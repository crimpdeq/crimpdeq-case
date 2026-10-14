# Crimpdeq 3D Case

OpenSCAD source files for the Crimpdeq 3D-printable enclosure (main body + lid), including assembly models and collision checks used in CI.

![Crimpdeq 3D Case](assets/case.jpg)

The enclosure is approximately 97.1 × 72.4 × 29.1 mm with a symmetric
hexagonal plan: flat front and rear walls, a point at each end, and 120°
interior angles. The facets are the tightest lines that still enclose all four
corners of the 80 mm load cell. Each eye stays reachable through an isolated
vertical U-slot that runs out through the case point, with 2.5 mm of clearance
around the eye; on its inboard side the slot stops at the battery bay wall. A
loaded carabiner bears on the metal eye ring rather than the plastic, and its
curve can leave the case.

The PCB is modelled with its real stack from the KiCad board: underside parts
over the battery, the USB-C connector hanging in front of it, and the ESP32
module and both LEDs facing the lid. Three floor-anchored columns in front of
the battery carry the board at bare areas taken from the KiCad courtyards,
clear of the cable pads, and the outer two guide its side edges. Lid clamps
directly above them press the board with a one-layer (0.1 mm) preload, so it
cannot rattle. Chamfered lid tabs behind the board's rear edge take USB-C
insertion loads and push a board that slid back forward as the lid closes.
Nothing hangs over the battery,
so the battery drops straight in and the board only tilts to seat its USB-C
connector, which reaches into the front wall. A 13.65 × 7.8 mm pocket around it
lets a cable's molded overmold (up to the 12.85 × 7.0 mm maximum in the USB
Type-C plug dimensions update) reach within 0.3 mm of the receptacle face, so
standard cables seat fully.

The repository contains:

- Parametric OpenSCAD models for the enclosure under `case/`
- Component envelope models (PCB, battery, load cell)
- Collision/fit validation script (`scripts/check-collisions.sh`)
- GitHub Actions workflows that build STL artifacts and release assets

Prebuilt STL files are published in [GitHub Releases](https://github.com/crimpdeq/crimpdeq-case/releases) for tagged versions.

## Components

- [Crimpdeq PCB revision 3](https://github.com/crimpdeq/crimpdeq-pcb/pull/23), installed bottom-side up with its USB-C edge toward the front wall, so both LEDs face the lid
- [2000mAh battery](https://www.aliexpress.us/item/3256809404408618.html?spm=a2g0o.order_list.order_list_main.5.1406194d6kJ2h0&gatewayAdapt=glo2usa4itemAdapt)
- [KCD11 switch](https://www.aliexpress.us/item/2255800787248498.html?spm=a2g0o.order_list.order_list_main.11.1406194d6kJ2h0&gatewayAdapt=glo2usa4itemAdapt)
- Load cell from this [hanging scale](https://www.aliexpress.us/item/3256802533330674.html?spm=a2g0o.order_list.order_list_main.35.1406194d6kJ2h0&gatewayAdapt=glo2usa4itemAdapt)

## Requirements

- `openscad` (CLI and/or GUI)
- `bash`
- Optional for headless Linux runs: `xvfb-run` (the collision script uses it automatically when no `DISPLAY` is available)

## Quick Start

### Preview in OpenSCAD (GUI)

Open the main files directly:

```bash
openscad case/case_main.scad
openscad case/case_lid.scad
openscad case/assembly.scad
```

### Export STL files (CLI)

```bash
openscad -o case/case_main.stl case/case_main.scad
openscad -o case/case_lid.stl case/case_lid.scad
```

By default, both files export in assembly orientation:
- `case_main.scad`: main body in assembled orientation
- `case_lid.scad`: lid in assembled orientation

To export in print layout instead:

```bash
openscad -D 'print_layout=true' -o /tmp/case_main_print_layout.stl case/case_main.scad
openscad -D 'print_layout=true' -o /tmp/case_lid_print_layout.stl case/case_lid.scad
```

Print layout places:
- `case_main.scad`: upright with the floor on the build plate (`Z=0`)
- `case_lid.scad`: flipped so the outer top face is on the build plate (support-free)
- The main body needs support only under its battery-front props; see the Bambu Studio project below

### Build the Bambu Studio project

```bash
python3 scripts/export-bambu-project.py
```

This writes `exports/crimpdeq-case.3mf` (gitignored): both parts in print
layout on one plate, set up for a Bambu Lab A1 with a 0.4 mm nozzle, Generic
PLA and the textured PEI plate. The script slices the plate to confirm it is
printable. If `bambu-studio` on `PATH` is a wrapper script, point
`BAMBU_STUDIO` at the real executable, for example
`BAMBU_STUDIO=/opt/bambustudio-bin/AppRun` on Arch.

| Setting | Value |
|---|---|
| Layer height | 0.2 mm |
| Walls | 6 (solid 2.4 mm shell) |
| Top/bottom layers | 6 (solid floor and lid) |
| Infill | 20% |
| Supports | Tree (auto), critical regions only, no bridge support; off for the lid |
| Brim | None |

Only the main body needs support, under the battery-front props. They hang
over the load-cell space, which is empty while printing. Remove the supports
through the open top. The PCB columns stand on the floor and need none.

### Run collision checks

This validates expected contacts/clearances between the enclosure parts and the internal components, including load-cell end clearance, load-cell corner coverage, loaded and tilted carabiner clearance, vertical drop-in paths for the battery and PCB, PCB support columns and edge guides, lid clamp preload, lid rear stops, screw pilot depth, a fully mated USB-C cable with its overmold seated in the front-wall pocket, and separate lid view holes for the battery-status and RGB LEDs.

```bash
bash scripts/check-collisions.sh
```

Useful overrides for faster/local runs:

```bash
CHECK_JOBS=4 OPENSCAD_RENDER_FN=24 bash scripts/check-collisions.sh
```

- `CHECK_JOBS`: number of OpenSCAD checks to run in parallel (defaults to up to 4 cores)
- `OPENSCAD_RENDER_FN`: tessellation used by collision checks only (defaults to `24`)

## Project Structure

- `case/case_main.scad`: main enclosure body
- `case/case_lid.scad`: lid
- `case/assembly.scad`: combined internal assembly preview (load cell, battery, PCB, switch)
- `case/collision_check.scad`: geometry intersections used for automated collision checks
- `case/dimensions.scad`: shared dimensions and clearances
- `scripts/check-collisions.sh`: CI/local collision validation script
- `scripts/export-bambu-project.py`: Bambu Studio project with the print settings

## CI and Releases

- `.github/workflows/cad_ci.yml`
  - Runs collision checks
  - Builds `case_main.stl` and `case_lid.stl`
  - Uploads STL artifacts for CI runs
- `.github/workflows/release.yml`
  - Builds release STL files when a GitHub Release is created
  - Uploads the generated STL files to the release assets

## License

This repository is source-available for personal and educational use only.

Commercial manufacture, sale of PCBs, sale of 3D-printed cases, kits, or assembled Crimpdeq devices requires prior written permission.
