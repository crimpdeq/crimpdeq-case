//
// Shared assembly placement derived from component dimensions
// Units: mm
//

include <dimensions.scad>

// Component positions in assembled case coordinates.
// +Y points toward the USB side/front wall.
inner_z_min = -lc_T / 2;
loadcell_bottom_z = inner_z_min + loadcell_lift;
loadcell_center_z = loadcell_bottom_z + lc_T / 2;
loadcell_top_z = loadcell_bottom_z + lc_T;

// Revision 3 is shorter than the battery and load cell, so derive the cavity
// and component positions from every front/rear envelope instead of the PCB.
case_inner_y_max = max(
    pcb_L / 2 + front_clear,
    lc_W / 2 + switch_d + 2 * switch_clear
);
switch_y = case_inner_y_max - switch_d / 2 - switch_clear;
pcb_y_offset = case_inner_y_max - pcb_front_gap - pcb_L / 2;
battery_y_offset = switch_y - switch_d / 2 - battery_switch_gap - bat_L / 2;
case_inner_y_min = min(
    -lc_W / 2 - rear_clear,
    pcb_y_offset - pcb_L / 2 - rear_clear,
    battery_y_offset - bat_L / 2 - battery_rear_gap
);

battery_bottom_z = loadcell_top_z + loadcell_to_battery_gap;
battery_top_z = battery_bottom_z + bat_T;
battery_front_y = battery_y_offset + bat_L / 2;

pcb_bottom_z = battery_top_z + battery_to_pcb_gap;
pcb_center_z = pcb_bottom_z + pcb_T / 2;
pcb_top_z = pcb_bottom_z + pcb_T;

switch_h_eff = (abs(switch_rot_y) % 180 == 90) ? switch_w : switch_h;
switch_x = 0;
switch_z = inner_z_min + switch_h_eff / 2;
