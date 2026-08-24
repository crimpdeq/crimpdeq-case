# Agent Instructions

## Design source of truth

- Units are millimetres. Put physical envelopes and tunable clearances in `case/dimensions.scad`; put derived assembly coordinates in `case/placement.scad`.
- Do not duplicate component offsets in `case_main.scad`, `case_lid.scad`, `assembly.scad`, or `collision_check.scad`.
- The PCB is revision 3 from `crimpdeq/crimpdeq-pcb#23`: 30 × 30 × 5 mm, installed bottom-side up so the status and RGB LEDs face the lid.
- The fixed component envelopes are: load cell 80 × 40 × 4 mm, battery 50 × 34 × 10 mm, and KCD11 switch 15 × 13 × 10 mm.

## Enclosure invariants

- The assembled central pod is approximately 50.4 × 68.8 × 29.8 mm. The battery, switch, notch retention, and rear screw bosses are the practical size limits.
- Keep the electronics bay closed: the main body's top-loading load-cell channels must be closed by the lid skirts.
- Keep both load-cell eyes accessible through isolated vertical tunnels. Current fit assumes a 12 mm carabiner shank and a 13 mm access path.
- The load-cell ends must clear both side walls, while all four edge notches remain retained.
- The USB-C connector must remain accessible through an aligned wall opening with enough clearance to insert a charging cable.
- Both the battery-status LED and RGB LED must remain visible through separate, aligned lid holes.
- Keep each `Crimpdeq` title centered on its intended enclosure face.
- The KCD11 switch must remain accessible through an aligned wall opening, with clearance from the USB-C opening.
- Fasteners are M2.5×10. Keep screw centers aligned between main and lid and clear of the battery.
- Preserve `print_layout=true`: main floor at Z=0; lid outer face on the bed.

## Validation

- Run the full check after substantive geometry or clearance changes:
  `CHECK_JOBS=4 OPENSCAD_RENDER_FN=24 bash scripts/check-collisions.sh`
- Use a timeout of 550 seconds for that command.
- A deliberately empty OpenSCAD intersection exits non-zero; let `scripts/check-collisions.sh` interpret it.
- Add collision modes in both `case/collision_check.scad` and `scripts/check-collisions.sh` when introducing a new fit invariant.
- Both exported STLs must contain exactly one connected component.
- Keep `scripts/check-collisions.sh` compatible with macOS Bash 3.2; do not use `wait -n`.
