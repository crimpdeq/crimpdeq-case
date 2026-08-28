# Crimpdeq 3D Case

OpenSCAD source files for the Crimpdeq 3D-printable enclosure (main body + lid), including assembly models and collision checks used in CI.

![Crimpdeq 3D Case](assets/case.jpg)

The compact central pod is approximately 50.4 × 53.3 × 27.2 mm. A fitted lid
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

Prebuilt, print-oriented STL files are published in
[GitHub Releases](https://github.com/crimpdeq/crimpdeq-case/releases) for tagged versions.

## Components

- [Crimpdeq PCB revision 3](https://github.com/crimpdeq/crimpdeq-pcb/pull/23), installed bottom-side up so both LEDs face the lid
- [Protected 603040 800mAh battery](https://es.aliexpress.com/item/1005010306922880.html) (6 × 30 × 42 mm overall)
- [K139b600-G8 / SS12D10 compact slide switch](https://es.aliexpress.com/item/1005012390864392.html)
- Load cell from this [hanging scale](https://www.aliexpress.us/item/3256802533330674.html?spm=a2g0o.order_list.order_list_main.35.1406194d6kJ2h0&gatewayAdapt=glo2usa4itemAdapt)

The slide switch mounts without hardware against the rear wall: insert its
actuator into the recessed slot, then pivot the body into the printed snap
cradle. Its reinforced continuous rails replace separate fragile rear tabs.
Trim its 7.9 mm PCB terminals to a 0.5 mm installed length and solder
the wires upward so they clear the load cell.
For ON/OFF operation, connect the center terminal and either outer terminal.

The battery sits on four floor-anchored edge ledges with 0.75 mm guide
clearance and is retained entirely by the main body, leaving the lid free of
battery walls that could pinch leads. The conservative square battery envelope
includes its protection-board end and a short lead exit toward the USB side.

The PCB snaps into the lid using three roof pads, one fixed 45-degree side hook,
one short opposite datum, and one accessible flexible rear clip. This removes
the former unsupported main-body PCB shelves. A 2 mm wiring corridor runs inward below the PCB's
case-local -X edge, with 0.5 mm clearance above the battery. The PCB should be
pre-wired with enough slack to snap it into the removed lid before the lid is
lowered onto the enclosure. Two floor-to-wall front reaction ribs and two
lid-mounted rear reaction points bracket the USB connector, limiting axial PCB
travel to 0.35 mm during cable insertion and removal.

The four M2.5 posts remain on the load-cell notch axes, but smaller screw bosses
and tapered clearance pins no longer tightly wedge the stamped notches. Two
diagonal lid stops limit shock movement without preloading the load cell.
The USB-C opening includes a 13 × 7.5 mm recessed pocket for a typical molded
cable boot.

## Assembly

1. Trim, wire, and snap the slide switch into the rear-wall cradle.
2. Lower the load cell over the four tapered notch pins.
3. Install the battery with its protection-board and lead end toward the USB wall.
4. Route insulated wiring inward below the PCB's -X edge; keep it out of the screw axes.
5. Connect the PCB, slide its +X edge under the fixed lid hook, then press its rear edge into the flexible clip.
6. Lower the lid vertically, checking that no leads cross the perimeter or load-cell channels.
7. Install the four M2.5×10 screws gradually in a cross pattern.
8. Attach the carabiners and calibrate only after final assembly.

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

This validates expected contacts and clearances between the enclosure parts and
internal components, including square battery and lead clearance, lid-mounted
PCB support and snap retention, solder/wire service space, relaxed load-cell
notch fit, compact-switch snap retention, exposed load-cell arm clearance,
USB-C shell and molded-boot insertion, and separate lid view holes for both LEDs.

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
  - Builds print-oriented `case_main.stl` and `case_lid.stl`
  - Uploads STL artifacts for CI runs
- `.github/workflows/release.yml`
  - Revalidates and builds print-oriented STL files when a GitHub Release is created
  - Uploads the generated STL files to the release assets

## License

This repository is source-available for personal and educational use only.

Commercial manufacture, sale of PCBs, sale of 3D-printed cases, kits, or assembled Crimpdeq devices requires prior written permission.
