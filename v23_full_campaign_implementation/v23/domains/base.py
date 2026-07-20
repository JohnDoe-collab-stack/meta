"""Shared exact posterior operations."""

from __future__ import annotations

from typing import Sequence

from ..canonical import content_sha256
from ..contracts import Episode


class ClosedFamilyMixin:
    def initial_fiber(self, episode: Episode) -> tuple[str, ...]:
        actual_hash = content_sha256(episode.actual_world().public_observation)
        return tuple(
            world.world_id
            for world in episode.worlds
            if content_sha256(world.public_observation) == actual_hash
        )

    def answer(self, episode: Episode, world_id: str, query_id: str) -> str:
        for world in episode.worlds:
            if world.world_id == world_id:
                try:
                    return world.query_answers[query_id]
                except KeyError as error:
                    raise KeyError(f"query {query_id} is not authorized") from error
        raise KeyError(f"unknown world {world_id}")

    def posterior(
        self,
        episode: Episode,
        fiber: Sequence[str],
        query_id: str,
        response_id: str,
    ) -> tuple[str, ...]:
        allowed = set(fiber)
        return tuple(
            world.world_id
            for world in episode.worlds
            if world.world_id in allowed
            and world.query_answers.get(query_id) == response_id
        )

    def action_sufficient(self, episode: Episode, fiber: Sequence[str]) -> bool:
        allowed = set(fiber)
        actions = {
            world.required_action
            for world in episode.worlds
            if world.world_id in allowed
        }
        return len(actions) <= 1 and bool(actions)

    def required_action_for_fiber(
        self, episode: Episode, fiber: Sequence[str]
    ) -> str | None:
        allowed = set(fiber)
        actions = {
            world.required_action
            for world in episode.worlds
            if world.world_id in allowed
        }
        if len(actions) == 1:
            return next(iter(actions))
        return None
