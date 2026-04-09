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
loadcell_lift = 2.5; // support structure height under load cell (from enclosure floor)

eye_d = 17;
eye_edge_start = 6;
eye_center_offset = eye_edge_start + eye_d / 2;

notch_d = 6;
notch_xA = 20;
notch_xB = 60;

// Battery
bat_L = 50;
bat_W = 34;
bat_T = 10;

// PCB
pcb_L = 64;
pcb_W = 24;
pcb_T = 5;

// USB-C connector envelope
usb_w = 9;
usb_h = 3.2;
usb_d = 7;
usb_inset = 3.2;

// USB-C cable plug outer housing envelope used for fit checks
// (common slim molded plug body; not just the metal connector shell)
usb_cable_boot_w = 12.0;
usb_cable_boot_h = 6.0;
usb_cable_boot_corner_r = 1.0;

// LED placement on PCB
led_from_left = 5;
led_from_usb_side = 15;

// Stack spacing
loadcell_to_battery_gap = 2;
battery_to_pcb_gap = 1.0; // small relief so the PCB does not rest directly on the battery
battery_rear_gap = 0.2; // target battery rear-edge gap to enclosure inner rear wall

// Inner cavity clearances
clear_x = 0.8;
rear_clear = 0.8;
front_clear = 2.0;
top_clear = 2.5; // PCB-to-lid gap, increased slightly to reduce lid pressure on the PCB
pcb_front_gap = 0.2; // target PCB front-edge gap to USB-side inner wall

// Side switch (KCD11 10x15 mm)
switch_w = 15;
switch_d = 13;
switch_h = 10;
switch_rot_y = 0;
switch_clear = 0.4;

// Screw centers from outer walls (shared by main and lid).
// 5.25 mm makes main screw posts merge into side walls for higher strength.
screw_corner_inset = 5.25;
