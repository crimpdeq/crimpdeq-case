#!/usr/bin/env python3
"""Build the ready-to-print Bambu Studio project for the case.

Exports both parts in print layout, places them on one plate, lets the Bambu
Studio CLI assemble the project with the print settings below, and slices it
to confirm that the plate is printable.

Usage: python3 scripts/export-bambu-project.py [--output FILE.3mf] [--skip-slice]
BAMBU_STUDIO names the Bambu Studio executable (default: bambu-studio on PATH,
then the macOS application); BAMBU_STUDIO_PROFILES its profiles directory.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MACOS_APP = Path("/Applications/BambuStudio.app/Contents/MacOS/BambuStudio")

PRINTER = "Bambu Lab A1 0.4 nozzle"
PROCESS = "0.20mm Standard @BBL A1"
FILAMENT = "Generic PLA @BBL A1"
PROJECT_PROCESS = "Crimpdeq case @BBL A1"
BED_TYPE = "Textured PEI Plate"
PLATE_NAME = "Main body and lid"

PROCESS_OVERRIDES = {
    "layer_height": "0.2",
    # Six loops fill the 2.4 mm shell with perimeters.
    "wall_loops": "6",
    # Six top and six bottom layers make the 2.4 mm floor and lid solid.
    "top_shell_layers": "6",
    "bottom_shell_layers": "6",
    "sparse_infill_density": "20%",
    # The PCB side rails, rear stops and rear pads hang about 10 mm above the
    # main-body floor. Tree supports grow from the floor and come out through
    # the open top; nothing else needs them.
    "enable_support": "1",
    "support_type": "tree(auto)",
    "support_on_build_plate_only": "0",
    # Skip bridges and small overhangs: the USB-C and switch openings, the
    # screw-head recesses and the engraved letters.
    "support_critical_regions_only": "1",
    "bridge_no_support": "1",
    "support_remove_small_overhang": "1",
    "brim_type": "no_brim",
}

# Parts in print layout, side by side along Y, with per-object settings.
# Every lid feature grows up from its outer face; support would only fill the
# screw-head recesses.
PARTS = {
    "case_main": {},
    "case_lid": {"enable_support": "0"},
}
PART_GAP = 15.0


def find_bambu_studio() -> Path:
    candidate = os.environ.get("BAMBU_STUDIO") or shutil.which("bambu-studio")
    if candidate:
        return Path(candidate)
    if MACOS_APP.exists():
        return MACOS_APP
    sys.exit("Bambu Studio not found: set BAMBU_STUDIO or put bambu-studio on PATH")


def find_profiles(bambu_studio: Path) -> Path:
    if os.environ.get("BAMBU_STUDIO_PROFILES"):
        return Path(os.environ["BAMBU_STUDIO_PROFILES"])
    exe_dir = bambu_studio.resolve().parent
    # macOS bundle, extracted AppImage, installed package.
    for candidate in (
        exe_dir.parent / "Resources" / "profiles",
        exe_dir / "resources" / "profiles",
        exe_dir.parent / "resources" / "profiles",
        exe_dir.parent / "share" / "BambuStudio" / "profiles",
    ):
        if (candidate / "BBL").is_dir():
            return candidate
    sys.exit(f"Bambu Studio profiles not found near {bambu_studio}: set BAMBU_STUDIO_PROFILES")


class Presets:
    """Bambu Lab system presets, flattened along their `inherits` chains."""

    def __init__(self, profiles: Path):
        self.by_name: dict[tuple[str, str], dict] = {}
        for kind in ("machine", "process", "filament"):
            for path in (profiles / "BBL" / kind).rglob("*.json"):
                try:
                    preset = json.loads(path.read_text(encoding="utf-8"))
                except (json.JSONDecodeError, UnicodeDecodeError):
                    continue
                if isinstance(preset, dict) and "name" in preset:
                    self.by_name[(kind, preset["name"])] = preset

    def flattened(self, kind: str, name: str) -> dict:
        preset = self.by_name.get((kind, name))
        if preset is None:
            sys.exit(f"Bambu Studio has no {kind} preset named {name!r}")
        parent = preset.get("inherits")
        resolved = self.flattened(kind, parent) if parent else {}
        resolved.update(preset)
        resolved.pop("inherits", None)
        return resolved


def write_settings(presets: Presets, work: Path) -> tuple[Path, Path, Path]:
    process = presets.flattened("process", PROCESS)
    for key in ("setting_id", "instantiation"):
        process.pop(key, None)
    # A project preset on top of the system process, so Bambu Studio lists
    # the changed settings against it.
    process.update(PROCESS_OVERRIDES)
    process.update({"name": PROJECT_PROCESS, "inherits": PROCESS, "from": "User"})

    paths = []
    for kind, preset in (
        ("machine", presets.flattened("machine", PRINTER)),
        ("process", process),
        ("filament", presets.flattened("filament", FILAMENT)),
    ):
        path = work / f"{kind}.json"
        path.write_text(json.dumps(preset, indent=4), encoding="utf-8")
        paths.append(path)
    return paths[0], paths[1], paths[2]


def list_changed_settings(project: Path, presets: Presets) -> None:
    """Record the process overrides in the project's different_settings_to_system.

    When Bambu Studio opens a project whose preset inherits a system preset,
    it keeps only the settings listed there and resets the rest to the system
    values. The CLI leaves the list empty, which would drop every override.
    """
    system = presets.flattened("process", PROCESS)
    changed = sorted(key for key, value in PROCESS_OVERRIDES.items()
                     if system.get(key) not in (value, [value]))
    name = "Metadata/project_settings.config"
    with zipfile.ZipFile(project) as archive:
        entries = [(info, archive.read(info)) for info in archive.infolist()]
    with zipfile.ZipFile(project, "w") as archive:
        for info, data in entries:
            if info.filename == name:
                settings = json.loads(data)
                missing = [key for key in changed if settings.get(key) != PROCESS_OVERRIDES[key]]
                if missing:
                    sys.exit(f"Bambu Studio did not keep the process overrides: {missing}")
                # Process first, then the filament and printer presets.
                settings["different_settings_to_system"][0] = ";".join(changed)
                data = json.dumps(settings, indent=4).encode("utf-8")
            archive.writestr(info, data)


def bed_size(presets: Presets) -> tuple[float, float]:
    corners = [
        tuple(float(v) for v in corner.split("x"))
        for corner in presets.flattened("machine", PRINTER)["printable_area"]
    ]
    return max(x for x, _ in corners), max(y for _, y in corners)


VERTEX = re.compile(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)")


def export_part(part: str, out: Path) -> list[tuple[float, float, float]]:
    subprocess.run(
        ["openscad", "-D", "print_layout=true", "-o", str(out),
         str(REPO_ROOT / "case" / f"{part}.scad")],
        check=True, capture_output=True,
    )
    return [tuple(map(float, m.groups())) for m in VERTEX.finditer(out.read_text())]


def translate_stl(path: Path, dx: float, dy: float) -> None:
    def shift(m: re.Match) -> str:
        x, y, z = map(float, m.groups())
        return f"vertex {x + dx:.6f} {y + dy:.6f} {z:.6f}"
    path.write_text(VERTEX.sub(shift, path.read_text()))


def place_parts(stl_dir: Path, bed: tuple[float, float]) -> dict[str, Path]:
    """Export the parts and center them on the bed, side by side along Y."""
    stl_dir.mkdir(parents=True)
    paths, boxes = {}, {}
    for part in PARTS:
        paths[part] = stl_dir / f"{part}.stl"
        points = export_part(part, paths[part])
        lo = [min(p[i] for p in points) for i in range(3)]
        hi = [max(p[i] for p in points) for i in range(3)]
        if abs(lo[2]) > 1e-3:
            sys.exit(f"{part} does not rest on the bed (Z min {lo[2]:.3f})")
        boxes[part] = (lo, hi)

    depth = sum(hi[1] - lo[1] for lo, hi in boxes.values()) + PART_GAP * (len(PARTS) - 1)
    y = (bed[1] - depth) / 2
    for part in PARTS:
        lo, hi = boxes[part]
        width = hi[0] - lo[0]
        if width > bed[0] or depth > bed[1]:
            sys.exit(f"The parts do not fit the {bed[0]:g} x {bed[1]:g} mm bed")
        translate_stl(paths[part], (bed[0] - width) / 2 - lo[0], y - lo[1])
        print(f"{part}: {width:.1f} x {hi[1] - lo[1]:.1f} x {hi[2]:.1f} mm")
        y += hi[1] - lo[1] + PART_GAP
    return paths


def run_bambu(bambu_studio: Path, args: list[str], out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(
        [str(bambu_studio), "--debug", "1", *args, "--outputdir", str(out_dir)],
        cwd=out_dir, capture_output=True, text=True,
    )
    # At --debug 1 Bambu Studio logs only errors, such as skipped thumbnails.
    sys.stdout.write(proc.stdout[-8000:])
    sys.stderr.write(proc.stderr[-8000:])
    result_path = out_dir / "result.json"
    result = json.loads(result_path.read_text()) if result_path.exists() else {}
    if proc.returncode != 0 or result.get("return_code", 0) != 0:
        sys.exit(f"Bambu Studio failed ({proc.returncode}): {result.get('error_string', 'no result')}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--output", type=Path,
                        default=REPO_ROOT / "exports" / "crimpdeq-case.3mf")
    parser.add_argument("--skip-slice", action="store_true",
                        help="don't slice the project to check it")
    args = parser.parse_args()

    bambu_studio = find_bambu_studio()
    presets = Presets(find_profiles(bambu_studio))

    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp)
        stl_paths = place_parts(work / "stl", bed_size(presets))
        machine, process, filament = write_settings(presets, work)
        assemble_list = {
            "plates": [{
                "plate_name": PLATE_NAME,
                "need_arrange": False,
                "plate_params": {"curr_bed_type": BED_TYPE},
                "objects": [
                    {"path": str(stl_paths[part]), "count": 1, "filaments": [1],
                     "print_params": params}
                    for part, params in PARTS.items()
                ],
            }]
        }
        assemble_path = work / "assemble.json"
        assemble_path.write_text(json.dumps(assemble_list, indent=4), encoding="utf-8")

        project = work / "project" / args.output.name
        run_bambu(bambu_studio, [
            "--load-settings", f"{machine};{process}",
            "--load-filaments", str(filament),
            "--load-assemble-list", str(assemble_path),
            "--export-3mf", project.name,
        ], project.parent)
        list_changed_settings(project, presets)
        if not args.skip_slice:
            run_bambu(bambu_studio, ["--slice", "0", str(project)], work / "slice")
            print("Sliced the plate without errors")

        args.output.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(project, args.output)
    print(f"Exported {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
