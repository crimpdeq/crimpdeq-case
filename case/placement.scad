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
usb_front_y = usb_y + usb_d / 2;
pcb_y_offset = case_inner_y_max - usb_face_wall_gap - usb_front_y;
case_inner_y_min = min(
    -lc_W / 2 - rear_clear,
    -lc_W / 2 - rear_fastener_clear,
    pcb_y_offset - pcb_L / 2 - rear_clear,
    battery_y_offset - bat_L / 2 - battery_rear_gap
);

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
switch_bottom_z = switch_z - switch_h / 2;
switch_top_z = switch_z + switch_h / 2;

// Raise the square battery envelope above both the load cell and switch.
battery_bottom_z = max(
    loadcell_top_z + loadcell_to_battery_gap,
    switch_top_z + battery_switch_clear_z
);
battery_center_z = battery_bottom_z + bat_T / 2;
battery_top_z = battery_bottom_z + bat_T;
battery_front_y = battery_y_offset + bat_L / 2;
battery_rear_y = battery_y_offset - bat_L / 2;
battery_pcm_y = battery_front_y - bat_pcm_L / 2;
battery_lead_y_min = battery_front_y;
battery_lead_y_max = battery_front_y + bat_lead_exit_l;
battery_lead_y = (battery_lead_y_min + battery_lead_y_max) / 2;

pcb_bottom_z = battery_top_z + battery_to_pcb_gap;
pcb_center_z = pcb_bottom_z + pcb_T / 2;
pcb_top_z = pcb_bottom_z + pcb_T;
pcb_front_y = pcb_y_offset + pcb_L / 2;
pcb_rear_y = pcb_y_offset - pcb_L / 2;
pcb_axial_left_x = usb_x - usb_boot_w / 2
    - pcb_axial_stop_port_clear - pcb_axial_stop_w / 2;
pcb_axial_right_x = max(
    usb_x + usb_boot_w / 2
        + pcb_axial_stop_port_clear + pcb_axial_stop_w / 2,
    bat_lead_pair_w / 2 + fdm_rigid_clear + pcb_axial_stop_w / 2
);

// Shared enclosure and fastener coordinates.
inner_x_min = -case_inner_x_half;
inner_x_max = case_inner_x_half;
inner_y_min = case_inner_y_min;
inner_y_max = case_inner_y_max;
inner_z_max = pcb_top_z + top_clear;

outer_x_min = inner_x_min - case_wall_t;
outer_x_max = inner_x_max + case_wall_t;
outer_y_min = inner_y_min - case_wall_t;
outer_y_max = inner_y_max + case_wall_t;
outer_z_min = inner_z_min - case_floor_t;
outer_z_max = inner_z_max;
inner_corner_r = max(0, case_corner_r - case_wall_t);
lid_z_min = outer_z_max;
lid_z_max = lid_z_min + case_lid_t;
brand_y = (outer_y_min + outer_y_max) / 2;

loadcell_notch_x1 = -lc_L / 2 + notch_xA;
loadcell_notch_x2 = -lc_L / 2 + notch_xB;
loadcell_notch_y1 = -lc_W / 2;
loadcell_notch_y2 = lc_W / 2;
screw_x1 = loadcell_notch_x1;
screw_x2 = loadcell_notch_x2;
screw_y1 = loadcell_notch_y1;
screw_y2 = loadcell_notch_y2;

// PCB service envelopes. The solder zone sits below the PCB; the wire race
// continues toward case -X where it remains accessible with the lid removed.
pcb_solder_keepout_x = -pcb_W / 2 + pcb_solder_keepout_w / 2;
pcb_solder_keepout_z = pcb_bottom_z - pcb_solder_keepout_h / 2;
pcb_wire_race_x = -pcb_W / 2 + pcb_wire_exit_l / 2;
pcb_wire_race_l = pcb_wire_exit_l;
pcb_wire_race_y = pcb_y_offset;
pcb_wire_race_z = pcb_bottom_z - pcb_wire_race_d / 2;

assert(battery_bottom_z >= switch_top_z + battery_switch_clear_z - 0.001,
    str("Battery must clear switch. battery_bottom=", battery_bottom_z,
        " switch_top=", switch_top_z, " mm."));
assert(pcb_wire_race_l > 0,
    str("PCB wire race collapsed. length=", pcb_wire_race_l, " mm."));
assert(screw_x1 == loadcell_notch_x1 && screw_x2 == loadcell_notch_x2
    && screw_y1 == loadcell_notch_y1 && screw_y2 == loadcell_notch_y2,
    "Screw centers must remain on all four load-cell notch axes.");

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
