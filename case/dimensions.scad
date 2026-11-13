//
// Shared component and stack dimensions
// Units: mm
// Legend:
// - L: Length
// - W: Width
// - T: Thickness
//
// Case frame: X runs along the load-cell axis, -Y points to the front wall
// with the USB-C connector and the switch, and Z = 0 is the floor's outer
// face.
//

// Load cell
lc_L = 80;
lc_W = 40;
lc_T = 4;

eye_d = 17;
eye_edge_start = 6;
eye_center_offset = eye_edge_start + eye_d / 2;
eye_ring_bore_d = 13.9; // pressed-in eye ring, measured 13.8-13.9 mm; not modelled in load_cell.scad
carabiner_shank_d = 12;
// Radial clearance from each eye hole to its slot wall. The battery bay wall
// bounds each slot on its inboard side.
eye_slot_clear = 2.5;

// Silicone-covered strain gauge at the load-cell center. The plate goes in
// with the cover facing the floor and its four wires leaving the cover's
// front (-Y) side, so the battery lies flat on the bare top face. Footprint
// from the assembly photos; the height is measured (6.5 mm across the plate
// and cover).
gauge_cover_w = 14; // along X
gauge_cover_l = 21; // along Y
gauge_cover_h = 2.5;
gauge_cover_y = 4.3; // center offset toward the wire exit
loadcell_wire_bundle = [2.0, 1.4]; // four ~0.7 mm wires two by two: width, height
// Floor pads hold the plate this far above the cover's underside, with room
// for its wires beside it.
loadcell_cover_clear = 0.5;
loadcell_pad_size = [3, 5]; // X, Y
loadcell_pad_edge_inset = 2; // from the plate's long edges

notch_d = 6;
notch_xA = 20;
notch_xB = 60;
notch_pin_clear = 0.1; // radial, floor pins in the notches

// Shell shared by the main body and lid: five 0.4 mm perimeters in the walls,
// ten 0.2 mm layers in the floor and lid.
wall_t = 2.0;
floor_t = 2.0;
lid_t = 2.0;
// Rounds the outer vertical edges.
case_corner_r = 1;

// The walls enclose the whole load cell, including all four corners.
loadcell_guard_clear = 0.5;
// Lid features over the load cell stop this far above it, so a printed part
// slightly off size cannot hold the lid open.
loadcell_hold_down_clear = 0.6;
loadcell_slot_wall_t = 1.2;
loadcell_slot_clear_z = 0.3;
// Gap from the lid slot-wall ends to the main body. The screws locate the
// lid; at 0.2 mm the tall wall ends wedged into the slightly undersized
// printed cavity and held the lid open.
slot_wall_fit = 0.6;
// Each lid slot-wall end reaches this far into a groove in the end wall, so
// the gap round it is a labyrinth instead of a slit from the slot into the
// bay.
slot_seal_overlap = 1.5;

// Battery: 800 mAh 102530 LiPo with its protection board, 10 x 25 x 30 mm
// overall. It lies flat on the load cell with its protection-board end, which
// its leads leave from the middle, toward the front wall. If they leave off
// center, turn the cell over so they leave right of center.
bat_L = 30;
bat_W = 25;
bat_T = 10;
battery_side_clear = 0.5; // to the bay walls beside the eye slots
battery_stop_clear = 0.3; // to the front column
battery_lead_clear = 0.3; // round the leads in the front column's recess
// Lid hold-downs beside the board stop this far above the battery. They limit
// how far it can lift without pressing it onto the load cell, whose reading
// would shift under the load.
battery_hold_down_clear = 0.3;
// The hold-downs stop this far inside the battery's rear edge and behind the
// switch wire bend.
battery_hold_down_inset = 0.5;
// Lid ribs beside the battery stop it along X, the axis it hangs on. Both are
// on the lid, so a lid seated off center carries the battery with it instead
// of pinching it, and the clearance may be smaller than lid_seat_play. The
// chamfer on each rib's battery side centers the battery as the lid closes.
battery_side_stop_clear = 0.3;
battery_side_stop_t = 1.2;
battery_side_stop_chamfer = 0.8;
// Lid wall behind the battery, which ends over the load cell. Its gap is
// larger than lid_seat_play, so the lid seats without pushing the battery.
battery_rear_stop_clear = 0.6;
battery_rear_stop_t = 2.4;
battery_rear_stop_inset = 3; // from the battery's sides

// PCB: crimpdeq-tscircuit (ADS1220 variant), 17 x 31.5 mm, from its
// circuit.json. The board sits top side up and unrotated: the ESP32 module,
// USB-C connector and both LEDs face the lid, and a tscircuit offset (x, y)
// from the board center is case-local (x, y). Rectangles below are
// [x_min, x_max, y_min, y_max] in that frame.
pcb_W = 17;
pcb_L = 31.5;
pcb_board_t = 1.6;
pcb_corner_r = 1;
pcb_bottom_parts_h = 1.45; // tallest bottom part: 0805 10 uF (C15, C17) at its maximum
pcb_top_parts_h = 1.0; // SOD-323 D8 and the other low top parts
pcb_module_rect = [-6.6, 6.6, -1.2, 15.4]; // ESP32-C3-MINI-1, antenna at the +Y edge
pcb_module_h = 2.5;
// Bare bottom-side strips from the front edge between each wire-pad column
// and the USB-C shell legs, 0.2 mm from the wire pads and clear of the
// courtyards. Case supports touch the board only there.
pcb_support_windows = [
    [-6.05, -4.93, -pcb_L / 2, -7.4],
    [4.93, 6.05, -pcb_L / 2, -7.3]
];
// Plated wire pads: J3 E+, S+, S-, E- on the left and J4 SW-, SW+, B+, B- on
// the right.
pcb_cable_pads = [
    [-7, -7.25], [-7, -9.45], [-7, -11.65], [-7, -13.85],
    [7, -7.8], [7, -10], [7, -12.2], [7, -14.4]
];
wire_d = 1.6; // 24 AWG silicone hookup wire
// Room between the battery front and the wires dropping from the nearest pads.
cable_pad_battery_clear = 0.8;
pcb_part_clear = 0.2; // support column top below the bottom parts

// USB-C receptacle (TYPE-C-31-M-12, top side) from its 3D model. Its front
// face overhangs the board edge by 1.0 mm; its flat shell top takes the lid
// clamp.
usb_rect = [-4.47, 4.47, -16.75, -9.0];
usb_shell_top_rect = [-4.1, 4.1, -16.6, -9.4];
usb_h = 3.25;

// USB-C cable plug. The metal shell enters the receptacle; the overmold is the
// largest envelope in the USB Type-C plug dimensions update ECN
// (12.85 x 7.0 mm, up from 12.35 x 6.5 mm).
usb_plug_shell_w = 8.6;
usb_plug_shell_h = 3.0;
usb_plug_shell_corner_r = 0.7;
usb_overmold_w = 12.85;
usb_overmold_h = 7.0;
usb_overmold_corner_r = 1.0;
// The fully mated overmold may stop this far in front of the receptacle
// face. Keep it small: plugs have well under a millimeter of spare length.
usb_overmold_stop_gap = 0.3;
// The connector reaches into a front-wall opening; a pocket in front of it
// lets the cable overmold reach the receptacle face.
usb_hole_clear = 0.55; // around the connector body
usb_pocket_clear = 0.4; // around the cable overmold
usb_pocket_min_web = 0.8; // front wall left behind the pocket
// The receptacle rises above the seam into a lid pocket this far clear of it.
usb_lid_clear = 0.4;
// The lid clamp presses the board onto the column fingers through the flat
// shell top, right above them, by one 0.2 mm layer: it ends on a layer
// boundary and the lid flexes to absorb it.
usb_clamp_preload = 0.1;

// Top-side LEDs. D1 is the battery-status LED, a 0603 turned 90 degrees; D4
// is the XL-2121RGBC RGB LED.
status_led_x = 4.1;
status_led_y = -3.403;
status_led_w = 0.8;
status_led_l = 1.6;
status_led_h = 0.8;
rgb_led_x = -6.4;
rgb_led_y = -3.279;
rgb_led_w = 2.2;
rgb_led_l = 2.2;
rgb_led_h = 1.0;
// The lid's LED holes stop this short of its outer face, two 0.2 mm layers
// printed first on the bed. The windows keep chalk and dust off the board;
// light PLA lets the LEDs show through them, black PLA does not.
led_window_t = 0.4;
status_led_view_d = 2.6;
rgb_led_view_d = 3.2;

// Stack spacing
battery_to_pcb_gap = 0.5; // battery top to the board's bottom parts
pcb_front_gap = 0.2; // board front edge to the inner front wall
pcb_guide_clear = 0.25; // board long edges to the front screw posts
top_clear = 0.5; // minimum ESP32 module-to-lid gap
// Lid tabs behind the board's rear edge take USB-C insertion loads. The
// chamfer on each tab's board side pushes a board that slid back during
// assembly forward as the lid closes.
pcb_rear_stop_x_min = 3.5; // |x| from the board center; they run to its edges
pcb_rear_stop_t = 2.4;
pcb_rear_stop_below = 1.0; // reach below the board underside
pcb_rear_stop_chamfer = 0.8;

// Front-wall switch (KCD11 10x15 mm). Measured 15.2 mm from its front to the
// end of its heat-shrunk solder joints; all of it is taken as behind the
// outer wall face, the worst case.
switch_w = 15; // along X
switch_h = 10; // along Z
switch_depth = 15.2;
switch_clear = 0.4;
switch_flange = 1.0; // bezel lip beyond the opening on the outer face
// The bezel is held only by friction in its wall opening. v2.0.0's 3.0 mm
// wall held it; a collar behind the front wall restores that length.
switch_grip_len = 3.0;
switch_collar_t = 1.2;
// Room behind the solder joints for the wires to turn up over the battery.
switch_wire_bend = 3.5;
switch_loadcell_clear = 0.5; // switch underside above the load cell

// Countersunk Phillips self-tapping screws, sold as M2.5x10, shared by main
// and lid. Their coarse ~0.9 mm pitch thread forms in PLA with far less
// torque than the M2.5 machine screws that twisted off in the V3 posts. Each
// center sits at least this far inside the outer faces, as in v2.0.0.
// Screwing into a pilot 3.4 mm from a face split the wall along a layer line.
screw_edge_inset = 5.25;
screw_len = 10.3; // measured overall, head included
screw_d = 2.4; // measured across the thread crests
screw_head_d = 4.8; // measured; 90 degree countersunk head
screw_head_h = (screw_head_d - screw_d) / 2; // its 90 degree cone down to the thread
// Lid countersink diameter at the lid top. The head seats
// (screw_countersink_d - screw_head_d) / 2 below flush.
screw_countersink_d = 5.0;
screw_post_d = 6.5;
// The seated screw forms its thread in the post only over this length above
// its tip, 2.5 diameters; a clear bore takes the rest, so the post top cannot
// bulge into the lid.
screw_thread_len = 6;
// Pilot the screw forms its thread in. Printed holes come out about 0.15 mm
// small, so this prints near 1.95 mm, about 0.8 of the thread diameter, the
// usual pilot for thread-forming screws in plastic.
screw_thread_d = 2.1;
screw_thread_tip_clear = 0.6; // pilot depth beyond the screw tip
// Bore above the threaded length. It prints about 0.15 mm small too, and
// must still clear the thread crests.
screw_shank_clear_d = 3.0;
screw_clear_d = 3.0; // lid hole, loose so the lid seats easily on the posts
// 90 degree countersink from the lid top down to the clearance hole.
countersink_depth = (screw_countersink_d - screw_clear_d) / 2;
// The lid may seat anywhere within the play of the screws in their lid holes,
// plus 0.2 mm for printed walls off size.
lid_seat_play = (screw_clear_d - screw_d) / 2 + 0.2;

// "Crimpdeq" titles on the lid and the bottom. They read along Y, between the
// carabiner slots, so they are horizontal when the device hangs from its eyes.
brand_text = "Crimpdeq";
brand_font = "Liberation Sans:style=Bold"; // bundled with OpenSCAD
brand_depth = 0.8;
// Both titles are centered and this long, the largest that keeps the lid one
// brand_led_clear from the LED holes, so it never opens their windows.
brand_l = 48.6;
brand_led_clear = 0.6;
// Rear-wall title, spanning the flat rear wall.
rear_brand_text = "crimpdeq.com";
rear_brand_depth = 0.8;
rear_brand_margin = 2; // from each end of the flat rear wall
