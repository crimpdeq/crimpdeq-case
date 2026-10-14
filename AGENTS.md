# Agent Instructions

## Design source of truth

- Units are millimetres. Put physical envelopes and tunable clearances in `case/dimensions.scad`; put derived assembly coordinates in `case/placement.scad`.
- Do not duplicate component offsets in `case_main.scad`, `case_lid.scad`, `assembly.scad`, or `collision_check.scad`.

## Enclosure invariants

- Keep the electronics bay closed: the main-body and lid slot walls must isolate both carabiner slots from the bay.
- Keep the plan a hexagon symmetric about both axes: flat front and rear walls and a point at each end.
- Keep both load-cell eyes accessible through isolated vertical U-slots that open through each case end, with `eye_slot_clear` around each eye; the inboard edge stops at the battery bay wall. A 12 mm carabiner shank must fit centered in the 15 mm eye-ring bore and bearing on its outer side.
- The facets must enclose all four load-cell corners and clear the load cell, while all four edge notches remain retained.
- The USB-C connector must remain accessible through an aligned wall opening with enough clearance to insert a charging cable.
- Both the battery-status LED and RGB LED must remain visible through separate, aligned lid holes.
- Keep each `Crimpdeq` title centered on its intended enclosure face.
- The KCD11 switch must remain accessible through an aligned wall opening, with clearance from the USB-C opening.
- Fasteners are M2.5×10. Keep screw centers aligned between main and lid, clear of the battery, and with pilot holes deeper than the seated screw.
- Case supports and lid clamps may touch the PCB only inside the bare-board windows in `case/dimensions.scad`; re-derive the windows, cable-pad clearances, component positions and PCB stack heights from the KiCad board in `crimpdeq-pcb` whenever the PCB changes. The board is flipped about the X axis, so a KiCad offset (dx, dy) from the board center is case-local (dx, dy); never mirror X.
- Nothing in the main body may hang over the battery: PCB supports stand on the floor in front of it, and the battery and board must drop in from above.
- Keep wire routes from the switch, the battery's rear leads and the load-cell strain gauge to the cable pads open, checked with realistic bundle sizes, and leave room under every cable pad for its solder joint. Keep the switch wire bend zone between the switch's solder joints and the load cell and battery. The battery must clear the strain-gauge cover; re-measure `gauge_cover_*` and `switch_depth` if those parts change.
- Keep internal supports chunky and fused to the floor or walls; no free-standing slender pillars.
- Preserve `print_layout=true`: main floor at Z=0; lid outer face on the bed.

## Validation

- Run the full check after substantive geometry or clearance changes:
  `CHECK_JOBS=4 OPENSCAD_RENDER_FN=24 bash scripts/check-collisions.sh`
- Use a timeout of 550 seconds for that command.
- A deliberately empty OpenSCAD intersection exits non-zero; let `scripts/check-collisions.sh` interpret it. It runs OpenSCAD with `--hardwarnings`, because a warning can silently drop a probe and fake an empty result.
- Add collision modes in both `case/collision_check.scad` and `scripts/check-collisions.sh` when introducing a new fit invariant.
- Both exported STLs must contain exactly one connected component.
- Keep `scripts/check-collisions.sh` compatible with macOS Bash 3.2; do not use `wait -n`.
