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
loadcell_eye_center_x = lc_L / 2 - eye_center_offset;
loadcell_guard_cavity_x_half = lc_L / 2 + loadcell_guard_clear;
loadcell_guard_cavity_y_half = lc_W / 2 + loadcell_guard_clear;
loadcell_guard_x_half = loadcell_guard_cavity_x_half + loadcell_guard_wall_t;
loadcell_guard_y_half = loadcell_guard_cavity_y_half + loadcell_guard_wall_t;
loadcell_guard_lower_top_z = loadcell_bottom_z - loadcell_guard_clear;

module loadcell_eye_access_2d(x_sign) {
    eye_x = x_sign * loadcell_eye_center_x;
    entry_x = x_sign * (
        loadcell_guard_x_half + loadcell_eye_entry_overcut
    );

    // Blend the eye-sized circular throat into a full-width circular mouth.
    // The hull produces tangent sides and a rounded outer opening instead of
    // the former square slot with abrupt 90-degree shoulders.
    hull() {
        translate([eye_x, 0])
            circle(d = carabiner_access_d);
        translate([entry_x, 0])
            circle(d = carabiner_side_entry_w);
    }
}

// The electronics remain in a compact central pod. Lightweight end guards
// extend around the load-cell corners without enlarging the electronics bay.
case_inner_x_half = loadcell_retain_half_x + clear_x;
loadcell_guard_join_x = case_inner_x_half;

// Revision 3 is shorter than the battery and load cell. Moving the switch to
// the rear fastener-clearance strip lets the front wall follow only the load
// cell, battery guide, and USB-facing PCB.
// Keep the battery centered so it overhangs both load-cell edges and can land
// on narrow floor-anchored support ledges.
battery_y_offset = 0;
case_inner_y_max = max(
    pcb_L / 2 + front_clear,
    lc_W / 2 + rear_clear,
    battery_y_offset + bat_L / 2 + battery_end_case_clear
);
pcb_y_offset = case_inner_y_max - pcb_front_gap - pcb_L / 2;
case_inner_y_min = min(
    -lc_W / 2 - rear_clear,
    -lc_W / 2 - rear_fastener_clear,
    pcb_y_offset - pcb_L / 2 - rear_clear,
    battery_y_offset - bat_L / 2 - battery_rear_gap
);

battery_bottom_z = loadcell_top_z + loadcell_to_battery_gap;
battery_top_z = battery_bottom_z + bat_T;
battery_front_y = battery_y_offset + bat_L / 2;

pcb_bottom_z = battery_top_z + battery_to_pcb_gap;
pcb_center_z = pcb_bottom_z + pcb_T / 2;
pcb_top_z = pcb_bottom_z + pcb_T;

// Rotate the switch 180 degrees around Z so its actuator exits through the
// rear wall. The body occupies the existing fastener-clearance strip behind
// the load cell and remains floor-mounted for simple top-down installation.
switch_x = 0;
switch_y = case_inner_y_min + switch_panel_setback + switch_d / 2;
switch_z = inner_z_min + switch_h / 2;
switch_x_min = switch_x - switch_w / 2;
switch_x_max = switch_x + switch_w / 2;
switch_y_min = switch_y - switch_d / 2;
switch_y_max = switch_y + switch_d / 2;
switch_actuator_y = switch_y_min - switch_actuator_d / 2;
switch_terminal_y_max = switch_y_max + switch_terminal_installed_d;

// Shared plan profile for one protective end cap. Four tangent corner arcs
// blend the screw-bearing pod into the narrower eye guard without stepped
// shoulders or sharp 90-degree transitions.
module loadcell_end_guard_2d(
    x_sign,
    blend_x = loadcell_guard_join_x,
    blend_y_min = -loadcell_guard_y_half + loadcell_guard_outer_r,
    blend_y_max = loadcell_guard_y_half - loadcell_guard_outer_r,
    blend_r = loadcell_guard_outer_r
) {
    outer_r = min(
        loadcell_guard_outer_r,
        loadcell_guard_x_half - 0.1,
        loadcell_guard_y_half - 0.1
    );
    inner_r = min(
        blend_r,
        loadcell_guard_x_half - 0.1,
        (blend_y_max - blend_y_min) / 2 + blend_r - 0.1
    );
    inner_x = x_sign * blend_x;
    outer_x = x_sign * (loadcell_guard_x_half - outer_r);

    hull() {
        for (inner_y = [blend_y_min, blend_y_max])
            translate([inner_x, inner_y])
                circle(r = inner_r);
        for (outer_y = [
            -loadcell_guard_y_half + outer_r,
            loadcell_guard_y_half - outer_r
        ])
            translate([outer_x, outer_y])
                circle(r = outer_r);
    }
}
