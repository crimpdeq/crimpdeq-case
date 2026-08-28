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
loadcell_lift = 1.5; // support structure height under load cell (from enclosure floor)

eye_d = 17;
eye_edge_start = 6;
eye_center_offset = eye_edge_start + eye_d / 2;
carabiner_shank_d = 12;
carabiner_access_clear = 0.5;
loadcell_eye_access_clear = 0.3;
carabiner_access_d = max(
    carabiner_shank_d + 2 * carabiner_access_clear,
    eye_d + 2 * loadcell_eye_access_clear
);
// Wide lateral mouth for inserting the carabiner nose and opening its gate.
// The circular section around the load-cell eye remains closely fitted.
carabiner_side_entry_w = 30;
loadcell_eye_entry_overcut = 0.2;
eye_tunnel_wall_t = 1.2;
eye_tunnel_outer_d = carabiner_access_d + 2 * eye_tunnel_wall_t;

notch_d = 6;
notch_xA = 20;
notch_xB = 60;

// Compact central pod: retain the load-cell notches while exposing both ends.
loadcell_retain_half_x = 22;
loadcell_channel_clear_y = 0.3;
loadcell_channel_clear_z = 0.3;
loadcell_guard_clear = 0.3;
loadcell_guard_wall_t = 2.4;
loadcell_guard_outer_r = 5;

// Protected 603040 LiPo from AliExpress item 1005010306922880.
// The protection PCB makes the nominal 40 mm cell 42 mm long overall.
bat_L = 42;
bat_W = 30;
bat_T = 6;

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
loadcell_to_battery_gap = 1.0;
battery_to_pcb_gap = 0.5; // relief so the PCB does not rest directly on the battery
battery_rear_gap = 0.2; // minimum battery rear-edge gap to enclosure inner rear wall
battery_end_case_clear = 1.7; // room for the 0.5 mm fit gap and 1.2 mm end guide
rear_fastener_clear = 5.8; // load-cell edge to rear wall for full-height M2.5 posts

// Inner cavity clearances
clear_x = 0.8;
rear_clear = 0.8;
front_clear = 2.0;
top_clear = 1.5; // PCB-to-lid gap with room for clamps and print tolerance
pcb_front_gap = 0.2; // target USB connector face gap before connector-overhang case fit

// Side switch: K139b600-G8 / SS12D10 compact maintained slide switch.
// The PCB-mount part is turned onto its side so the actuator points through
// the -Y rear wall. Raw dimensions remain in switch-local axes.
switch_w = 12.8;
switch_d = 3.4;
switch_h = 6.9;
switch_total_d = 8.0;
switch_actuator_d = switch_total_d - switch_d;
switch_actuator_w = 4.0;
switch_actuator_h = 4.9;
switch_travel = 2.2;
switch_terminal_pitch = 4.7;
switch_terminal_installed_d = 0.5; // trim pins close and solder wires upward to clear the load cell
switch_terminal_w = 1.3;
switch_terminal_h = 0.8;
switch_panel_setback = 1.7;
switch_fit_clear_x = 0.25;
switch_fit_clear_y = 0.25;
switch_fit_clear_top = 0.20;
switch_opening_clear = 0.4;
