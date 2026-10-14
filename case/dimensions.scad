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
// Radial clearance from each eye hole to its slot wall. The battery sides line
// up with the inner edges of the eyes, so the battery bay cuts each slot short
// on its inboard side.
eye_slot_clear = 2.5;

notch_d = 6;
notch_xA = 20;
notch_xB = 60;

// Shell shared by the main body and lid.
wall_t = 2.4;
lid_t = 2.4;
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

// Battery
bat_L = 50;
bat_W = 34;
bat_T = 10;
battery_side_clear = 0.5; // to the bay walls beside the eye slots

// PCB revision 3 (crimpdeq-pcb pcb/crimpdeq, board center (142.45, 67.40)).
// The board is installed bottom-side up with its USB-C edge toward the front
// wall: KiCad F.Cu faces the battery and B.Cu (LEDs and ESP32 module) faces
// the lid. That flip turns about the X axis, and KiCad's Y axis points down,
// so a KiCad offset (dx, dy) from the board center is case-local (dx, dy).
// Rectangles below are [x_min, x_max, y_min, y_max] in that frame, taken
// from the KiCad courtyards.
pcb_L = 30;
pcb_W = 30;
pcb_board_t = 1.6;
pcb_bottom_parts_h = 1.8; // tallest F.Cu part over the battery (L1, Bourns SRN4018)
pcb_top_parts_h = 1.5; // B.Cu SOT-23-5/SOD-123 parts, below the module and RGB LED
pcb_module_h = 2.4; // ESP32-C3-MINI-1
pcb_module_rect = [-7.25, 5.95, -20.2, -3.6]; // its antenna overhangs the rear edge
// Bare F.Cu areas in front of the battery that case supports may touch:
// left of the ADS1220 and the 100R filter resistors, between the USB-C
// connector and the right-edge cable pads, and behind those pads.
pcb_support_windows = [
    [-15, -8.3, 4.0, 12.2],
    [9.9, 12.3, 7.0, 15],
    [12.9, 15, 1.7, 4.6]
];
// Floor-anchored column under each support window. The board keepout carves
// their tops, so they touch only the windows; their rear ends stop at the
// battery front. The outer columns rise past the board as edge guides and
// stop and prop the battery. The middle one starts at its window, leaving a
// wire channel from the switch to the cable pads, and runs into the front
// wall. All keep clear of the cable pads.
pcb_support_columns = [
    [-16.5, -8.3, -pcb_L / 2, 12.1],
    [8.3, 12.3, 7.0, pcb_L / 2 + 1],
    [12.9, 16.5, -pcb_L / 2, 4.6]
];
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
loadcell_to_battery_gap = 1.5;
battery_to_pcb_gap = 0.5; // relief so the PCB does not rest directly on the battery
battery_rear_gap = 0.2; // minimum battery rear-edge gap to the inner rear wall

// Inner cavity clearances
clear_x = 0.8;
rear_clear = 0.8;
front_clear = 2.0;
top_clear = 0.5; // ESP32 module-to-lid gap
pcb_front_gap = 0.2; // board front edge to the inner front wall; the USB-C connector continues into the wall opening

// Side switch (KCD11 10x15 mm)
switch_w = 15;
switch_d = 13;
switch_h = 10;
switch_rot_y = 0;
switch_clear = 0.4;
battery_switch_gap = 0.4;

// M2.5x10 fasteners shared by main and lid, one at each faceted corner.
screw_corner_inset = 4.65; // center inset from the front and rear walls
screw_len = 10; // under the head
screw_head_d = 5.2; // typical M2.5 button/pan head clearance
screw_head_recess = 1.8; // recess depth so heads do not protrude
screw_head_wall = 0.8; // minimum shell outside each head recess
