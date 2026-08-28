# Agent Instructions

## Design source of truth

- Units are millimetres. Put physical envelopes and tunable clearances in `case/dimensions.scad`; put derived assembly coordinates in `case/placement.scad`.
- Do not duplicate component offsets in `case_main.scad`, `case_lid.scad`, `assembly.scad`, or `collision_check.scad`.

## Enclosure invariants

- Keep the electronics bay closed: the main body's top-loading load-cell channels must be closed by the lid skirts.
- Keep both load-cell eyes accessible through isolated vertical tunnels. The openings must let the carabiner body and gate pass through, not only the 12 mm shank; preserve the eye-sized vertical path and 30 mm lateral entry.
- Keep the vertical load-cell corner/end walls in the main body; the lid should provide only the matching roof caps and upper eye-tunnel isolation.
- The load-cell ends must clear both side walls, while all four edge notches remain retained.
- The USB-C connector must remain accessible through an aligned wall opening with enough clearance to insert a charging cable.
- Both the battery-status LED and RGB LED must remain visible through separate, aligned lid holes.
- Keep each `Crimpdeq` title centered on its intended enclosure face.
- The rear-wall K139b600-G8 slide switch must remain captured by its snap cradle and accessible through its recessed opening. Keep its closely trimmed terminals clear of the load cell.
- Fasteners are M2.5×10. Keep screw centers aligned between main and lid on the four load-cell notch axes and clear of the battery.
- Preserve `print_layout=true`: main floor at Z=0; lid outer face on the bed.

## Validation

- Run the full check after substantive geometry or clearance changes:
  `CHECK_JOBS=4 OPENSCAD_RENDER_FN=24 bash scripts/check-collisions.sh`
- Use a timeout of 550 seconds for that command.
- Let `scripts/check-collisions.sh` interpret deliberately empty and boundary-only OpenSCAD intersections.
- Add collision modes in both `case/collision_check.scad` and `scripts/check-collisions.sh` when introducing a new fit invariant.
- Both exported STLs must contain exactly one connected component.
- Keep `scripts/check-collisions.sh` compatible with macOS Bash 3.2; do not use `wait -n`.
