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

// The electronics sit in a central pod; the end faces enclose the rest of
// the load cell so only the eyes remain exposed.
case_inner_x_half = pod_half_x + clear_x;
guard_inner_x_half = lc_L / 2 + loadcell_guard_clear;
guard_inner_y_half = lc_W / 2 + loadcell_guard_clear;
guard_outer_x_half = guard_inner_x_half + wall_t;

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

// Only the low F.Cu parts sit over the battery; the taller USB-C connector
// hangs in front of it.
pcb_board_bottom_z = battery_top_z + battery_to_pcb_gap + pcb_bottom_parts_h;
pcb_board_top_z = pcb_board_bottom_z + pcb_board_t;
pcb_bottom_z = pcb_board_bottom_z - usb_h;
pcb_top_z = pcb_board_top_z + pcb_module_h;
pcb_rear_y = pcb_y_offset - pcb_L / 2;
usb_rear_y = pcb_y_offset + usb_y - usb_d / 2;

switch_h_eff = (abs(switch_rot_y) % 180 == 90) ? switch_w : switch_h;
switch_x = 0;
switch_z = inner_z_min + switch_h_eff / 2;

// Shell bounds shared by the main body and lid.
inner_x_min = -case_inner_x_half;
inner_x_max = case_inner_x_half;
inner_y_min = case_inner_y_min;
inner_y_max = case_inner_y_max;
outer_y_min = inner_y_min - wall_t;
outer_y_max = inner_y_max + wall_t;
brand_y = (outer_y_min + outer_y_max) / 2;

// Faceted plan: flat front and rear walls, flat end walls, and one facet per
// corner. The facets are the tightest lines at case_facet_angle that keep the
// load-cell corners inside the cavity.
facet_n = [sin(case_facet_angle), cos(case_facet_angle)]; // outward normal, +X/+Y corner
facet_k = facet_n * [lc_L / 2, lc_W / 2] + loadcell_guard_clear + wall_t;
front_face_x = (facet_k - facet_n[1] * outer_y_max) / facet_n[0];
rear_face_x = (facet_k + facet_n[1] * outer_y_min) / facet_n[0];
end_face_y_max = (facet_k - facet_n[0] * guard_outer_x_half) / facet_n[1];
end_face_y_min = -end_face_y_max;

// Each screw sits one head radius plus a shell inside its facet, so the post
// merges into the facet wall.
function facet_screw_x(y) =
    (facet_k - screw_head_d / 2 - screw_head_wall - facet_n[1] * abs(y)) / facet_n[0];
screw_y1 = outer_y_min + screw_corner_inset;
screw_y2 = outer_y_max - screw_corner_inset;
screw_x_front = facet_screw_x(screw_y2);
screw_x_rear = facet_screw_x(screw_y1);
screw_centers = [
    [-screw_x_rear, screw_y1], [screw_x_rear, screw_y1],
    [-screw_x_front, screw_y2], [screw_x_front, screw_y2]
];

// A carabiner under load bears on the outer side of the eye ring. Each
// vertical slot is centered there and runs out through the case end, so the
// shank only touches metal and the carabiner curve can leave the case.
eye_x = lc_L / 2 - eye_center_offset;
carabiner_loaded_x = eye_x + (eye_ring_bore_d - carabiner_shank_d) / 2;
carabiner_slot_d = carabiner_shank_d + 2 * carabiner_slot_clear;

assert(guard_inner_x_half > lc_L / 2 && guard_inner_y_half > lc_W / 2,
    "End guards must enclose all four load-cell corners.");
assert(usb_rear_y >= battery_front_y + 0.5,
    "The USB-C connector must hang in front of the battery.");
assert(front_face_x > 0 && front_face_x < guard_outer_x_half
    && rear_face_x > 0 && rear_face_x < guard_outer_x_half,
    str("Facets must leave flat front and rear walls. front=", front_face_x, " rear=", rear_face_x, " mm."));
assert(end_face_y_max > carabiner_slot_d / 2 && -end_face_y_min > carabiner_slot_d / 2,
    "Facets must leave end walls beside each carabiner slot.");
assert(carabiner_shank_d < eye_ring_bore_d && eye_ring_bore_d < eye_d,
    str("Carabiner diameters must satisfy shank < ring bore < eye. Got ",
        carabiner_shank_d, ", ", eye_ring_bore_d, ", ", eye_d, " mm."));
assert(carabiner_slot_d / 2 + loadcell_slot_wall_t < guard_inner_y_half,
    "Carabiner slot walls must leave the load-cell corners covered.");

module each_corner(z_pos) {
    for (c = screw_centers)
        translate([c[0], c[1], z_pos])
            children();
}

// inset = wall_t gives the inner cavity.
module case_outline_2d(inset = 0) {
    E = guard_outer_x_half;
    offset(delta = -inset)
        polygon([
            [E, end_face_y_min], [E, end_face_y_max],
            [front_face_x, outer_y_max], [-front_face_x, outer_y_max],
            [-E, end_face_y_max], [-E, end_face_y_min],
            [-rear_face_x, outer_y_min], [rear_face_x, outer_y_min]
        ]);
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
