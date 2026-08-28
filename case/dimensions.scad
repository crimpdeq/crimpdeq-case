//
// Shared component and stack dimensions
// Units: mm
// Legend:
// - L: Length
// - W: Width
// - T: Thickness
//

// General mid-range FDM profile (0.4 mm nozzle, 0.2 mm layers).
// Keep separate values for sliding fits, rigid parts, soft packs, and Z gaps;
// they compensate for different manufacturing and assembly failure modes.
fdm_slide_clear = 0.35;
fdm_rigid_clear = 0.50;
fdm_soft_clear = 0.75;
fdm_z_clear = 0.30;

// Shared enclosure construction.
case_wall_t = 2.4;
case_floor_t = 2.4;
case_lid_t = 2.4;
case_corner_r = 6;
internal_feature_embed = 0.15;

// Shared face branding.
brand_text = "Crimpdeq";
brand_font = "Liberation Sans:style=Bold";
brand_size = 7.0;
brand_depth = 0.4;

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
bat_pouch_L = 40;
bat_corner_r = 2;
bat_pcm_L = bat_L - bat_pouch_L;
bat_pcm_W = bat_W;
bat_pcm_T = bat_T;
bat_lead_d = 2.0;
bat_lead_exit_l = 1.2;
bat_lead_pair_w = 6.0;

// PCB revision 3.0 (PR crimpdeq/crimpdeq-pcb#23).
// The board is installed bottom-side up so its two bottom-mounted LEDs face the lid.
pcb_L = 30;
pcb_W = 30;
pcb_T = 5;

// USB4105-GF-A manufactured connector envelope, measured from the PCB STEP.
usb_w = 8.94;
usb_h = 3.31;
usb_d = 7.71;
usb_inset = 3.2;
// Case-local coordinates after flipping the PCB bottom-side up while keeping
// the USB edge toward +Y. Source board center: (142.45, 67.40); J2 is at
// (147.00, 80.70), and its mating face is 2.60 mm beyond the footprint origin.
// The manufactured connector therefore overhangs the PCB edge by 0.90 mm.
usb_x = -4.55;
usb_y = 12.045;

// USB-C plug metal shell envelope used for port fit checks.
usb_plug_shell_w = 8.6;
usb_plug_shell_h = 3.0;
usb_plug_shell_corner_r = 0.7;
// Normal molded cable boot pocket. The assumed 12.2 x 6.7 mm boot receives
// general-FDM fit margin while oversized/rugged overmolds are intentionally
// excluded. A seated plug still needs nearly the complete recess depth.
usb_boot_w = 13.0;
usb_boot_h = 7.5;
usb_boot_corner_r = 2.0;
usb_boot_recess_depth = 2.3;
usb_boot_probe_depth = 4.0;

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
battery_switch_clear_z = 0.5;
battery_to_pcb_gap = 2.5; // insulation plus a 2 mm wire race below the PCB
battery_rear_gap = 0.2; // minimum battery rear-edge gap to enclosure inner rear wall
battery_end_case_clear = 1.7; // room for the 0.5 mm fit gap and 1.2 mm end guide
rear_fastener_clear = 5.8; // load-cell edge to rear wall for full-height M2.5 posts

// Conservative solder and inward-bending wire route below the PCB's
// case-local -X edge. Clips and guides must stay out of this corridor.
pcb_solder_keepout_w = 4.0;
pcb_solder_keepout_l = 18.0;
pcb_solder_keepout_h = 1.0;
pcb_wire_race_d = 2.0;
pcb_wire_race_clear = 0.5;
pcb_wire_exit_l = 6.0;

// Lid-mounted PCB cradle.
pcb_cradle_xy_clear = fdm_slide_clear;
pcb_cradle_top_clear = fdm_z_clear;
pcb_cradle_pad_d = 3.0;
pcb_cradle_rail_t = 1.2;
pcb_cradle_feature_w = 4.0;
pcb_cradle_hook_overlap = 0.8;
pcb_cradle_hook_h = 0.8;

// Axial PCB reaction points for USB cable insertion and extraction.
pcb_axial_stop_clear = fdm_slide_clear;
pcb_axial_stop_w = 2.4;
pcb_axial_stop_port_clear = 0.6;

// Inner cavity clearances
clear_x = 0.8;
rear_clear = 0.8;
front_clear = 2.0;
top_clear = 1.5; // PCB-to-lid gap with room for clamps and print tolerance
usb_face_wall_gap = 0.2; // connector mating face to inner wall

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
