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
carabiner_shank_d = 12;
carabiner_access_clear = 0.5;
carabiner_access_d = carabiner_shank_d + 2 * carabiner_access_clear;
eye_tunnel_radial_clear = 0.3;
eye_tunnel_outer_d = eye_d - 2 * eye_tunnel_radial_clear;

notch_d = 6;
notch_xA = 20;
notch_xB = 60;

// Compact central pod: retain the load-cell notches while exposing both ends.
loadcell_retain_half_x = 22;
loadcell_channel_clear_y = 0.3;
loadcell_channel_clear_z = 0.3;

// Battery
bat_L = 50;
bat_W = 34;
bat_T = 10;

// PCB revision 3.0 (PR crimpdeq/crimpdeq-pcb#23).
// The board is installed bottom-side up so its two bottom-mounted LEDs face the lid.
pcb_L = 30;
pcb_W = 30;
pcb_T = 5;

// USB-C connector envelope
usb_w = 9;
usb_h = 3.2;
usb_d = 7.73;
usb_inset = 3.2;
// Case-local coordinates after flipping the PCB bottom-side up while keeping
// the USB edge toward +Y. Source board center: (142.45, 67.40).
usb_x = -4.55;
usb_y = 11.135;

// USB-C plug metal shell envelope used for port fit checks.
// The molded cable boot stays outside the case; only the plug shell enters the hole.
usb_plug_shell_w = 8.6;
usb_plug_shell_h = 3.0;
usb_plug_shell_corner_r = 0.7;

// Bottom-mounted LED positions, transformed into case-local coordinates.
// D1 is the battery-status LED; D4 is the WS2812B RGB LED.
status_led_x = 7.65;
status_led_y = -1.40;
status_led_w = 1.6;
status_led_l = 0.8;
status_led_h = 0.8;
rgb_led_x = 11.95;
rgb_led_y = -10.90;
rgb_led_w = 5.0;
rgb_led_l = 5.0;
rgb_led_h = 1.6;

// Stack spacing
loadcell_to_battery_gap = 2;
battery_to_pcb_gap = 1.0; // small relief so the PCB does not rest directly on the battery
battery_rear_gap = 0.2; // target battery rear-edge gap to enclosure inner rear wall

// Inner cavity clearances
clear_x = 0.8;
rear_clear = 0.8;
front_clear = 2.0;
top_clear = 2.5; // PCB-to-lid gap, increased slightly to reduce lid pressure on the PCB
pcb_front_gap = 0.2; // target USB connector face gap before connector-overhang case fit

// Side switch (KCD11 10x15 mm)
switch_w = 15;
switch_d = 13;
switch_h = 10;
switch_rot_y = 0;
switch_clear = 0.4;
battery_switch_gap = 0.4;

// Screw centers from outer walls (shared by main and lid).
// 5.25 mm makes main screw posts merge into side walls for higher strength.
screw_corner_inset = 5.25;
