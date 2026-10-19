# Crimpdeq 3D Case

OpenSCAD source files for the Crimpdeq 3D-printable enclosure (main body + lid), including assembly models and collision checks used in CI.

![Crimpdeq 3D Case](assets/case.jpg)

## Print the case

Download `case_main.stl`, `case_lid.stl`, and the Bambu Studio project `crimpdeq-case.3mf`
from the [latest release](https://github.com/crimpdeq/crimpdeq-case/releases/latest). The STLs
are in print layout: the main body stands on its floor and the lid lies on its outer face.
Neither part needs support. See [Build the Bambu Studio project](#build-the-bambu-studio-project)
for the print settings.

Fasten the lid with 4 × M2.5×10 screws. The [Crimpdeq book](https://book.crimpdeq.com/assembly/crimpdeq/index.html)
covers the full assembly.

## Compatibility

Use the case release in the row for your PCB revision. From V2 on, the case and PCB share the
major version; PCB V1 uses case `v0.4.0`.

| Case                                                                      | PCB                                                                    |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [`v3.1.0`](https://github.com/crimpdeq/crimpdeq-case/releases/tag/v3.1.0) | V3 ([`v3.0.0`](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v3.0.0)) |
| [`v2.0.0`](https://github.com/crimpdeq/crimpdeq-case/releases/tag/v2.0.0) | V2 ([`v2.0.0`](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v2.0.0)) |
| [`v0.4.0`](https://github.com/crimpdeq/crimpdeq-case/releases/tag/v0.4.0) | V1 ([`v1.0.1`](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v1.0.1)) |

## Components

- [Crimpdeq PCB V3](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v3.0.0), installed bottom-side up with its USB-C edge toward the front wall, so both LEDs face the lid
- [2000mAh battery](https://www.aliexpress.us/item/3256809404408618.html)
- [KCD11 switch](https://www.aliexpress.us/item/2255800787248498.html)
- Load cell from this [crane scale](https://www.aliexpress.com/item/1005002719645426.html)

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
- Neither part needs support

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
| Supports | None |
| Brim | None |

### Run collision checks

This validates expected contacts/clearances between the enclosure parts and the internal components, including load-cell end clearance, load-cell corner coverage, loaded and tilted carabiner clearance, vertical drop-in paths for the load cell, battery and PCB, lid clearance over a load cell resting 0.5 mm high, a lid that seats anywhere within its screw play, no straight path from the carabiner slots into the bay, PCB support columns and edge guides, lid clamp preload, lid rear stops, battery hold-down preload and alignment over its pads, the switch opening's grip length, switch, battery and load-cell wire routes to the cable pads, screw pilot depth, a fully mated USB-C cable with its overmold seated in the front-wall pocket, and separate lid view holes for the battery-status and RGB LEDs.

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
  - Builds the release STL files in print layout and `crimpdeq-case.3mf` when a GitHub Release is created
  - Uploads them to the release assets

## Design

The enclosure is approximately 97.1 × 77.4 × 30.6 mm with a symmetric
hexagonal plan: flat front and rear walls, a point at each end, and 120°
interior angles. The facets are the tightest lines that still enclose all four
corners of the 80 mm load cell. Each eye stays reachable through an isolated
vertical U-slot that runs out through the case point, with 2.5 mm of clearance
around the eye; on its inboard side the slot stops at the battery bay wall. A
loaded carabiner bears on the metal eye ring rather than the plastic, and its
curve can leave the case.

The PCB is modelled with its real stack from the KiCad board: underside parts
over the battery, the USB-C connector hanging in front of it, and the ESP32
module and both LEDs facing the lid. Two floor-anchored columns in front of
the battery carry the board at bare areas taken from the KiCad courtyards,
clear of the cable pads. The left one guides the board's left edge; the right
one, fused to the front wall, stops it moving right through the USB-C shell's
through-hole legs. Lid clamps directly above the columns press the board with
a one-layer (0.1 mm) preload, so it cannot rattle. Chamfered lid tabs behind
the board's rear edge take USB-C insertion loads and push a board that slid
back forward as the lid closes. The left column and a low rib in front of
the battery's front-right corner stop the battery.

The front of the case leaves room for every wire, checked with realistic
bundle sizes:

- The KCD11 switch is 15.2 mm deep up to the end of its heat-shrunk solder
  joints. A 3.5 mm zone behind it lets its wires turn up before the battery
  and load cell; they run right over the battery-front rib and forward to the
  SW+ and SW- pads.
- The battery leads leave its rear end, rise behind it and run forward over
  its right edge, beside the board, to the B- and B+ pads.
- The load cell goes in with its strain-gauge cover facing the battery and
  its wires toward the front. The wires run left under the battery, forward
  outside the left column and under the board to the front-edge pads. Pads
  behind the load cell hold the battery's rear 0.5 mm above the 2.5 mm
  cover; its front settles onto the cover. Lid hold-downs directly above the
  pads clamp the battery onto them with a one-layer (0.2 mm) preload, so it
  cannot rattle, and the clamp load goes into the floor, not the load cell.

Nothing hangs over the load cell or the battery, so both drop straight in
and lie flat, and the board only tilts to seat its USB-C connector, which
reaches into the front wall. A 13.65 × 7.8 mm pocket around it
lets a cable's molded overmold (up to the 12.85 × 7.0 mm maximum in the USB
Type-C plug dimensions update) reach within 0.3 mm of the receptacle face, so
standard cables seat fully.

Every lid feature over the load cell stops 0.6 mm above it, so a slightly
off-size print cannot hold the lid open. The lid's carabiner slot walls stop
0.6 mm short of the facets, so the screws, not the walls, locate the lid; a
fin on the main body overlaps each wall end, so that gap is a labyrinth
rather than a slit from the slot into the electronics bay. Each screw pilot
has a 0.6 mm countersink that takes the plastic the screw displaces, instead
of letting it curl up between the post and the lid.

## License

This repository is source-available for personal and educational use only.

Commercial manufacture, sale of PCBs, sale of 3D-printed cases, kits, or assembled Crimpdeq devices requires prior written permission.
