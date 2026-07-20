"""Exact finite reference realizing aliasing, querying and repair."""

from __future__ import annotations

from ..canonical import content_sha256
from ..contracts import DomainKind, Episode, World
from .base import ClosedFamilyMixin


class FiniteReferenceDomain(ClosedFamilyMixin):
    kind = DomainKind.FINITE
    query_catalog = ("read_low_bit", "read_high_bit", "read_exact", "observe_neutral")
    action_catalog = ("continue_left", "continue_right")
    repair_catalog = ("defer",) + action_catalog

    def generate_episode(self, seed: int, actual_index: int = 0) -> Episode:
        if not 0 <= actual_index < 32:
            raise ValueError("actual_index must lie in [0, 31]")
        worlds: list[World] = []
        for index in range(32):
            bucket = index // 8
            local = index % 8
            public = {"visible_bucket": bucket, "candidate": "unresolved"}
            hidden = {"bucket": bucket, "latent_code": local, "seed": seed}
            world_id = "finite-" + content_sha256(hidden)[:20]
            worlds.append(
                World(
                    world_id=world_id,
                    public_observation=public,
                    hidden_state=hidden,
                    required_action=self.action_catalog[local % 2],
                    query_answers={
                        "read_low_bit": str(local % 2),
                        "read_high_bit": str(local // 4),
                        "read_exact": str(local),
                        "observe_neutral": "constant",
                    },
                )
            )
        actual_world_id = worlds[actual_index].world_id
        episode_id = "finite-episode-" + content_sha256(
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
            metadata={"generator": "finite-reference-v1", "seed": seed},
        )
        episode.validate_closed_family()
        return episode
