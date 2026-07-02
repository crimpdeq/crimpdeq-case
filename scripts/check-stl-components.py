#!/usr/bin/env python3
"""Validate that STL files contain one connected triangle component.

This intentionally has no third-party dependencies so it can run in CI anywhere
OpenSCAD artifacts are produced. Vertices are welded by rounded coordinates to
avoid tiny text/binary serialization differences.
"""

from __future__ import annotations

import struct
import sys
from collections import defaultdict, deque
from pathlib import Path

WELD_DECIMALS = 5


def _vertex_key(vertex: tuple[float, float, float]) -> tuple[float, float, float]:
    return tuple(round(coord, WELD_DECIMALS) for coord in vertex)


def _read_ascii_stl(data: bytes) -> list[tuple[tuple[float, float, float], ...]]:
    triangles = []
    current = []

    for raw_line in data.decode("utf-8", errors="ignore").splitlines():
        line = raw_line.strip()
        if not line.startswith("vertex "):
            continue

        parts = line.split()
        if len(parts) != 4:
            raise ValueError(f"invalid STL vertex line: {raw_line!r}")
        current.append(_vertex_key((float(parts[1]), float(parts[2]), float(parts[3]))))
        if len(current) == 3:
            triangles.append(tuple(current))
            current = []

    return triangles


def _read_binary_stl(data: bytes) -> list[tuple[tuple[float, float, float], ...]]:
    if len(data) < 84:
        raise ValueError("binary STL is too short")

    tri_count = struct.unpack_from("<I", data, 80)[0]
    expected_len = 84 + tri_count * 50
    if len(data) < expected_len:
        raise ValueError("binary STL is truncated")

    triangles = []
    offset = 84
    for _ in range(tri_count):
        # normal (3 floats) + vertices (9 floats) + attribute byte count
        values = struct.unpack_from("<12fH", data, offset)
        vertices = values[3:12]
        triangles.append(tuple(
            _vertex_key((vertices[i], vertices[i + 1], vertices[i + 2]))
            for i in range(0, 9, 3)
        ))
        offset += 50

    return triangles


def read_stl(path: Path) -> list[tuple[tuple[float, float, float], ...]]:
    data = path.read_bytes()

    # OpenSCAD writes ASCII STL by default, but support binary for completeness.
    if data[:5].lower() == b"solid" and b"vertex" in data[:4096]:
        return _read_ascii_stl(data)
    return _read_binary_stl(data)


def component_count(triangles: list[tuple[tuple[float, float, float], ...]]) -> int:
    vertex_to_triangles: dict[tuple[float, float, float], list[int]] = defaultdict(list)
    for tri_index, triangle in enumerate(triangles):
        for vertex in triangle:
            vertex_to_triangles[vertex].append(tri_index)

    visited = set()
    components = 0

    for start in range(len(triangles)):
        if start in visited:
            continue

        components += 1
        queue = deque([start])
        visited.add(start)

        while queue:
            tri_index = queue.popleft()
            for vertex in triangles[tri_index]:
                for neighbor in vertex_to_triangles[vertex]:
                    if neighbor not in visited:
                        visited.add(neighbor)
                        queue.append(neighbor)

    return components


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print("usage: check-stl-components.py FILE.stl [...]")
        return 2

    failed = False
    for arg in argv[1:]:
        path = Path(arg)
        triangles = read_stl(path)
        components = component_count(triangles)
        print(f"{path.name}: {len(triangles)} triangles, {components} connected component(s)")

        if not triangles:
            print(f"error: {path} contains no triangles", file=sys.stderr)
            failed = True
        elif components != 1:
            print(f"error: {path} should contain exactly one connected component", file=sys.stderr)
            failed = True

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
