# Crimpdeq 3D Case

OpenSCAD source files for the Crimpdeq 3D-printable enclosure (main body + lid), including assembly models and collision checks used in CI.

![Crimpdeq 3D Case](assets/case.jpg)

The repository contains:

- Parametric OpenSCAD models for the enclosure under `case/`
- Component envelope models (PCB, battery, load cell)
- Collision/fit validation script (`scripts/check-collisions.sh`)
- GitHub Actions workflows that build STL artifacts and release assets

Prebuilt STL files are published in [GitHub Releases](https://github.com/crimpdeq/crimpdeq-case/releases) for tagged versions.

## Components

- [Crimpdeq PCB v1.0.0](https://github.com/crimpdeq/crimpdeq-pcb/releases/tag/v1.0.0)
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

### Run collision checks

This validates expected contacts/clearances between the enclosure parts and the internal components.

```bash
bash scripts/check-collisions.sh
```

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
