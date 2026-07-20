"""Collision-free byte tokenization and episode tensorization."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import torch
from torch import Tensor

from .canonical import canonical_json
from .contracts import Episode
from .domains.perceptual import PerceptualDomain


PAD = 0
BOS = 1
EOS = 2
BYTE_OFFSET = 3
BYTE_VOCAB_SIZE = 259


def byte_tokens(value: Any, maximum_length: int = 512) -> tuple[int, ...]:
    raw = canonical_json(value).encode("utf-8")
    tokens = (BOS,) + tuple(BYTE_OFFSET + byte for byte in raw) + (EOS,)
    if len(tokens) > maximum_length:
        raise ValueError(
            f"canonical token sequence has length {len(tokens)}, limit {maximum_length}"
        )
    return tokens


def pad_token_rows(rows: list[tuple[int, ...]], minimum_length: int = 1) -> Tensor:
    width = max(minimum_length, *(len(row) for row in rows))
    result = torch.full((len(rows), width), PAD, dtype=torch.long)
    for index, row in enumerate(rows):
        result[index, : len(row)] = torch.tensor(row, dtype=torch.long)
    return result


@dataclass(frozen=True)
class EncodedBatch:
    observation: Tensor
    candidate: Tensor
    history: Tensor
    symbolic: bool


def encode_episode_batch(domain: object, episodes: list[Episode]) -> EncodedBatch:
    if not episodes:
        raise ValueError("cannot encode an empty batch")
    candidates = [
        byte_tokens(episode.actual_world().public_observation.get("candidate_tokens", episode.actual_world().public_observation.get("candidate_program", "none")))
        for episode in episodes
    ]
    histories = [byte_tokens({"history": ()}) for _ in episodes]
    if isinstance(domain, PerceptualDomain):
        from .splits import perceptual_ood_tensor

        observation = torch.from_numpy(
            __import__("numpy").stack(
                [
                    perceptual_ood_tensor(domain, episode)
                    if episode.metadata.get("ood_family")
                    else domain.observation_tensor(episode)
                    for episode in episodes
                ]
            )
        )
        symbolic = False
    else:
        public_observations = []
        for episode in episodes:
            public = dict(episode.actual_world().public_observation)
            public.pop("candidate_tokens", None)
            public.pop("candidate_program", None)
            public_observations.append(public)
        observation = pad_token_rows(
            [byte_tokens(public) for public in public_observations]
        )
        symbolic = True
    return EncodedBatch(
        observation=observation,
        candidate=pad_token_rows(candidates),
        history=pad_token_rows(histories),
        symbolic=symbolic,
    )
