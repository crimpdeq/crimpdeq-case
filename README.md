# Crimpdeq 3D Case

OpenSCAD source files for the Crimpdeq 3D-printable enclosure (main body + lid), including assembly models and collision checks used in CI.

![Crimpdeq 3D Case](assets/case.jpg)

The compact central pod is approximately 50.4 × 53.3 × 24.3 mm. A fitted lid
closes the electronics bay around the 80 mm load cell, while two isolated
vertical tunnels keep both load-cell eyes accessible. Each tunnel opens into a
smoothly flared 30 mm circular mouth so the supplied carabiner gate can pass
through the guard without abrupt shoulders or sharp 90-degree corners.
Rounded end guards wrap all four load-cell corners without obstructing the eyes,
using tangent blends around the four screw/notch locations instead of stepped
90-degree shoulders. Their vertical walls are integrated into the main body;
the lid adds only the matching roof caps and upper eye-tunnel isolation.

The repository contains:

- Parametric OpenSCAD models for the enclosure under `case/`
- Component envelope models (PCB, battery, load cell)
- Collision/fit validation script (`scripts/check-collisions.sh`)
- GitHub Actions workflows that build STL artifacts and release assets

Prebuilt STL files are published in [GitHub Releases](https://github.com/crimpdeq/crimpdeq-case/releases) for tagged versions.

## Components

- [Crimpdeq PCB revision 3](https://github.com/crimpdeq/crimpdeq-pcb/pull/23), installed bottom-side up so both LEDs face the lid
- [Protected 603040 800mAh battery](https://es.aliexpress.com/item/1005010306922880.html) (6 × 30 × 42 mm overall)
- [K139b600-G8 / SS12D10 compact slide switch](https://es.aliexpress.com/item/1005012390864392.html)
- Load cell from this [hanging scale](https://www.aliexpress.us/item/3256802533330674.html?spm=a2g0o.order_list.order_list_main.35.1406194d6kJ2h0&gatewayAdapt=glo2usa4itemAdapt)

The slide switch mounts without hardware against the rear wall: insert its
actuator into the recessed slot, then pivot the body into the printed snap
cradle. Trim its 7.9 mm PCB terminals to a 0.5 mm installed length and solder
the wires upward so they clear the load cell.
For ON/OFF operation, connect the center terminal and either outer terminal.

The battery sits on four floor-anchored edge ledges with 0.5 mm guide
clearance. Compact front PCB columns share the space beyond the battery edge.
These supports stay outside the load-cell channel, so the switch, load cell,
battery, and PCB can all be installed from above before fitting the lid. The
M2.5 posts share the four load-cell notch axes, retaining the cell without
requiring a larger screw-corner envelope.

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

### Run collision checks

This validates expected contacts/clearances between the enclosure parts and the internal components, including compact-switch snap retention, exposed load-cell arm clearance, a USB-C cable plug housing fit check at the offset port opening, and separate lid view holes for the battery-status and RGB LEDs.

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
