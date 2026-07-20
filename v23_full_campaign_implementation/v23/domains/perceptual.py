"""Integer-rasterized compositional scene-repair domain."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable

import numpy as np

from ..canonical import content_sha256
from ..contracts import DomainKind, Episode, World
from .base import ClosedFamilyMixin


PALETTE: dict[str, tuple[int, int, int]] = {
    "background": (8, 12, 20),
    "red": (220, 50, 47),
    "green": (54, 180, 90),
    "blue": (60, 110, 220),
    "yellow": (235, 190, 45),
}


@dataclass(frozen=True)
class SceneObject:
    object_id: str
    shape: str
    color: str
    x: int
    y: int
    z: int = 0

    def validate(self) -> None:
        if self.shape not in {"square", "circle", "triangle"}:
            raise ValueError("unknown shape")
        if self.color not in PALETTE or self.color == "background":
            raise ValueError("unknown foreground color")
        if not (0 <= self.x < 8 and 0 <= self.y < 8):
            raise ValueError("logical coordinates must lie in the 8x8 grid")


def _shape_mask(shape: str) -> np.ndarray:
    yy, xx = np.mgrid[0:8, 0:8]
    if shape == "square":
        return np.ones((8, 8), dtype=np.bool_)
    if shape == "circle":
        return (2 * xx - 7) ** 2 + (2 * yy - 7) ** 2 <= 49
    if shape == "triangle":
        return (yy >= 1) & (xx >= 3 - yy // 2) & (xx <= 4 + yy // 2)
    raise ValueError(f"unknown shape {shape}")


def render_scene(objects: Iterable[SceneObject]) -> np.ndarray:
    canvas = np.empty((64, 64, 3), dtype=np.uint8)
    canvas[:, :] = PALETTE["background"]
    ordered = sorted(objects, key=lambda item: (item.z, item.object_id))
    for item in ordered:
        item.validate()
        mask = _shape_mask(item.shape)
        top = item.y * 8
        left = item.x * 8
        view = canvas[top : top + 8, left : left + 8]
        view[mask] = PALETTE[item.color]
    return canvas


def transform_object(item: SceneObject, operation: str) -> SceneObject:
    if operation == "left":
        x, y = (item.x - 1) % 8, item.y
    elif operation == "right":
        x, y = (item.x + 1) % 8, item.y
    elif operation == "up":
        x, y = item.x, (item.y - 1) % 8
    elif operation == "down":
        x, y = item.x, (item.y + 1) % 8
    elif operation == "rot90":
        x, y = 7 - item.y, item.x
    else:
        raise ValueError(f"unknown transform {operation}")
    return SceneObject(item.object_id, item.shape, item.color, x, y, item.z)


class PerceptualDomain(ClosedFamilyMixin):
    kind = DomainKind.PERCEPTUAL
    query_catalog = ("inspect_mid_x", "inspect_mid_y", "inspect_mid_cell", "observe_neutral")
    action_catalog = tuple(f"insert_waypoint_{index}" for index in range(8))
    repair_catalog = ("defer",) + action_catalog
    waypoints = ((1, 2), (2, 2), (3, 2), (4, 2), (1, 5), (2, 5), (3, 5), (4, 5))

    @staticmethod
    def _public_scene(group: int) -> tuple[dict[str, object], dict[str, object]]:
        start = SceneObject("target", "circle", "red", group + 1, 1, 1)
        finish = SceneObject("target", "circle", "red", group + 1, 6, 1)
        distractor = SceneObject("anchor", "square", "blue", 6 - group, 3, 0)
        start_pixels = render_scene((start, distractor))
        finish_pixels = render_scene((finish, distractor))
        return (
            {
                "objects": (start, distractor),
                "raster_sha256": content_sha256(start_pixels.tolist()),
            },
            {
                "objects": (finish, distractor),
                "raster_sha256": content_sha256(finish_pixels.tolist()),
            },
        )

    def generate_episode(self, seed: int, actual_index: int = 0) -> Episode:
        if not 0 <= actual_index < 32:
            raise ValueError("actual_index must lie in [0, 31]")
        worlds: list[World] = []
        for group in range(4):
            initial, final = self._public_scene(group)
            for route, (mid_x, mid_y) in enumerate(self.waypoints):
                public = {
                    "initial": initial,
                    "final": final,
                    "candidate_program": ("select:red-circle", "move:to-final"),
                    "missing_slot": 1,
                }
                hidden = {
                    "waypoint": (mid_x, mid_y),
                    "route": route,
                    "group": group,
                    "seed": seed,
                    "complete_program": (
                        "select:red-circle",
                        f"move:{mid_x}:{mid_y}",
                        "move:to-final",
                    ),
                }
                world_id = "perceptual-" + content_sha256(hidden)[:20]
                worlds.append(
                    World(
                        world_id=world_id,
                        public_observation=public,
                        hidden_state=hidden,
                        required_action=f"insert_waypoint_{route}",
                        query_answers={
                            "inspect_mid_x": str(mid_x),
                            "inspect_mid_y": str(mid_y),
                            "inspect_mid_cell": f"{mid_x}:{mid_y}",
                            "observe_neutral": "constant",
                        },
                    )
                )
        actual_world_id = worlds[actual_index].world_id
        episode_id = "perceptual-episode-" + content_sha256(
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
                "generator": "integer-raster-compositional-v1",
                "grid": (8, 8),
                "raster": (64, 64, 3),
                "seed": seed,
            },
        )
        episode.validate_closed_family()
        return episode

    def observation_tensor(self, episode: Episode) -> np.ndarray:
        actual = episode.actual_world()
        group = int(actual.hidden_state["group"])
        initial, final = self._public_scene(group)
        initial_objects = tuple(initial["objects"])
        final_objects = tuple(final["objects"])
        frames = np.stack((render_scene(initial_objects), render_scene(final_objects)))
        return np.transpose(frames.astype(np.float32) / 255.0, (0, 3, 1, 2))
