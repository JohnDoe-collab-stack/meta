"""Bounded SSA program-repair domain with an independent interpreter."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Sequence

from ..canonical import content_sha256
from ..contracts import DomainKind, Episode, World
from .base import ClosedFamilyMixin


class Opcode(str, Enum):
    INPUT = "input"
    CONST = "const"
    ADD = "add"
    SUB = "sub"
    MUL = "mul"
    IF_ZERO = "if_zero"


@dataclass(frozen=True)
class Instruction:
    opcode: Opcode
    args: tuple[int, ...]


@dataclass(frozen=True)
class Program:
    instructions: tuple[Instruction, ...]

    def validate(self) -> None:
        if not self.instructions:
            raise ValueError("program cannot be empty")
        for register, instruction in enumerate(self.instructions):
            if instruction.opcode is Opcode.INPUT and instruction.args:
                raise ValueError("input accepts no arguments")
            if instruction.opcode is Opcode.CONST and len(instruction.args) != 1:
                raise ValueError("const accepts one literal")
            if instruction.opcode in {Opcode.ADD, Opcode.SUB, Opcode.MUL}:
                if len(instruction.args) != 2:
                    raise ValueError("binary instruction accepts two registers")
                if any(source < 0 or source >= register for source in instruction.args):
                    raise ValueError("SSA register must refer to an earlier value")
            if instruction.opcode is Opcode.IF_ZERO:
                if len(instruction.args) != 3:
                    raise ValueError("if_zero accepts condition and two branches")
                if any(source < 0 or source >= register for source in instruction.args):
                    raise ValueError("SSA register must refer to an earlier value")

    def evaluate(self, input_value: int) -> int:
        self.validate()
        registers: list[int] = []
        for instruction in self.instructions:
            if instruction.opcode is Opcode.INPUT:
                value = input_value
            elif instruction.opcode is Opcode.CONST:
                value = instruction.args[0]
            elif instruction.opcode is Opcode.ADD:
                value = registers[instruction.args[0]] + registers[instruction.args[1]]
            elif instruction.opcode is Opcode.SUB:
                value = registers[instruction.args[0]] - registers[instruction.args[1]]
            elif instruction.opcode is Opcode.MUL:
                value = registers[instruction.args[0]] * registers[instruction.args[1]]
            else:
                condition, then_register, else_register = instruction.args
                value = (
                    registers[then_register]
                    if registers[condition] == 0
                    else registers[else_register]
                )
            if abs(value) > 2**31 - 1:
                raise OverflowError("interpreter exceeds the signed 32-bit contract")
            registers.append(value)
        return registers[-1]

    def to_tokens(self) -> tuple[str, ...]:
        tokens: list[str] = []
        for instruction in self.instructions:
            tokens.append(instruction.opcode.value)
            tokens.extend(str(arg) for arg in instruction.args)
            tokens.append(";")
        return tuple(tokens)


def branch_program(zero_value: int, offset: int) -> Program:
    # r0=x; r1=zero_value; r2=offset; r3=x+offset; r4=ifZero r0 r1 r3
    return Program(
        (
            Instruction(Opcode.INPUT, ()),
            Instruction(Opcode.CONST, (zero_value,)),
            Instruction(Opcode.CONST, (offset,)),
            Instruction(Opcode.ADD, (0, 2)),
            Instruction(Opcode.IF_ZERO, (0, 1, 3)),
        )
    )


class SymbolicDomain(ClosedFamilyMixin):
    kind = DomainKind.SYMBOLIC
    probes: tuple[int, ...] = (1, 2, 3, 4, 5, 6, 7, 8)
    query_catalog = ("eval_0", "eval_neg1", "reveal_zero_branch", "observe_neutral")
    action_catalog = tuple(f"set_zero_{value}" for value in range(8))
    repair_catalog = ("defer",) + action_catalog

    def generate_episode(self, seed: int, actual_index: int = 0) -> Episode:
        if not 0 <= actual_index < 32:
            raise ValueError("actual_index must lie in [0, 31]")
        worlds: list[World] = []
        for offset in range(4):
            for zero_value in range(8):
                program = branch_program(zero_value, offset)
                table = tuple(program.evaluate(probe) for probe in self.probes)
                public = {
                    "candidate_tokens": branch_program(0, offset).to_tokens(),
                    "probes": self.probes,
                    "observed_outputs": table,
                }
                hidden = {
                    "program_tokens": program.to_tokens(),
                    "offset": offset,
                    "zero_value": zero_value,
                    "seed": seed,
                }
                world_id = "symbolic-" + content_sha256(hidden)[:20]
                worlds.append(
                    World(
                        world_id=world_id,
                        public_observation=public,
                        hidden_state=hidden,
                        required_action=f"set_zero_{zero_value}",
                        query_answers={
                            "eval_0": str(program.evaluate(0)),
                            "eval_neg1": str(program.evaluate(-1)),
                            "reveal_zero_branch": str(zero_value),
                            "observe_neutral": "constant",
                        },
                    )
                )
        actual_world_id = worlds[actual_index].world_id
        episode_id = "symbolic-episode-" + content_sha256(
            {"seed": seed, "actual": actual_world_id}
        )[:20]
        episode = Episode(
            episode_id=episode_id,
            domain=self.kind,
            worlds=tuple(worlds),
            actual_world_id=actual_world_id,
            query_catalog=self.query_catalog,
            action_catalog=self.action_catalog,
            repair_catalog=self.repair_catalog,
            metadata={
                "generator": "bounded-ssa-v1",
                "interpreter": "signed-int32-exact",
                "seed": seed,
            },
        )
        episode.validate_closed_family()
        return episode

    def independent_evaluate(self, tokens: Sequence[str], input_value: int) -> int:
        """Stack-free parser used as a differential oracle in tests."""
        registers: list[int] = []
        cursor = 0
        while cursor < len(tokens):
            opcode = tokens[cursor]
            cursor += 1
            arguments: list[int] = []
            while cursor < len(tokens) and tokens[cursor] != ";":
                arguments.append(int(tokens[cursor]))
                cursor += 1
            if cursor >= len(tokens):
                raise ValueError("unterminated instruction")
            cursor += 1
            if opcode == "input":
                result = input_value
            elif opcode == "const":
                result = arguments[0]
            elif opcode == "add":
                result = registers[arguments[0]] + registers[arguments[1]]
            elif opcode == "sub":
                result = registers[arguments[0]] - registers[arguments[1]]
            elif opcode == "mul":
                result = registers[arguments[0]] * registers[arguments[1]]
            elif opcode == "if_zero":
                result = (
                    registers[arguments[1]]
                    if registers[arguments[0]] == 0
                    else registers[arguments[2]]
                )
            else:
                raise ValueError(f"unknown opcode {opcode}")
            registers.append(result)
        if not registers:
            raise ValueError("empty token stream")
        return registers[-1]
