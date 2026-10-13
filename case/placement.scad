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

// The electronics sit in a central pod; full-height end guards enclose the
// rest of the load cell so only the eyes remain exposed.
case_inner_x_half = pod_half_x + clear_x;
guard_inner_x_half = lc_L / 2 + loadcell_guard_clear;
guard_inner_y_half = lc_W / 2 + loadcell_guard_clear;
guard_outer_x_half = guard_inner_x_half + wall_t;
guard_outer_y_half = guard_inner_y_half + wall_t;
// An inner corner radius equal to the clearance keeps that clearance around
// the square load-cell corners.
guard_corner_r = wall_t + loadcell_guard_clear;

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

// Shell bounds shared by the main body and lid.
inner_x_min = -case_inner_x_half;
inner_x_max = case_inner_x_half;
inner_y_min = case_inner_y_min;
inner_y_max = case_inner_y_max;
outer_x_min = inner_x_min - wall_t;
outer_x_max = inner_x_max + wall_t;
outer_y_min = inner_y_min - wall_t;
outer_y_max = inner_y_max + wall_t;
brand_y = (outer_y_min + outer_y_max) / 2;

// A carabiner under load bears on the outer side of the eye ring. Each
// vertical slot is centered there and runs out through the case end, so the
// shank only touches metal and the carabiner curve can leave the case.
eye_x = lc_L / 2 - eye_center_offset;
carabiner_loaded_x = eye_x + (eye_ring_bore_d - carabiner_shank_d) / 2;
carabiner_slot_d = carabiner_shank_d + 2 * carabiner_slot_clear;

assert(guard_inner_x_half > lc_L / 2 && guard_inner_y_half > lc_W / 2,
    "End guards must enclose all four load-cell corners.");
assert(guard_outer_x_half > outer_x_max && guard_outer_y_half < min(-outer_y_min, outer_y_max),
    "End guards must extend the pod in X and stay within its Y span.");
assert(carabiner_shank_d < eye_ring_bore_d && eye_ring_bore_d < eye_d,
    str("Carabiner diameters must satisfy shank < ring bore < eye. Got ",
        carabiner_shank_d, ", ", eye_ring_bore_d, ", ", eye_d, " mm."));
assert(carabiner_slot_d / 2 + loadcell_slot_wall_t < guard_inner_y_half,
    "Carabiner slot walls must leave the load-cell corners covered.");

module rounded_rect_2d(x_min, x_max, y_min, y_max, r) {
    w = x_max - x_min;
    h = y_max - y_min;
    rr = max(0, min(r, min(w, h) / 2 - 0.01));
    if (rr > 0) {
        translate([x_min + rr, y_min + rr])
            offset(r = rr)
                square([w - 2 * rr, h - 2 * rr], center = false);
    } else {
        translate([x_min, y_min])
            square([w, h], center = false);
    }
}

// Plan outline: electronics pod plus end guards, with filleted concave
// corners. inset = wall_t gives the inner cavity.
module case_outline_2d(inset = 0) {
    offset(r = -inset)
        offset(r = -outer_fillet_r)
            offset(delta = outer_fillet_r)
                union() {
                    rounded_rect_2d(outer_x_min, outer_x_max, outer_y_min, outer_y_max, corner_r);
                    rounded_rect_2d(-guard_outer_x_half, guard_outer_x_half,
                        -guard_outer_y_half, guard_outer_y_half, guard_corner_r);
                }
}

module carabiner_slot_2d(x_sign) {
    hull() {
        translate([x_sign * carabiner_loaded_x, 0])
            circle(d = carabiner_slot_d);
        translate([x_sign * (guard_outer_x_half + 1), 0])
            square([0.01, carabiner_slot_d], center = true);
    }
}

module carabiner_slot_wall_2d(x_sign) {
    difference() {
        offset(r = loadcell_slot_wall_t)
            carabiner_slot_2d(x_sign);
        carabiner_slot_2d(x_sign);
    }
}
