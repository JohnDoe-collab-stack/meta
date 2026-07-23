#!/usr/bin/env python3
"""Render the French and English causal-gap diagrams as SVG and PNG."""

from __future__ import annotations

from dataclasses import dataclass, field
from html import escape
from math import atan2, cos, hypot, sin
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parent
FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_BOLD_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
SCALE = 2


@dataclass
class Node:
    name: str
    x: float
    y: float
    w: float
    h: float
    text: str
    fill: str
    stroke: str
    dashed: bool = False
    font_size: int = 14


@dataclass
class Edge:
    source: str
    target: str
    label: str = ""
    color: str = "#4a4a4a"
    dashed: bool = False
    both: bool = False
    width: float = 1.6


@dataclass
class Cluster:
    x: float
    y: float
    w: float
    h: float
    title: str
    stroke: str = "#315d80"


@dataclass
class Diagram:
    width: int
    height: int
    title: str
    nodes: list[Node] = field(default_factory=list)
    edges: list[Edge] = field(default_factory=list)
    clusters: list[Cluster] = field(default_factory=list)

    def node(self, name: str) -> Node:
        return next(node for node in self.nodes if node.name == name)


def hex_rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD_PATH if bold else FONT_PATH, size * SCALE)


def node_boundary(source: Node, target: Node) -> tuple[tuple[float, float], tuple[float, float]]:
    dx = target.x - source.x
    dy = target.y - source.y

    def boundary(node: Node, vx: float, vy: float) -> tuple[float, float]:
        candidates: list[float] = []
        if vx:
            candidates.append((node.w / 2) / abs(vx))
        if vy:
            candidates.append((node.h / 2) / abs(vy))
        factor = min(candidates)
        return node.x + vx * factor, node.y + vy * factor

    start = boundary(source, dx, dy)
    end = boundary(target, -dx, -dy)
    return start, end


def arrow_polygon(point: tuple[float, float], angle: float, size: float = 10) -> list[tuple[float, float]]:
    x, y = point
    return [
        (x, y),
        (x - size * cos(angle - 0.48), y - size * sin(angle - 0.48)),
        (x - size * cos(angle + 0.48), y - size * sin(angle + 0.48)),
    ]


def dashed_segments(start: tuple[float, float], end: tuple[float, float], dash: float = 9, gap: float = 7):
    x1, y1 = start
    x2, y2 = end
    length = hypot(x2 - x1, y2 - y1)
    if length == 0:
        return
    ux = (x2 - x1) / length
    uy = (y2 - y1) / length
    position = 0.0
    while position < length:
        finish = min(position + dash, length)
        yield (
            (x1 + ux * position, y1 + uy * position),
            (x1 + ux * finish, y1 + uy * finish),
        )
        position += dash + gap


def draw_centered_text(
    draw: ImageDraw.ImageDraw,
    center: tuple[float, float],
    text: str,
    size: int,
    color: str = "#222222",
    bold_first: bool = False,
) -> None:
    lines = text.splitlines()
    line_height = (size + 5) * SCALE
    y = center[1] * SCALE - (len(lines) * line_height) / 2
    for index, line in enumerate(lines):
        selected_font = font(size, bold_first and index == 0)
        box = draw.textbbox((0, 0), line, font=selected_font)
        width = box[2] - box[0]
        draw.text(
            (center[0] * SCALE - width / 2, y),
            line,
            font=selected_font,
            fill=hex_rgb(color),
        )
        y += line_height


def render_png(diagram: Diagram, output: Path) -> None:
    image = Image.new("RGB", (diagram.width * SCALE, diagram.height * SCALE), "white")
    draw = ImageDraw.Draw(image)

    draw_centered_text(
        draw,
        (diagram.width / 2, 30),
        diagram.title,
        20,
        bold_first=True,
    )

    for cluster in diagram.clusters:
        box = tuple(int(value * SCALE) for value in (
            cluster.x,
            cluster.y,
            cluster.x + cluster.w,
            cluster.y + cluster.h,
        ))
        draw.rounded_rectangle(
            box,
            radius=14 * SCALE,
            outline=hex_rgb(cluster.stroke),
            width=2 * SCALE,
        )
        draw_centered_text(
            draw,
            (cluster.x + cluster.w / 2, cluster.y + 22),
            cluster.title,
            15,
            color=cluster.stroke,
            bold_first=True,
        )

    for edge in diagram.edges:
        source = diagram.node(edge.source)
        target = diagram.node(edge.target)
        start, end = node_boundary(source, target)
        scaled_start = (start[0] * SCALE, start[1] * SCALE)
        scaled_end = (end[0] * SCALE, end[1] * SCALE)
        edge_color = hex_rgb(edge.color)
        if edge.dashed:
            for segment_start, segment_end in dashed_segments(scaled_start, scaled_end, 10 * SCALE, 7 * SCALE):
                draw.line((segment_start, segment_end), fill=edge_color, width=max(1, int(edge.width * SCALE)))
        else:
            draw.line((scaled_start, scaled_end), fill=edge_color, width=max(1, int(edge.width * SCALE)))

        angle = atan2(scaled_end[1] - scaled_start[1], scaled_end[0] - scaled_start[0])
        draw.polygon(arrow_polygon(scaled_end, angle, 9 * SCALE), fill=edge_color)
        if edge.both:
            draw.polygon(arrow_polygon(scaled_start, angle + 3.141592653589793, 9 * SCALE), fill=edge_color)

        if edge.label:
            midpoint = ((start[0] + end[0]) / 2, (start[1] + end[1]) / 2)
            label_font = font(10)
            label_box = draw.textbbox((0, 0), edge.label, font=label_font)
            label_width = label_box[2] - label_box[0]
            label_height = label_box[3] - label_box[1]
            background = (
                midpoint[0] * SCALE - label_width / 2 - 6 * SCALE,
                midpoint[1] * SCALE - label_height / 2 - 4 * SCALE,
                midpoint[0] * SCALE + label_width / 2 + 6 * SCALE,
                midpoint[1] * SCALE + label_height / 2 + 4 * SCALE,
            )
            draw.rounded_rectangle(background, radius=4 * SCALE, fill="white")
            draw.text(
                (midpoint[0] * SCALE - label_width / 2, midpoint[1] * SCALE - label_height / 2),
                edge.label,
                font=label_font,
                fill=edge_color,
            )

    for node in diagram.nodes:
        box = tuple(int(value * SCALE) for value in (
            node.x - node.w / 2,
            node.y - node.h / 2,
            node.x + node.w / 2,
            node.y + node.h / 2,
        ))
        draw.rounded_rectangle(
            box,
            radius=12 * SCALE,
            fill=hex_rgb(node.fill),
            outline=hex_rgb(node.stroke),
            width=2 * SCALE,
        )
        if node.dashed:
            for segment_start, segment_end in dashed_segments(
                (box[0], box[1]), (box[2], box[1]), 8 * SCALE, 6 * SCALE
            ):
                draw.line((segment_start, segment_end), fill=hex_rgb(node.stroke), width=2 * SCALE)
        draw_centered_text(
            draw,
            (node.x, node.y),
            node.text,
            node.font_size,
            bold_first=True,
        )

    image.save(output, format="PNG", optimize=True)


def svg_text(x: float, y: float, text: str, size: int, bold_first: bool = False, color: str = "#222222") -> str:
    lines = text.splitlines()
    line_height = size + 5
    first_y = y - ((len(lines) - 1) * line_height) / 2
    parts = [
        f'<text x="{x:.1f}" y="{first_y:.1f}" text-anchor="middle" '
        f'font-family="DejaVu Sans" font-size="{size}" fill="{color}">'
    ]
    for index, line in enumerate(lines):
        weight = "700" if bold_first and index == 0 else "400"
        dy = "0" if index == 0 else str(line_height)
        parts.append(
            f'<tspan x="{x:.1f}" dy="{dy}" font-weight="{weight}">{escape(line)}</tspan>'
        )
    parts.append("</text>")
    return "".join(parts)


def svg_arrow(point: tuple[float, float], angle: float, color: str, size: float = 9) -> str:
    points = arrow_polygon(point, angle, size)
    value = " ".join(f"{x:.1f},{y:.1f}" for x, y in points)
    return f'<polygon points="{value}" fill="{color}"/>'


def render_svg(diagram: Diagram, output: Path) -> None:
    elements: list[str] = [
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>',
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{diagram.width}" height="{diagram.height}" '
        f'viewBox="0 0 {diagram.width} {diagram.height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        svg_text(diagram.width / 2, 32, diagram.title, 20, True),
    ]

    for cluster in diagram.clusters:
        elements.append(
            f'<rect x="{cluster.x}" y="{cluster.y}" width="{cluster.w}" height="{cluster.h}" '
            f'rx="14" fill="none" stroke="{cluster.stroke}" stroke-width="2"/>'
        )
        elements.append(
            svg_text(cluster.x + cluster.w / 2, cluster.y + 25, cluster.title, 15, True, cluster.stroke)
        )

    for edge in diagram.edges:
        source = diagram.node(edge.source)
        target = diagram.node(edge.target)
        start, end = node_boundary(source, target)
        dash = ' stroke-dasharray="9 7"' if edge.dashed else ""
        elements.append(
            f'<line x1="{start[0]:.1f}" y1="{start[1]:.1f}" '
            f'x2="{end[0]:.1f}" y2="{end[1]:.1f}" '
            f'stroke="{edge.color}" stroke-width="{edge.width}"{dash}/>'
        )
        angle = atan2(end[1] - start[1], end[0] - start[0])
        elements.append(svg_arrow(end, angle, edge.color))
        if edge.both:
            elements.append(svg_arrow(start, angle + 3.141592653589793, edge.color))
        if edge.label:
            midpoint = ((start[0] + end[0]) / 2, (start[1] + end[1]) / 2)
            label_width = max(70, len(edge.label) * 5.7)
            elements.append(
                f'<rect x="{midpoint[0] - label_width / 2 - 6:.1f}" '
                f'y="{midpoint[1] - 11:.1f}" width="{label_width + 12:.1f}" height="20" '
                f'rx="4" fill="white"/>'
            )
            elements.append(svg_text(midpoint[0], midpoint[1] + 3, edge.label, 10, False, edge.color))

    for node in diagram.nodes:
        dash = ' stroke-dasharray="8 6"' if node.dashed else ""
        elements.append(
            f'<rect x="{node.x - node.w / 2:.1f}" y="{node.y - node.h / 2:.1f}" '
            f'width="{node.w:.1f}" height="{node.h:.1f}" rx="12" '
            f'fill="{node.fill}" stroke="{node.stroke}" stroke-width="2"{dash}/>'
        )
        elements.append(svg_text(node.x, node.y + 4, node.text, node.font_size, True))

    elements.append("</svg>")
    output.write_text("\n".join(elements) + "\n", encoding="utf-8")


def improved_diagram(english: bool) -> Diagram:
    if english:
        title = "Gap-mediated causal morphism"
        cluster_t = "Realization T — local Tarskian correction"
        cluster_p = "Realization P — local provability"
        labels = {
            "state_t": "State S_T",
            "state_p": "State S_P := φ(S_T)",
            "built_t": "constructs gap_T",
            "built_p": "constructs gap_P",
            "inc_t": "incorporated by advance_T",
            "inc_p": "incorporated by advance_P",
            "new": "none branch",
            "next": "new frontier",
            "commute": "φ commutes with advance",
            "nosem": "NO VERTICAL SEMANTIC COMPONENT\nEvaluated_T ↛ Evaluated_P",
        }
    else:
        title = "Morphisme causal médiatisé par le gap"
        cluster_t = "Réalisation T — correction tarskienne locale"
        cluster_p = "Réalisation P — prouvabilité locale"
        labels = {
            "state_t": "État S_T",
            "state_p": "État S_P := φ(S_T)",
            "built_t": "construit gap_T",
            "built_p": "construit gap_P",
            "inc_t": "incorporé par advance_T",
            "inc_p": "incorporé par advance_P",
            "new": "branche none",
            "next": "nouvelle frontière",
            "commute": "φ commute avec advance",
            "nosem": "AUCUNE COMPOSANTE SÉMANTIQUE VERTICALE\nEvaluated_T ↛ Evaluated_P",
        }

    diagram = Diagram(1900, 820, title)
    diagram.clusters = [
        Cluster(30, 75, 1840, 280, cluster_t),
        Cluster(30, 465, 1840, 280, cluster_p),
    ]
    xs = [115, 390, 700, 1010, 1320, 1635]
    widths = [140, 260, 245, 280, 245, 270]
    diagram.nodes = [
        Node("T0", xs[0], 220, widths[0], 70, labels["state_t"], "#eef4fb", "#315d80"),
        Node("TG", xs[1], 220, widths[1], 105, "d_T := gap_T(S_T)\nfrontier_open_T\n¬ Evaluated_T(S_T, d_T)", "#fff8e6", "#8a6500"),
        Node("T1", xs[2], 220, widths[2], 75, "S_T⁺ := advance_T(S_T)", "#eef4fb", "#315d80"),
        Node("TN", xs[3], 220, widths[3], 95, "new_T(S_T) : Position_T(S_T⁺)\nlabel_T[S_T⁺](new_T(S_T)) = d_T", "#edf8ef", "#35733b"),
        Node("TC", xs[4], 220, widths[4], 90, "frontier_closed_T\nEvaluated_T(S_T⁺, d_T)", "#f5f0fb", "#6a4b8a"),
        Node("TG1", xs[5], 220, widths[5], 105, "d_T⁺ := gap_T(S_T⁺)\nfrontier_open_T\n¬ Evaluated_T(S_T⁺, d_T⁺)", "#fff8e6", "#8a6500"),
        Node("P0", xs[0], 610, widths[0] + 35, 70, labels["state_p"], "#eef4fb", "#315d80"),
        Node("PG", xs[1], 610, widths[1], 105, "d_P := gap_P(S_P)\nfrontier_open_P\n¬ Evaluated_P(S_P, d_P)", "#fff8e6", "#8a6500"),
        Node("P1", xs[2], 610, widths[2], 90, "S_P⁺ := advance_P(S_P)\n= φ(S_T⁺)", "#eef4fb", "#315d80"),
        Node("PN", xs[3], 610, widths[3], 95, "new_P(S_P) : Position_P(S_P⁺)\nlabel_P[S_P⁺](new_P(S_P)) = d_P", "#edf8ef", "#35733b"),
        Node("PC", xs[4], 610, widths[4], 90, "frontier_closed_P\nEvaluated_P(S_P⁺, d_P)", "#f5f0fb", "#6a4b8a"),
        Node("PG1", xs[5], 610, widths[5], 105, "d_P⁺ := gap_P(S_P⁺)\nfrontier_open_P\n¬ Evaluated_P(S_P⁺, d_P⁺)", "#fff8e6", "#8a6500"),
        Node("NS", 1320, 410, 330, 75, labels["nosem"], "#fff1f1", "#9b3d3d", True, 12),
    ]
    diagram.edges = [
        Edge("T0", "TG", labels["built_t"]),
        Edge("TG", "T1", labels["inc_t"]),
        Edge("T1", "TN", labels["new"]),
        Edge("TN", "TC", "position_evaluated_T"),
        Edge("T1", "TG1", labels["next"]),
        Edge("P0", "PG", labels["built_p"]),
        Edge("PG", "P1", labels["inc_p"]),
        Edge("P1", "PN", labels["new"]),
        Edge("PN", "PC", "position_evaluated_P"),
        Edge("P1", "PG1", labels["next"]),
        Edge("T0", "P0", "φ", "#315d80", True),
        Edge("T1", "P1", labels["commute"], "#315d80", True),
        Edge("TN", "PN", "positionMap: new_T ↦ new_P", "#315d80", True),
    ]
    return diagram


def unification_diagram(english: bool) -> Diagram:
    if english:
        title = "Universal gap-mediated causal unification"
        texts = {
            "syn": "COMMON SYNTACTIC LAYER\nSentence · Predicate · diagonal\nno evaluation",
            "k": "K — INTENDED INTRINSIC FREE OBJECT\nroot · step · Position\nEmpty at the root · Option at the successor\nno sentence · no evaluator",
            "orbit": "GapOrbit⁺ — PROVENANCE STRUCTURE\npointed positive orbits\nmorphisms preserving root · advance · new · old\npointwise equivalence · no quotient or funext",
            "univ": "CANDIDATE UNIVERSAL PROPERTY\nfor every orbit R: a unique morphism K → R\npointwise uniqueness\nnot yet proved",
            "kt": "K_T⁺ — TARSKIAN SKELETON\nstate · advance · positions\nnew_T / old_T",
            "kp": "K_P⁺ — PROVABILITY SKELETON\ncertified history · advance · positions\nnew_P / old_P",
            "dt": "D_T — SYNTACTIC DECORATION\ndiagonal gap · patch\nlabel_T",
            "dp": "D_P — SYNTACTIC DECORATION\nRosser sentence · extension\nlabel_P",
            "et": "ℰ_T — LOCAL EVALUATION\nCorrectAt · models · truthAt\nfrontier_open · position_evaluated",
            "ep": "ℰ_P — LOCAL EVALUATION\nTheoryProvable · derivations · consistency\nfrontier_open · position_evaluated",
            "nosem": "NO SEMANTIC UNIFICATION\nEvaluated_T ↛ Evaluated_P\nEvaluated_P ↛ Evaluated_T",
            "span": "INTENDED CANONICAL SPAN\nT ← K → P\nF = r_P ∘ r_T⁻¹ only on the generated orbits",
            "local_syntax": "local syntax",
            "candidate": "candidate initiality",
            "derived": "F derived on generated orbits",
            "decoration": "local decoration",
            "mediates": "the gap mediates evaluation",
        }
    else:
        title = "Unification causale universelle médiatisée par le gap"
        texts = {
            "syn": "COUCHE SYNTAXIQUE COMMUNE\nSentence · Predicate · diagonal\naucune évaluation",
            "k": "K — OBJET LIBRE INTRINSÈQUE VISÉ\nroot · step · Position\nEmpty à la racine · Option au successeur\naucune phrase · aucun évaluateur",
            "orbit": "GapOrbit⁺ — STRUCTURE DE PROVENANCE\norbites positives pointées\nmorphismes préservant root · advance · new · old\néquivalence pointwise · sans quotient ni funext",
            "univ": "PROPRIÉTÉ UNIVERSELLE CANDIDATE\npour toute orbite R : unique morphisme K → R\nunicité point par point\nnon encore démontrée",
            "kt": "K_T⁺ — SQUELETTE TARSKIEN\nétat · advance · positions\nnew_T / old_T",
            "kp": "K_P⁺ — SQUELETTE DE PROUVABILITÉ\nhistoire certifiée · advance · positions\nnew_P / old_P",
            "dt": "D_T — DÉCORATION SYNTAXIQUE\ngap diagonal · patch\nlabel_T",
            "dp": "D_P — DÉCORATION SYNTAXIQUE\nphrase de Rosser · extension\nlabel_P",
            "et": "ℰ_T — ÉVALUATION LOCALE\nCorrectAt · models · truthAt\nfrontier_open · position_evaluated",
            "ep": "ℰ_P — ÉVALUATION LOCALE\nTheoryProvable · dérivations · cohérence\nfrontier_open · position_evaluated",
            "nosem": "AUCUNE UNIFICATION SÉMANTIQUE\nEvaluated_T ↛ Evaluated_P\nEvaluated_P ↛ Evaluated_T",
            "span": "SPAN CANONIQUE VISÉ\nT ← K → P\nF = r_P ∘ r_T⁻¹ seulement sur les orbites engendrées",
            "local_syntax": "syntaxe locale",
            "candidate": "initialité candidate",
            "derived": "F dérivé sur les orbites engendrées",
            "decoration": "décoration locale",
            "mediates": "le gap médiatise l’évaluation",
        }

    diagram = Diagram(1600, 1200, title)
    diagram.nodes = [
        Node("SYN", 280, 125, 390, 105, texts["syn"], "#f4f4f4", "#4d4d4d"),
        Node("K", 800, 160, 440, 135, texts["k"], "#eaf3ff", "#245a8d", False, 14),
        Node("GO", 1320, 150, 450, 135, texts["orbit"], "#eef7f7", "#276b6b", False, 13),
        Node("UV", 1320, 280, 430, 110, texts["univ"], "#fafafa", "#777777", True, 13),
        Node("KT", 390, 410, 390, 110, texts["kt"], "#edf8ef", "#34743c"),
        Node("KP", 1070, 410, 410, 110, texts["kp"], "#edf8ef", "#34743c"),
        Node("DT", 390, 620, 360, 105, texts["dt"], "#fff8e5", "#886500"),
        Node("DP", 1070, 620, 370, 105, texts["dp"], "#fff8e5", "#886500"),
        Node("ET", 310, 850, 430, 120, texts["et"], "#f5f0fb", "#6c4a8c"),
        Node("EP", 1190, 850, 440, 120, texts["ep"], "#f5f0fb", "#6c4a8c"),
        Node("NS", 750, 850, 330, 105, texts["nosem"], "#fff0f0", "#9a3434", True, 13),
        Node("SPAN", 800, 1080, 520, 105, texts["span"], "#eaf3ff", "#245a8d", False, 14),
    ]
    diagram.edges = [
        Edge("SYN", "DT", texts["local_syntax"]),
        Edge("SYN", "DP", texts["local_syntax"]),
        Edge("K", "GO", "", "#276b6b", True),
        Edge("GO", "UV", "", "#777777", True),
        Edge("K", "KT", "r_T", "#245a8d", False, False, 2.1),
        Edge("K", "KP", "r_P", "#245a8d", False, False, 2.1),
        Edge("KT", "KP", texts["derived"], "#315d80", True, True),
        Edge("KT", "DT", texts["decoration"]),
        Edge("KP", "DP", texts["decoration"]),
        Edge("DT", "ET", texts["mediates"]),
        Edge("DP", "EP", texts["mediates"]),
        Edge("ET", "NS", "", "#9a3434", True),
        Edge("EP", "NS", "", "#9a3434", True),
        Edge("K", "SPAN", "", "#245a8d", False, False, 1.8),
    ]
    return diagram


def write(diagram: Diagram, stem: str) -> None:
    render_svg(diagram, ROOT / f"{stem}.svg")
    render_png(diagram, ROOT / f"{stem}.png")


def main() -> None:
    write(improved_diagram(False), "SyntaxSemanticGapCausalDiagram_ameliore")
    write(improved_diagram(True), "SyntaxSemanticGapCausalDiagram_improved_en")
    write(unification_diagram(False), "SyntaxSemanticGapCausalDiagram_unification")
    write(unification_diagram(True), "SyntaxSemanticGapCausalDiagram_unification_en")


if __name__ == "__main__":
    main()
