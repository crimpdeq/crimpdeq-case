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

// The electronics sit in a central pod; the facets enclose the rest of the
// load cell so only the eyes remain exposed.
case_inner_x_half = pod_half_x + clear_x;

// Revision 3 is shorter than the battery and load cell, so derive the cavity
// and component positions from every front envelope instead of the PCB.
case_inner_y_max = max(
    pcb_L / 2 + front_clear,
    lc_W / 2 + switch_wire_bend + switch_d
);
switch_y = case_inner_y_max - switch_d / 2;
pcb_y_offset = case_inner_y_max - pcb_front_gap - pcb_L / 2;
// The battery front lines up with the load-cell front edge, behind the
// switch wire bend.
battery_y_offset = lc_W / 2 - bat_L / 2;
// The plan is symmetric about the load cell, so the rear wall mirrors the
// front one and every rear envelope must fit inside it.
case_inner_y_min = -case_inner_y_max;

battery_bottom_z = loadcell_top_z + loadcell_to_battery_gap;
battery_top_z = battery_bottom_z + bat_T;
battery_front_y = battery_y_offset + bat_L / 2;
// +X rear pad; the -X one mirrors it.
battery_pad_x = [bat_W / 2 - battery_pad_inset - battery_pad_size, bat_W / 2 - battery_pad_inset];
battery_pad_y0 = battery_y_offset - bat_L / 2 + battery_pad_inset;
battery_pad_y = [battery_pad_y0, battery_pad_y0 + battery_pad_size];

// Only the low F.Cu parts sit over the battery; the taller USB-C connector
// hangs in front of it.
pcb_board_bottom_z = battery_top_z + battery_to_pcb_gap + pcb_bottom_parts_h;
pcb_board_top_z = pcb_board_bottom_z + pcb_board_t;
pcb_bottom_z = pcb_board_bottom_z - usb_h;
pcb_top_z = pcb_board_top_z + pcb_module_h;
pcb_rear_y = pcb_y_offset - pcb_L / 2;
usb_rear_y = pcb_y_offset + usb_y - usb_d / 2;

// USB-C receptacle, its front-wall opening, and the cable overmold pocket.
usb_center_z = pcb_board_bottom_z - usb_h / 2;
usb_face_y = pcb_y_offset + usb_y + usb_d / 2; // receptacle mating face
usb_hole_w = usb_w + 2 * usb_hole_clear;
usb_hole_h = usb_h + 2 * usb_hole_clear;
usb_pocket_floor_y = usb_face_y + usb_overmold_stop_gap;
usb_pocket_w = usb_overmold_w + 2 * usb_pocket_clear;
usb_pocket_h = usb_overmold_h + 2 * usb_pocket_clear;

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
switch_grip_y = outer_y_max - switch_grip_len; // inner end of the switch opening
brand_y = (outer_y_min + outer_y_max) / 2;

// Hexagonal plan: flat front and rear walls and a point at each end, where
// the carabiner slot leaves the case. The facets are the tightest lines at
// case_facet_angle that keep the load-cell corners inside the cavity.
facet_n = [sin(case_facet_angle), cos(case_facet_angle)]; // outward normal, +X/+Y facet
facet_k = facet_n * [lc_L / 2, lc_W / 2] + loadcell_guard_clear + wall_t;
case_tip_x = facet_k / facet_n[0];
case_corner_x = (facet_k - facet_n[1] * outer_y_max) / facet_n[0];

// Each screw sits screw_edge_inset inside both faces of its corner, so the
// post merges into the front or rear wall and the facet wall.
screw_y = outer_y_max - screw_edge_inset;
screw_x = (facet_k - screw_edge_inset - facet_n[1] * screw_y) / facet_n[0];
screw_centers = [
    [-screw_x, -screw_y], [screw_x, -screw_y],
    [-screw_x, screw_y], [screw_x, screw_y]
];

// Each eye is reached through a vertical U-slot round the eye that runs out
// through the case end, so the carabiner curve can leave the case. Its
// inboard edge is the battery bay wall. A carabiner under load bears on the
// outer side of the eye ring.
eye_x = lc_L / 2 - eye_center_offset;
carabiner_loaded_x = eye_x + (eye_ring_bore_d - carabiner_shank_d) / 2;
carabiner_slot_d = eye_d + 2 * eye_slot_clear;
carabiner_slot_inner_x = bat_W / 2 + battery_side_clear + loadcell_slot_wall_t;

assert(case_inner_y_min <= min(
        -lc_W / 2 - rear_clear,
        pcb_y_offset - pcb_L / 2 - rear_clear,
        battery_y_offset - bat_L / 2 - battery_rear_gap),
    "The mirrored rear wall must enclose the load cell, PCB and battery.");
assert(switch_y - switch_d / 2 - switch_wire_bend >= max(lc_W / 2, battery_front_y),
    "The switch wire bend must stay clear of the load cell and battery.");
assert(battery_pad_y[1] < -lc_W / 2,
    "Battery pads and their lid hold-downs must stay behind the load cell.");
assert(usb_rear_y >= battery_front_y + 0.5,
    "The USB-C connector must hang in front of the battery.");
assert(case_corner_x > case_inner_x_half && case_corner_x < case_tip_x,
    str("Facets must leave flat front and rear walls wider than the bay. corner_x=", case_corner_x, " mm."));
assert(carabiner_shank_d < eye_ring_bore_d && eye_ring_bore_d < eye_d,
    str("Carabiner diameters must satisfy shank < ring bore < eye. Got ",
        carabiner_shank_d, ", ", eye_ring_bore_d, ", ", eye_d, " mm."));
assert(carabiner_slot_inner_x < eye_x - carabiner_shank_d / 2,
    str("A carabiner centered in the eye must clear the slot's inboard edge. inner_x=",
        carabiner_slot_inner_x, " mm."));
assert(carabiner_slot_d / 2 + loadcell_slot_wall_t < lc_W / 2 + loadcell_guard_clear,
    "Carabiner slot walls must leave the load-cell corners covered.");

// Axis-aligned box spanning the [min, max] pairs x, y and z.
module box(x, y, z) {
    translate([min(x), min(y), min(z)])
        cube([abs(x[1] - x[0]), abs(y[1] - y[0]), abs(z[1] - z[0])]);
}

module each_corner(z_pos) {
    for (c = screw_centers)
        translate([c[0], c[1], z_pos])
            children();
}

// inset = wall_t gives the inner cavity.
module case_outline_2d(inset = 0) {
    T = case_tip_x;
    C = case_corner_x;
    offset(delta = -inset)
        polygon([
            [T, 0], [C, outer_y_max], [-C, outer_y_max],
            [-T, 0], [-C, outer_y_min], [C, outer_y_min]
        ]);
}

module carabiner_slot_2d(x_sign) {
    intersection() {
        hull() {
            translate([x_sign * eye_x, 0])
                circle(d = carabiner_slot_d);
            translate([x_sign * (case_tip_x + 1), 0])
                square([0.01, carabiner_slot_d], center = true);
        }
        translate([x_sign * (carabiner_slot_inner_x + case_tip_x + 2) / 2, 0])
            square([case_tip_x + 2 - carabiner_slot_inner_x, carabiner_slot_d + 1], center = true);
    }
}

module carabiner_slot_wall_2d(x_sign) {
    difference() {
        offset(r = loadcell_slot_wall_t)
            carabiner_slot_2d(x_sign);
        carabiner_slot_2d(x_sign);
    }
}

// Main-body fins on the bay side of the four lid slot-wall ends, fused to the
// facets and reaching slot_seal_overlap past each end.
slot_seal_fin_y = carabiner_slot_d / 2 + loadcell_slot_wall_t + slot_wall_fit;

module slot_seal_fins_2d() {
    intersection() {
        difference() {
            case_outline_2d();
            case_outline_2d(wall_t + slot_wall_fit + slot_seal_overlap);
        }
        for (y_sign = [-1, 1])
            translate([-case_tip_x, y_sign > 0 ? slot_seal_fin_y : -slot_seal_fin_y - loadcell_slot_wall_t])
                square([2 * case_tip_x, loadcell_slot_wall_t]);
    }
}
