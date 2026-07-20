"""Pre-registered IID/OOD transformations and structural-disjointness audit."""

from __future__ import annotations

import dataclasses
from typing import Iterable

import numpy as np

from .canonical import content_sha256
from .contracts import Episode, World
from .domains.perceptual import PerceptualDomain
from .domains.symbolic import SymbolicDomain


OOD_FAMILIES = (
    "OOD-composition",
    "OOD-horizon",
    "OOD-presentation",
    "OOD-action-response",
    "OOD-cross-family",
)


def _replace_world(
    world: World,
    public: dict[str, object],
    hidden: dict[str, object],
    required_action: str | None = None,
    query_answers: dict[str, str] | None = None,
) -> World:
    world_id = world.world_id + "-ood-" + content_sha256(
        {"public": public, "hidden": hidden, "required": required_action or world.required_action}
    )[:12]
    return World(
        world_id=world_id,
        public_observation=public,
        hidden_state=hidden,
        required_action=required_action or world.required_action,
        query_answers=query_answers or dict(world.query_answers),
    )


def make_ood_episode(domain: object, episode: Episode, family: str) -> Episode:
    if family not in OOD_FAMILIES:
        raise ValueError("unknown OOD family")
    transformed: list[World] = []
    action_catalog = episode.action_catalog
    repair_catalog = episode.repair_catalog
    episode_horizon = (8, 12, 16)[int(episode.metadata.get("seed", 0)) % 3]
    for world in episode.worlds:
        public = dict(world.public_observation)
        hidden = dict(world.hidden_state)
        required = world.required_action
        answers = dict(world.query_answers)
        if family in {"OOD-composition", "OOD-cross-family"}:
            if isinstance(domain, SymbolicDomain):
                prefix = ("const", "17", ";", "const", "19", ";", "mul", "0", "1", ";")
                public["candidate_tokens"] = prefix + tuple(public["candidate_tokens"])
                hidden["ood_dependency_prefix"] = prefix
                hidden["ood_program_length"] = 8
            else:
                public["composition_depth"] = 8
                hidden["complete_program"] = tuple(hidden["complete_program"]) + (
                    "verify:anchor", "verify:target", "commit:repair"
                )
        if family == "OOD-horizon":
            horizon = episode_horizon
            public["history_horizon"] = tuple(f"prior:{index}" for index in range(horizon))
            hidden["horizon"] = horizon
        if family in {"OOD-presentation", "OOD-cross-family"}:
            public["presentation_vocabulary"] = "held-out-violet-diamond"
            if isinstance(domain, SymbolicDomain):
                replacements = {"input": "ARG", "const": "LIT", "add": "PLUS", "if_zero": "BRANCH0"}
                public["candidate_tokens"] = tuple(
                    replacements.get(str(token), str(token))
                    for token in public["candidate_tokens"]
                )
            else:
                public["visual_transform"] = "rgb-to-gbr-plus-marker"
        if family == "OOD-action-response":
            answers = {query: "heldout::" + answer for query, answer in answers.items()}
            required = "heldout::" + required
        transformed.append(_replace_world(world, public, hidden, required, answers))
    if family == "OOD-action-response":
        action_catalog = tuple("heldout::" + action for action in episode.action_catalog)
        repair_catalog = ("defer",) + action_catalog
    actual_index = tuple(world.world_id for world in episode.worlds).index(episode.actual_world_id)
    metadata = dict(episode.metadata) | {
        "split": "ood",
        "ood_family": family,
        "structural_fingerprint": structural_fingerprint(domain, family),
    }
    result = Episode(
        episode_id=episode.episode_id + "-" + family.lower(),
        domain=episode.domain,
        worlds=tuple(transformed),
        actual_world_id=transformed[actual_index].world_id,
        query_catalog=episode.query_catalog,
        action_catalog=action_catalog,
        repair_catalog=repair_catalog,
        metadata=metadata,
    )
    result.validate_closed_family()
    return result


def structural_fingerprint(domain: object, family: str) -> str:
    domain_name = getattr(getattr(domain, "kind", None), "value", type(domain).__name__)
    specification = {
        "domain": domain_name,
        "family": family,
        "opcode_depth": 8 if family in {"OOD-composition", "OOD-cross-family"} else 5,
        "horizon": family == "OOD-horizon",
        "heldout_presentation": family in {"OOD-presentation", "OOD-cross-family"},
        "heldout_action_response": family == "OOD-action-response",
    }
    return content_sha256(specification)


def iid_fingerprint(domain: object) -> str:
    domain_name = getattr(getattr(domain, "kind", None), "value", type(domain).__name__)
    return content_sha256(
        {
            "domain": domain_name,
            "family": "IID",
            "opcode_depth": 5,
            "horizon": False,
            "heldout_presentation": False,
            "heldout_action_response": False,
        }
    )


def audit_structural_disjointness(domains: Iterable[object]) -> dict[str, object]:
    collisions: list[str] = []
    fingerprints: dict[str, str] = {}
    for domain in domains:
        name = domain.kind.value
        iid = iid_fingerprint(domain)
        fingerprints[f"{name}:IID"] = iid
        for family in OOD_FAMILIES:
            key = f"{name}:{family}"
            fingerprint = structural_fingerprint(domain, family)
            fingerprints[key] = fingerprint
            if fingerprint == iid:
                collisions.append(key)
    return {
        "schema": "v23-structural-disjointness-1",
        "fingerprints": fingerprints,
        "collisions": tuple(collisions),
        "ok": not collisions,
    }


def perceptual_ood_tensor(
    domain: PerceptualDomain, episode: Episode
) -> np.ndarray:
    base = domain.observation_tensor(episode)
    family = episode.metadata.get("ood_family")
    if family in {"OOD-presentation", "OOD-cross-family"}:
        base = base[:, (1, 2, 0), :, :]
        base[:, :, 48:56, 48:56] = np.asarray([0.7, 0.2, 0.9], dtype=np.float32)[:, None, None]
    if family in {"OOD-composition", "OOD-cross-family"}:
        intermediate = (base[0] // 2 + base[-1] // 2)[None, ...]
        base = np.concatenate((base[:1], intermediate, base[1:]), axis=0)
    if family == "OOD-horizon":
        horizon = int(episode.actual_world().public_observation["history_horizon"][-1].split(":")[-1]) + 1
        repeats = max(1, horizon // 2)
        base = np.concatenate([base for _ in range(repeats)], axis=0)
        if base.shape[0] < 16:
            padding = np.repeat(base[-1:], 16 - base.shape[0], axis=0)
            base = np.concatenate((base, padding), axis=0)
    return base
