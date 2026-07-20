"""Exact finite no-go, optimal passive controller and active sufficiency audit."""

from __future__ import annotations

from itertools import product
from typing import Any

from .canonical import content_sha256
from .contracts import ActiveDomain, Episode
from .reference_agent import ExactActiveAgent


def observation_classes(episode: Episode) -> tuple[tuple[str, ...], ...]:
    groups: dict[str, list[str]] = {}
    for world in episode.worlds:
        groups.setdefault(content_sha256(world.public_observation), []).append(world.world_id)
    return tuple(tuple(groups[key]) for key in sorted(groups))


def certify_passive_no_go(episode: Episode) -> dict[str, Any]:
    classes = observation_classes(episode)
    by_id = {world.world_id: world for world in episode.worlds}
    conflicting_classes = tuple(
        index
        for index, fiber in enumerate(classes)
        if len({by_id[world_id].required_action for world_id in fiber}) > 1
    )
    if not conflicting_classes:
        raise ValueError("the no-go certificate requires an action-conflicting fiber")
    controller_count = len(episode.action_catalog) ** len(classes)
    exhaustive = controller_count <= 1_000_000
    perfect_controllers = 0
    if exhaustive:
        for choices in product(episode.action_catalog, repeat=len(classes)):
            prediction = {
                world_id: choices[class_index]
                for class_index, fiber in enumerate(classes)
                for world_id in fiber
            }
            if all(prediction[world.world_id] == world.required_action for world in episode.worlds):
                perfect_controllers += 1
    majority_correct = 0
    for fiber in classes:
        counts = {
            action: sum(by_id[world_id].required_action == action for world_id in fiber)
            for action in episode.action_catalog
        }
        majority_correct += max(counts.values())
    return {
        "schema": "v23-passive-no-go-1",
        "observation_classes": len(classes),
        "conflicting_classes": conflicting_classes,
        "controller_count": controller_count,
        "exhaustively_enumerated": exhaustive,
        "perfect_controllers": perfect_controllers if exhaustive else None,
        "symbolic_impossibility": bool(conflicting_classes),
        "best_passive_correct": majority_correct,
        "world_count": len(episode.worlds),
        "best_passive_accuracy_micros": majority_correct * 1_000_000 // len(episode.worlds),
    }


def transcript_capacity_bits(query_count: int, response_count: int, steps: int) -> int:
    if min(query_count, response_count, steps) < 0:
        raise ValueError("capacity arguments must be non-negative")
    possibilities = (max(1, query_count) * max(1, response_count)) ** steps
    bits = 0
    bound = 1
    while bound < possibilities:
        bound *= 2
        bits += 1
    return bits


def certify_active_sufficiency(
    domain: ActiveDomain, seed: int = 230_000
) -> dict[str, Any]:
    agent = ExactActiveAgent()
    closed = 0
    maximum_steps = 0
    for actual_index in range(32):
        episode = domain.generate_episode(seed + actual_index, actual_index)
        trace = agent.run(domain, episode, seed + actual_index)
        closed += int(trace.closed)
        maximum_steps = max(maximum_steps, len(trace.steps))
    return {
        "schema": "v23-active-sufficiency-1",
        "closed": closed,
        "episodes": 32,
        "maximum_steps": maximum_steps,
        "sufficient": closed == 32,
    }


def certify_information_layer(domain: ActiveDomain) -> dict[str, Any]:
    episode = domain.generate_episode(230_000, 0)
    no_go = certify_passive_no_go(episode)
    responses = {
        response
        for world in episode.worlds
        for response in world.query_answers.values()
    }
    active = certify_active_sufficiency(domain)
    return {
        "schema": "v23-information-layer-1",
        "domain": domain.kind.value,
        "passive_no_go": no_go,
        "visible_factorized_no_go": no_go["symbolic_impossibility"],
        "best_controller": {
            "correct": no_go["best_passive_correct"],
            "worlds": no_go["world_count"],
        },
        "transcript_capacity_bits_at_active_horizon": transcript_capacity_bits(
            len(episode.query_catalog), len(responses), active["maximum_steps"]
        ),
        "active_sufficiency": active,
        "ok": no_go["symbolic_impossibility"] and active["sufficient"],
    }
