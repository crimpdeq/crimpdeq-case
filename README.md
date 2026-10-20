# Crimpdeq 3D Case

OpenSCAD source files for the Crimpdeq 3D-printable enclosure (main body + lid), including assembly models and collision checks used in CI.

![Crimpdeq V3 cases](assets/case_v3.jpg)

*V3 case*

![Crimpdeq V1 and V2 case](assets/case.jpg)

*V1 and V2 case*

## Print the case

Download `case_main.stl` and `case_lid.stl` from the release that matches your PCB revision
(see [Compatibility](#compatibility)). Releases up to `v3.1.0` ship the STLs in assembly
orientation, so lay the lid on its outer face before slicing; later releases ship them in print
layout. From `v3.1.0`, releases also include `crimpdeq-case.3mf`, a Bambu Studio project with
both parts laid out and the [print settings](#build-the-bambu-studio-project) applied. The V3
parts need no support.

To assemble the case, follow the [Crimpdeq book](https://book.crimpdeq.com/assembly/crimpdeq/index.html).

## Compatibility

Use the case release in the row for your PCB revision. From V2 on, the case and PCB share the
major version; PCB V1 uses case `v0.4.0`.

| Case                                                                      | PCB                                                                    |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [`v3.1.0`](https://github.com/crimpdeq/crimpdeq-case/releases/tag/v3.1.0) | V3 ([`v3.0.0`](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v3.0.0)) |
| [`v2.0.0`](https://github.com/crimpdeq/crimpdeq-case/releases/tag/v2.0.0) | V2 ([`v2.0.0`](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v2.0.0)) |
| [`v0.4.0`](https://github.com/crimpdeq/crimpdeq-case/releases/tag/v0.4.0) | V1 ([`v1.0.1`](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v1.0.1)) |

## Components

- [Crimpdeq PCB V3](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v3.0.0)
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

## License

This repository is source-available for personal and educational use only.

Commercial manufacture, sale of PCBs, sale of 3D-printed cases, kits, or assembled Crimpdeq devices requires prior written permission.
