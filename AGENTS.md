# Agent Instructions

## Design source of truth

- Units are millimetres. Put physical envelopes and tunable clearances in `case/dimensions.scad`; put derived assembly coordinates in `case/placement.scad`.
- Do not duplicate component offsets in `case_main.scad`, `case_lid.scad`, `assembly.scad`, or `collision_check.scad`.

## Enclosure invariants

- Keep the electronics bay closed: the main-body and lid slot walls must isolate both carabiner slots from the bay; any fit gap between them must be a labyrinth, never a straight slit. The lid slot-wall ends reach into end-wall grooves for that.
- Keep the plan symmetric about both axes, so the top view looks the same from the front and the rear: flat front, rear and end walls with 45 degree chamfers, and the screws mirrored. Derive every wall from the component envelopes in `case/placement.scad`.
- Keep both load-cell eyes accessible through isolated vertical U-slots that open through each case end, with `eye_slot_clear` around each eye; the inboard edge stops at the battery bay wall. A 12 mm carabiner shank must fit centered in the 15 mm eye-ring bore and bearing on its outer side.
- The walls must enclose all four load-cell corners and clear the load cell. Pins in its four edge notches retain it; only its floor pads may touch it.
- The load cell goes in with its strain-gauge cover facing the floor, and the battery lies flat on its bare top face. Nothing may press the battery onto the load cell: the lid hold-downs keep `battery_hold_down_clear` above it.
- The USB-C connector must remain accessible through an aligned wall opening with enough clearance to insert a charging cable; a fully mated cable's overmold must reach within `usb_overmold_stop_gap` of the receptacle face.
- Both the battery-status LED and RGB LED must remain visible through separate, aligned lid holes.
- Keep each `Crimpdeq` title centered on its intended enclosure face.
- The KCD11 switch must remain accessible through an aligned front-wall opening, with clearance from the USB-C pocket, and leave room beside the battery's front-right corner for its leads to bend.
- Fasteners are M2.5×10. Keep screw centers aligned between main and lid, clear of the battery, at least `screw_edge_inset` inside every outer face, and with pilot holes deeper than the seated screw.
- Case supports may touch the PCB only inside the bare bottom-side windows in `case/dimensions.scad`, and the lid only the flat USB-C shell top; re-derive the windows, cable pads, component positions and stack heights from `crimpdeq-tscircuit`'s `circuit.json` whenever the board changes. The board sits top side up and unrotated, so a tscircuit offset (x, y) from the board center is case-local (x, y); never mirror or rotate it.
- Nothing in the main body may hang over the load cell or the battery: PCB supports stand on the floor in front of them, and the load cell, battery and board must drop in from above.
- Keep wire routes from the switch, the battery's corner leads and the load-cell strain gauge to the cable pads open, checked with realistic bundle sizes, and leave room under every cable pad for its solder joint. Keep the switch wire bend zone behind its solder joints, clear of the load cell and battery. Re-measure `gauge_cover_*`, `switch_depth` and the battery if those parts change.
- Keep internal supports chunky and fused to the floor or walls; no free-standing slender pillars.
- The main body prints as assembled, floor at Z=0; `print_layout=true` puts the lid's outer face on the bed.

## Validation

- Run the full check after substantive geometry or clearance changes:
  `CHECK_JOBS=4 OPENSCAD_RENDER_FN=24 bash scripts/check-collisions.sh`
- Use a timeout of 550 seconds for that command.
- A deliberately empty OpenSCAD intersection exits non-zero; let `scripts/check-collisions.sh` interpret it. It runs OpenSCAD with `--hardwarnings`, because a warning can silently drop a probe and fake an empty result.
- Add collision modes in both `case/collision_check.scad` and `scripts/check-collisions.sh` when introducing a new fit invariant.
- Both exported STLs must contain exactly one connected component.
- Keep `scripts/check-collisions.sh` compatible with macOS Bash 3.2; do not use `wait -n`.
