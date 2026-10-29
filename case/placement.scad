//
// Shared assembly placement derived from component dimensions
// Units: mm
//

include <dimensions.scad>

// Vertical stack: floor, the load cell on its pads (cover down), the battery
// flat on the plate, then the board over the battery.
floor_top_z = floor_t;
loadcell_bottom_z = floor_top_z + gauge_cover_h + loadcell_cover_clear;
loadcell_top_z = loadcell_bottom_z + lc_T;
loadcell_center_z = loadcell_bottom_z + lc_T / 2;
battery_bottom_z = loadcell_top_z;
battery_top_z = battery_bottom_z + bat_T;
pcb_board_bottom_z = battery_top_z + battery_to_pcb_gap + pcb_bottom_parts_h;
pcb_board_top_z = pcb_board_bottom_z + pcb_board_t;
usb_top_z = pcb_board_top_z + usb_h;
usb_center_z = pcb_board_top_z + usb_h / 2;
pcb_module_top_z = pcb_board_top_z + pcb_module_h;
// The main body ends and the lid starts at the seam.
seam_z = max(usb_top_z + usb_lid_clear, pcb_module_top_z + top_clear);
lid_top_z = seam_z + lid_t;

// The battery front lines up with the load-cell front edge.
battery_front_y = -lc_W / 2;
battery_y = battery_front_y + bat_L / 2;
battery_rear_y = battery_front_y + bat_L;
// The board's pad end hangs in front of the battery, so every wire reaches its
// pad from below.
pcb_pad_y_max = max([for (p = pcb_cable_pads) p[1]]);
pcb_y = battery_front_y - cable_pad_battery_clear - wire_d / 2 - pcb_pad_y_max;
pcb_front_y = pcb_y - pcb_L / 2;
pcb_rear_y = pcb_y + pcb_L / 2;

inner_front_y = pcb_front_y - pcb_front_gap;
outer_front_y = inner_front_y - wall_t;
inner_end_x = lc_L / 2 + loadcell_guard_clear;
// The end walls carry the grooves for the lid slot-wall ends.
end_groove_x = inner_end_x + slot_wall_fit + slot_seal_overlap;
outer_end_x = end_groove_x + wall_t;

// The plan is symmetric about both axes: the rear wall mirrors the front one,
// and the band behind the battery mirrors the board's front band.
inner_rear_y = -inner_front_y;
outer_rear_y = -outer_front_y;
notch_x = lc_L / 2 - notch_xA;

// Front-wall switch over the load cell's front-right corner, beside the
// battery leads' bend. The model spans its measured depth from the outer face.
switch_x = bat_W / 2 + battery_lead_bend + switch_clear + switch_w / 2;
switch_z = loadcell_top_z + switch_loadcell_clear + switch_h / 2;
switch_rear_y = outer_front_y + switch_depth;
switch_grip_y = outer_front_y + switch_grip_len; // inner end of the opening

// 45 degree chamfers at the four corners: |x| +/- y = chamfer_k. The inner
// chamfers pass outside the guarded load-cell corners; the flat front wall
// carries the switch flange.
chamfer_wall_k = wall_t * sqrt(2);
chamfer_k = max(
    lc_L / 2 + lc_W / 2 + 2 * loadcell_guard_clear + chamfer_wall_k,
    switch_x + switch_w / 2 + switch_flange + case_corner_r - outer_front_y
);
inner_chamfer_k = chamfer_k - chamfer_wall_k;

// The screws sit screw_edge_inset inside the front and rear faces, beside the
// board; the front posts guide its long edges.
screw_x = pcb_W / 2 + pcb_guide_clear + screw_post_d / 2;
screw_y = outer_rear_y - screw_edge_inset;
screw_centers = [[-screw_x, -screw_y], [screw_x, -screw_y], [-screw_x, screw_y], [screw_x, screw_y]];

// USB-C receptacle, its front-wall opening and the cable overmold pocket.
usb_x = (usb_rect[0] + usb_rect[1]) / 2;
usb_w = usb_rect[1] - usb_rect[0];
usb_face_y = pcb_y + usb_rect[2]; // receptacle mating face
usb_hole_w = usb_w + 2 * usb_hole_clear;
usb_pocket_floor_y = usb_face_y - usb_overmold_stop_gap;
usb_pocket_w = usb_overmold_w + 2 * usb_pocket_clear;
usb_pocket_h = usb_overmold_h + 2 * usb_pocket_clear;
usb_pocket_z_min = usb_center_z - usb_pocket_h / 2;

// Each eye is reached through a vertical U-slot round the eye that runs out
// through the case end, so the carabiner curve can leave the case. Its
// inboard edge is the battery bay wall. A carabiner under load bears on the
// outer side of the eye ring.
eye_x = lc_L / 2 - eye_center_offset;
carabiner_loaded_x = eye_x + (eye_ring_bore_d - carabiner_shank_d) / 2;
carabiner_slot_d = eye_d + 2 * eye_slot_clear;
carabiner_slot_inner_x = bat_W / 2 + battery_side_clear + loadcell_slot_wall_t;
slot_wall_outer_y = carabiner_slot_d / 2 + loadcell_slot_wall_t;

assert(screw_y + screw_post_d / 2 > inner_rear_y,
    "Screw posts must merge into the front and rear walls.");
assert(screw_y - screw_post_d / 2 > battery_rear_y + battery_stop_clear,
    "The rear screw posts must stay behind the battery.");
assert(inner_rear_y > battery_rear_y + battery_stop_clear,
    "The rear wall must clear the battery.");
assert(switch_rear_y + switch_wire_bend < -carabiner_slot_d / 2 - loadcell_slot_wall_t,
    "The switch and its wire bend must stay in front of the carabiner slot walls.");
assert(chamfer_k - outer_rear_y > 0,
    "The chamfers must leave flat front and rear walls.");
assert(chamfer_k - outer_end_x > slot_wall_outer_y + slot_wall_fit,
    "The chamfers must leave end walls round the carabiner slot exits and grooves.");
assert(carabiner_shank_d < eye_ring_bore_d && eye_ring_bore_d < eye_d,
    str("Carabiner diameters must satisfy shank < ring bore < eye. Got ",
        carabiner_shank_d, ", ", eye_ring_bore_d, ", ", eye_d, " mm."));
assert(carabiner_slot_inner_x < eye_x - carabiner_shank_d / 2,
    str("A carabiner centered in the eye must clear the slot's inboard edge. inner_x=",
        carabiner_slot_inner_x, " mm."));
assert(slot_wall_outer_y + slot_wall_fit < lc_W / 2,
    "Carabiner slot walls must leave the load-cell corners covered.");
assert(notch_x - notch_d / 2 > bat_W / 2 + battery_side_clear,
    "The notch pins must clear the battery.");
assert(usb_pocket_floor_y - outer_front_y > 0 && inner_front_y - usb_pocket_floor_y >= usb_pocket_min_web,
    str("USB-C pocket must leave a front-wall web. web=", inner_front_y - usb_pocket_floor_y, " mm."));

function span(center, half) = [center - half, center + half];

// Axis-aligned box spanning the [min, max] pairs x, y and z.
module box(x, y, z) {
    translate([min(x), min(y), min(z)])
        cube([abs(x[1] - x[0]), abs(y[1] - y[0]), abs(z[1] - z[0])]);
}

module each_screw(z_pos) {
    for (c = screw_centers)
        translate([c[0], c[1], z_pos])
            children();
}

// Octagonal plan with flat front, rear and end walls and 45 degree chamfers,
// symmetric about both axes.
function plan_points(half_y, half_x, k) = [
    [half_x, half_x - k], [half_x, k - half_x], [k - half_y, half_y], [half_y - k, half_y],
    [-half_x, k - half_x], [-half_x, half_x - k], [half_y - k, -half_y], [k - half_y, -half_y]
];

module case_outline_2d() {
    offset(r = case_corner_r)
        offset(delta = -case_corner_r)
            polygon(plan_points(outer_rear_y, outer_end_x, chamfer_k));
}

module cavity_2d() {
    polygon(plan_points(inner_rear_y, inner_end_x, inner_chamfer_k));
}

module carabiner_slot_2d(x_sign) {
    intersection() {
        hull() {
            translate([x_sign * eye_x, 0])
                circle(d = carabiner_slot_d);
            translate([x_sign * (outer_end_x + 1), 0])
                square([0.01, carabiner_slot_d], center = true);
        }
        translate([x_sign * (carabiner_slot_inner_x + outer_end_x + 2) / 2, 0])
            square([outer_end_x + 2 - carabiner_slot_inner_x, carabiner_slot_d + 1], center = true);
    }
}

module carabiner_slot_wall_2d(x_sign) {
    difference() {
        offset(r = loadcell_slot_wall_t)
            carabiner_slot_2d(x_sign);
        carabiner_slot_2d(x_sign);
    }
}

// Lid slot walls stop slot_wall_fit short of the main body, except where
// their straight ends reach into the end-wall grooves.
module lid_slot_wall_bound_2d() {
    offset(delta = -slot_wall_fit)
        cavity_2d();
    square([2 * (end_groove_x - slot_wall_fit), 2 * slot_wall_outer_y], center = true);
}

// The grooves in each end wall that take the lid slot-wall ends. Their slot
// sides open into the slot.
module end_wall_grooves() {
    for (x_sign = [-1, 1], y_sign = [-1, 1])
        box(x_sign * [inner_end_x - 0.1, end_groove_x],
            y_sign * [carabiner_slot_d / 2 - 0.1, slot_wall_outer_y + slot_wall_fit],
            [loadcell_top_z, seam_z + 0.1]);
}

// Prism along Y from y0 to y1 with a rounded profile centered on the USB-C
// receptacle, from z0 to z1 in the front-wall (XZ) plane.
module usb_prism(y0, y1, w, z0, z1, r) {
    translate([0, y1, 0])
        rotate([90, 0, 0])
            linear_extrude(height = y1 - y0)
                translate([usb_x - w / 2 + r, z0 + r])
                    offset(r = r)
                        square([w - 2 * r, z1 - z0 - 2 * r]);
}

// Opening in the front-wall web round the receptacle. It runs out through the
// top of the main body, so the receptacle drops in with the board.
module usb_hole_cut() {
    box([usb_x - usb_hole_w / 2, usb_x + usb_hole_w / 2],
        [usb_pocket_floor_y - 0.01, inner_front_y + 0.1],
        [pcb_board_top_z - usb_hole_clear, seam_z + 0.1]);
}

// Overmold pocket in front of the web. It sits higher than the seam allows, so
// it runs out through the lid as a notch.
module usb_pocket_cut() {
    usb_prism(outer_front_y - 0.1, usb_pocket_floor_y, usb_pocket_w,
        usb_pocket_z_min, lid_top_z + 2, usb_overmold_corner_r + usb_pocket_clear);
}
