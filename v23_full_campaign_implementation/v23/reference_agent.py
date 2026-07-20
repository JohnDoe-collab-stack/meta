"""Constructive finite active policy and proof-relevant trace producer."""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from itertools import combinations
from typing import Iterable, Sequence

from .canonical import content_sha256
from .contracts import (
    ActiveDomain,
    CertifiedRepairStep,
    Decision,
    DecisionKind,
    Episode,
    EpisodeTrace,
    RepairRecord,
)


def action_conflict_pairs(episode: Episode, fiber: Sequence[str]) -> int:
    by_id = {world.world_id: world for world in episode.worlds}
    return sum(
        1
        for left, right in combinations(fiber, 2)
        if by_id[left].required_action != by_id[right].required_action
    )


def _decision(
    kind: DecisionKind,
    selected: str,
    catalog: Iterable[str],
    provenance: Iterable[str],
    allowed: Iterable[str] | None = None,
) -> Decision:
    items = tuple(catalog)
    allowed_set = set(items if allowed is None else allowed)
    mask = tuple(item in allowed_set for item in items)
    logits = tuple(1_000_000 if item == selected else 0 for item in items)
    decision = Decision(kind, selected, items, mask, logits, tuple(provenance))
    decision.validate()
    return decision


@dataclass(frozen=True)
class QueryScore:
    query_id: str
    worst_conflicts: int
    total_conflicts: int
    largest_branch: int


class ExactActiveAgent:
    """Decision-tree policy minimizing residual action conflicts exactly."""

    system_id = "C-exact-active"

    def score_query(
        self,
        domain: ActiveDomain,
        episode: Episode,
        fiber: Sequence[str],
        query_id: str,
    ) -> QueryScore:
        branches: dict[str, list[str]] = defaultdict(list)
        for world_id in fiber:
            branches[domain.answer(episode, world_id, query_id)].append(world_id)
        conflict_counts = [
            action_conflict_pairs(episode, branch) for branch in branches.values()
        ]
        return QueryScore(
            query_id=query_id,
            worst_conflicts=max(conflict_counts, default=0),
            total_conflicts=sum(conflict_counts),
            largest_branch=max((len(branch) for branch in branches.values()), default=0),
        )

    def choose_query(
        self, domain: ActiveDomain, episode: Episode, fiber: Sequence[str]
    ) -> tuple[str, tuple[QueryScore, ...]]:
        scores = tuple(
            self.score_query(domain, episode, fiber, query)
            for query in episode.query_catalog
        )
        ranked = sorted(
            scores,
            key=lambda item: (
                item.worst_conflicts,
                item.total_conflicts,
                item.largest_branch,
                episode.query_catalog.index(item.query_id),
            ),
        )
        if not ranked:
            raise RuntimeError("an active episode requires an authorized query")
        best = ranked[0]
        current_conflicts = action_conflict_pairs(episode, fiber)
        if best.worst_conflicts >= current_conflicts and current_conflicts > 0:
            raise RuntimeError("authorized queries cannot reduce action ambiguity")
        return best.query_id, scores

    def run(
        self,
        domain: ActiveDomain,
        episode: Episode,
        seed: int,
        intervention_id: str | None = None,
        max_steps: int = 16,
    ) -> EpisodeTrace:
        episode.validate_closed_family()
        actual = episode.actual_world()
        fiber = domain.initial_fiber(episode)
        initial_fiber = tuple(fiber)
        memory: tuple[str, ...] = ()
        steps: list[CertifiedRepairStep] = []
        for step_index in range(max_steps):
            if domain.action_sufficient(episode, fiber):
                break
            query_id, scores = self.choose_query(domain, episode, fiber)
            response_id = domain.answer(episode, actual.world_id, query_id)
            fiber_after = domain.posterior(
                episode, fiber, query_id, response_id
            )
            if actual.world_id not in set(fiber_after):
                raise RuntimeError("posterior eliminated the actual world")
            if not set(fiber_after) < set(fiber):
                raise RuntimeError("active query failed to refine the actual branch")
            sufficient = domain.action_sufficient(episode, fiber_after)
            predicted = (
                domain.required_action_for_fiber(episode, fiber_after)
                if hasattr(domain, "required_action_for_fiber")
                else None
            )
            repair_id = predicted if predicted is not None else "defer"
            score_logits = {
                score.query_id: -1_000 * score.worst_conflicts
                - 10 * score.total_conflicts
                - score.largest_branch
                for score in scores
            }
            query_decision = Decision(
                kind=DecisionKind.QUERY,
                selected_id=query_id,
                catalog=episode.query_catalog,
                allowed_mask=tuple(True for _ in episode.query_catalog),
                logits_micros=tuple(
                    score_logits[query] for query in episode.query_catalog
                ),
                provenance=(episode.episode_id, "authorized-query-catalog"),
            )
            decisions = (
                _decision(
                    DecisionKind.DETECT,
                    "gap",
                    ("closed", "gap"),
                    (episode.episode_id, "fiber"),
                ),
                _decision(
                    DecisionKind.GAP,
                    "action_conflict",
                    ("none", "action_conflict"),
                    ("fiber", "required-action"),
                ),
                _decision(
                    DecisionKind.USE,
                    "query_response",
                    ("visible_state", "query_response"),
                    ("gap:action_conflict",),
                ),
                _decision(
                    DecisionKind.TRANSPORT,
                    "authorized_query",
                    ("none", "authorized_query"),
                    ("use:query_response",),
                ),
                query_decision,
                _decision(
                    DecisionKind.REPAIR,
                    repair_id,
                    episode.repair_catalog,
                    (query_id, response_id, "posterior"),
                ),
                _decision(
                    DecisionKind.CONTINUE,
                    predicted or "defer",
                    ("defer",) + episode.action_catalog,
                    ("repair", repair_id),
                ),
            )
            provenance = (query_id, response_id, episode.episode_id, actual.world_id)
            new_memory = memory + tuple(
                item for item in provenance if item not in set(memory)
            )
            record = RepairRecord(
                repair_id=repair_id,
                query_id=query_id,
                response_id=response_id,
                fiber_before=tuple(fiber),
                fiber_after=tuple(fiber_after),
                retained_closures=tuple(
                    f"step:{index}" for index in range(step_index)
                ),
                provenance=provenance,
            )
            step = CertifiedRepairStep(
                step_index=step_index,
                fiber_before=tuple(fiber),
                decisions=decisions,
                query_id=query_id,
                response_id=response_id,
                repair=record,
                fiber_after=tuple(fiber_after),
                memory_before=memory,
                memory_after=new_memory,
                predicted_action_after=predicted,
                action_sufficient_after=sufficient,
                transition_derived_from_repair=True,
            )
            step.validate()
            steps.append(step)
            fiber = tuple(fiber_after)
            memory = new_memory
        if not domain.action_sufficient(episode, fiber):
            raise RuntimeError("certified repair episode did not terminate")
        predicted_action = domain.required_action_for_fiber(episode, fiber)
        if predicted_action is None:
            raise RuntimeError("action-sufficient fiber has no unique action")
        trace = EpisodeTrace(
            schema_version="v23.1",
            episode_id=episode.episode_id,
            system_id=self.system_id,
            seed=seed,
            observation_hash=content_sha256(actual.public_observation),
            actual_world_id=actual.world_id,
            initial_fiber=initial_fiber,
            steps=tuple(steps),
            final_fiber=tuple(fiber),
            required_action=actual.required_action,
            predicted_action=predicted_action,
            intervention_id=intervention_id,
            closed=predicted_action == actual.required_action,
        )
        trace.validate()
        return trace
