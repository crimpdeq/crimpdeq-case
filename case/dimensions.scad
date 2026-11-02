//
// Shared component and stack dimensions
// Units: mm
// Legend:
// - L: Length
// - W: Width
// - T: Thickness
//

// Load cell
lc_L = 80;
lc_W = 40;
lc_T = 4;
loadcell_lift = 2.0; // support structure height under load cell (from enclosure floor)

eye_d = 17;
eye_edge_start = 6;
eye_center_offset = eye_edge_start + eye_d / 2;
eye_ring_bore_d = 15; // pressed-in eye ring, not modelled in load_cell.scad
carabiner_shank_d = 12;
// Radial clearance from each eye hole to its slot wall. The battery bay wall
// cuts each slot short on its inboard side.
eye_slot_clear = 2.5;

// Silicone-covered strain gauge at the load-cell center, on the face toward
// the battery. Its four wires leave the cover's +Y side, toward the front
// wall. Footprint from the assembly photos; the height is measured (6.5 mm
// across the plate and cover).
gauge_cover_w = 14; // along X
gauge_cover_l = 21; // along Y
gauge_cover_h = 2.5;
gauge_cover_y = 4.3; // center, offset toward the wire exit
loadcell_wire_bundle = [2.0, 1.4]; // four ~0.7 mm wires two by two: width, height

notch_d = 6;
notch_xA = 20;
notch_xB = 60;

// Shell shared by the main body and lid.
wall_t = 2.4;
lid_t = 2.4;
// The lid may seat anywhere within the 0.25 mm play of the screws in their
// lid holes, plus 0.2 mm for printed walls off size.
lid_seat_play = 0.45;
// Symmetric hexagonal plan: flat front and rear walls and a point at each
// end. 60 degrees from the X axis makes every interior angle 120 degrees.
case_facet_angle = 60;

// Electronics bay half-width around the battery guides. Beyond it, nothing in
// the main body may touch the load cell.
pod_half_x = 22;
// The facets enclose the whole load cell, including all four corners.
loadcell_guard_clear = 0.5;
loadcell_slot_wall_t = 1.2;
loadcell_slot_clear_z = 0.3;
// Gap from the lid slot-wall ends to the main-body facets and to the fins
// beside them. The screws locate the lid; at 0.2 mm the tall wall ends wedged
// into the slightly undersized printed cavity and held the lid open.
slot_wall_fit = 0.6;
// How far each main-body fin reaches past its lid slot-wall end, so the gap
// round the end is a labyrinth instead of a slit from the slot into the bay.
slot_seal_overlap = 1.5;

// Battery: 800 mAh 102530 LiPo, 10 x 25 x 30 mm overall, leads leaving one
// 25 mm end, which faces the rear wall.
bat_L = 30;
bat_W = 25;
bat_T = 10;
// Inner faces of the bay walls beside the eye slots. The battery leads run
// forward between them and the battery, beside the board.
battery_bay_half_w = 17.5;
// Pads under the battery's rear corners, behind the load cell.
battery_pad_size = 8;
battery_pad_inset = 1; // from the battery's rear and side edges
battery_pad_loadcell_clear = 1; // from the pads to the load cell
// Lid hold-downs above the pads press the battery onto them by one 0.2 mm
// layer, so it cannot rattle. Re-measure bat_T if the battery changes: a
// thicker one adds its excess to this preload.
battery_hold_down_preload = 0.2;

// PCB revision 3 (crimpdeq-pcb pcb/crimpdeq, board center (142.45, 67.40)).
// The board is installed bottom-side up with its USB-C edge toward the front
// wall: KiCad F.Cu faces the floor and B.Cu (LEDs and ESP32 module) faces
// the lid. That flip turns about the X axis, and KiCad's Y axis points down,
// so a KiCad offset (dx, dy) from the board center is case-local (dx, dy).
// Rectangles below are [x_min, x_max, y_min, y_max] in that frame, taken
// from the KiCad courtyards.
pcb_L = 30;
pcb_W = 30;
pcb_board_t = 1.6;
pcb_bottom_parts_h = 1.8; // tallest F.Cu part (L1, Bourns SRN4018)
pcb_top_parts_h = 1.5; // B.Cu SOT-23-5/SOD-123 parts, below the module and RGB LED
pcb_module_h = 2.4; // ESP32-C3-MINI-1
pcb_module_rect = [-7.25, 5.95, -20.2, -3.6]; // its antenna overhangs the rear edge
// Bare F.Cu areas that case supports may touch:
// left of the ADS1220 and the 100R filter resistors, between the USB-C
// connector and the right-edge cable pads, and behind those pads.
pcb_support_windows = [
    [-15, -8.3, 4.0, 12.2],
    [9.9, 12.3, 7.0, 15]
];
// Floor-anchored column under each support window. The board keepout carves
// their tops, so they touch only the windows. The left column rises past the
// board as its left-edge guide and stops in front of the load cell.
// The right one starts at its window and runs into the front wall; it stops
// the board moving right through the USB-C shell, whose legs are
// through-hole. Both keep clear of the cable pads, and the switch body
// stands between them.
pcb_support_columns = [
    [-16.5, -13.0, -pcb_L / 2, 12.1],
    [9.7, 12.3, 7.0, pcb_L / 2 + 1]
];
pcb_column_loadcell_clear = 0.3; // from the columns to the load-cell front edge
// THT cable pad centers: B-, B+, SW+, SW- on the right edge (J5, J7, J6, J8)
// and E-, A-, A+, E+ on the front edge (J12, J10, J9, J11).
pcb_cable_pads = [
    [13.75, 6.1], [13.75, 8.6], [13.75, 11.15], [13.75, 13.7],
    [-13.65, 13.7], [-10.85, 13.7], [-8.05, 13.7], [-5.25, 13.7]
];
wire_d = 1.6; // 24 AWG silicone hookup wire
// Bare B.Cu areas that lid clamps may press, above the support windows.
pcb_clamp_windows = [
    [-14.6, -9.9, 4.2, 12.2],
    [9.9, 12.3, 7.0, 14.6]
];

// USB-C connector body (GCT USB4105-GF-A, F.Cu) from its F.Fab outline. Its
// front face overhangs the board edge by 0.9 mm.
usb_w = 9.58;
usb_h = 3.31;
usb_d = 7.53;
usb_x = 4.55;
usb_y = 12.135;

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
// The connector body continues into a front-wall through-hole; a pocket in
// front of it lets the cable overmold reach the receptacle face.
usb_hole_clear = 0.55; // around the connector body
usb_pocket_clear = 0.4; // around the cable overmold
usb_pocket_min_web = 0.8; // front wall left behind the pocket

// B.Cu LED positions. D1 is the battery-status LED, a 0603 turned 90 degrees;
// D4 is the WS2812B RGB LED.
status_led_x = -7.65;
status_led_y = -1.40;
status_led_w = 0.8;
status_led_l = 1.6;
status_led_h = 0.8;
rgb_led_x = -11.95;
rgb_led_y = -10.90;
rgb_led_w = 5.0;
rgb_led_l = 5.0;
rgb_led_h = 1.6;

// Stack spacing
// The battery's rear pads hold it this far above the load cell. Nothing may
// hang over the load cell, so its front settles onto the gauge cover.
loadcell_to_battery_gap = gauge_cover_h + 0.5;
battery_rear_gap = 0.2; // minimum battery rear-edge gap to the inner rear wall

// Inner cavity clearances
clear_x = 0.8;
rear_clear = 0.8;
front_clear = 2.0;
top_clear = 0.5; // ESP32 module-to-lid gap
pcb_front_gap = 0.2; // board front edge to the inner front wall; the USB-C connector continues into the wall opening

// Front switch: snap-in rocker with a 21 x 15 mm bezel on the outer face of
// the front wall, 21 mm along X. Taken from the product drawing: 12 mm of
// body behind the bezel, then 8 mm quick-connect tabs; the wires are soldered
// to the tabs, with 1.5 mm of joint and heat-shrink past their tips. The
// cutout is the usual 19 x 13 mm for this bezel.
switch_bezel_w = 21;
switch_bezel_h = 15;
switch_front_depth = 6; // bezel and rocker in front of the wall
switch_cutout_w = 19;
switch_cutout_h = 13;
switch_cutout_clear = 0.1; // a side, as printed holes come out small
switch_w = switch_bezel_w; // behind the wall, across the sprung snap clips
switch_h = switch_cutout_h;
switch_depth = 12 + 8 + 1.5; // behind the outer wall face
switch_d = switch_depth - wall_t; // behind the inner wall face
switch_clear = 0.4;
// The snap clips catch the inside of the wall round the cutout, thinned to
// this panel. Estimated from the clip shoulders in the drawing; measure them.
switch_panel_t = 1.2;
// Bezel to the USB-C cable pocket above it.
switch_usb_gap = 0.6;
// Room behind the solder joints for the wires to turn up, in front of the
// load cell and battery.
switch_wire_bend = 3.5;

// M2.5x10 fasteners shared by main and lid, one at each faceted corner.
// Each center sits this far inside both the front or rear face and the facet
// face, as in v2.0.0. Screwing into a pilot 3.4 mm from the facet split the
// facet wall along a layer line.
screw_edge_inset = 5.25;
screw_len = 10; // under the head
screw_d = 2.5; // thread major diameter
screw_head_d = 5.2; // typical M2.5 button/pan head clearance
screw_head_recess = 1.8; // recess depth so heads do not protrude
// The seated screw forms its thread in the post only over this length above
// its tip, about 2.5 diameters; a clear bore takes the rest. Forming it over
// all 9.4 mm took more torque than the M2.5 shank carries, and screws twisted
// off flush with the post.
screw_thread_len = 6;
