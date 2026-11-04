//
// Lid enclosure part
// - corner screw holes aligned with case_main.scad
// - carabiner slot walls that close the electronics bay above the load cell
//

include <placement.scad>
use <pcb.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
// Every lid feature over the load cell stops this far above it, so a printed
// part slightly off size cannot hold the lid open.
loadcell_hold_down_clear = 0.6;

screw_hole_lead_in_d = 3.8; // underside funnel for easier post entry during assembly
screw_hole_lead_in_depth = 1.0;

// Alignment lip (underside) inside the rear wall, behind the battery leads.
// Rear-only so the USB-side connector area stays clear.
align_lip_h = 1.2;
align_lip_t = 1.0;
align_lip_clear = 0.6; // extra fit margin for print tolerances / elephant foot
align_lip_len = 24;

// Battery side walls (lid underside), running parallel to battery length.
battery_side_wall_t = 1.2;
battery_side_wall_l = 24;

// PCB clamps press the bare pcb_clamp_windows, directly above the support
// columns, so the board cannot rattle. The preload is one 0.2 mm layer: the
// clamps end on a layer boundary and the lid flexes to absorb it.
pcb_top_clamp_preload = 0.1;
// Clearance to the B.Cu parts around each window; larger than the rear stop
// clearance, so the stops engage before a part reaches a clamp.
pcb_top_clamp_inset = 0.3;

// Tabs behind the board's rear edge take USB-C insertion loads, one each side
// of the ESP32 antenna overhang. The chamfer on each tab's board side pushes
// a board that slid back during assembly forward as the lid closes.
pcb_rear_stop_x = [8.5, 13.5]; // |x| span
pcb_rear_stop_t = 2.4;
pcb_rear_stop_below = 1.0; // reach below the board underside
pcb_rear_stop_chamfer = 0.8;

status_led_view_d = 2.6;
rgb_led_view_d = 5.8;
led_view_chamfer_depth = 0.8;
led_view_chamfer_delta = 0.6;

print_layout = false; // true: flip lid for support-free printing (outer top face on bed)

/*** Derived placement ***/
hold_down_target_z = loadcell_top_z + loadcell_hold_down_clear;


battery_side_wall_x = battery_bay_half_w + battery_side_wall_t / 2;
// Extend through the lid thickness so the walls fuse into the roof; their
// lower ends also stop the load cell from lifting.
battery_side_wall_h = lid_z_max - hold_down_target_z;
status_led_view_x = status_led_x;
status_led_view_y = pcb_y_offset + status_led_y;
rgb_led_view_x = rgb_led_x;
rgb_led_view_y = pcb_y_offset + rgb_led_y;
pcb_top_clamp_h = lid_z_min - (pcb_board_top_z - pcb_top_clamp_preload);
// Over the main-body pads, inset so they stay there wherever the lid seats.
battery_hold_down_x = battery_pad_x + [1, -1] * lid_seat_play;
battery_hold_down_y = battery_pad_y + [1, -1] * lid_seat_play;
battery_hold_down_z_min = battery_top_z - battery_hold_down_preload;
pcb_rear_stop_z_min = pcb_board_bottom_z - pcb_rear_stop_below;

assert(screw_head_d < screw_countersink_d && screw_d < screw_clear_d,
    "The screw head and shank must clear the countersink and lid hole.");
assert(countersink_depth + screw_hole_lead_in_depth <= lid_t - 0.3,
    str("The countersink and lead-in must leave a straight lid hole. countersink=",
        countersink_depth, " mm."));
assert(screw_hole_lead_in_d >= screw_clear_d,
    str("screw_hole_lead_in_d must be >= screw_clear_d. lead_in_d=", screw_hole_lead_in_d,
        " clear_d=", screw_clear_d));
assert(screw_hole_lead_in_depth >= 0 && screw_hole_lead_in_depth <= lid_t,
    str("screw_hole_lead_in_depth must be within [0, lid_t]. depth=", screw_hole_lead_in_depth,
        " lid_t=", lid_t));
assert(battery_side_wall_x + battery_side_wall_t / 2 <= carabiner_slot_inner_x + 0.001,
    str("Battery side walls reach into the carabiner slots by ",
        battery_side_wall_x + battery_side_wall_t / 2 - carabiner_slot_inner_x, " mm (X)."));
assert(pcb_rear_stop_x[0] >= max(-pcb_module_rect[0], pcb_module_rect[1]) + 1
    && pcb_rear_stop_x[1] <= pcb_W / 2,
    "PCB rear stops must sit behind the board, clear of the antenna overhang.");
assert(pcb_rear_y - pcb_rear_stop_clear - pcb_rear_stop_t >= battery_front_y + 1,
    "PCB rear stops must stand in front of the battery.");
assert(battery_front_stop_clear > lid_seat_play,
    "The battery front stop must clear the battery wherever the lid seats.");
for (x = battery_front_stop_x)
    assert(x[1] - x[0] >= 3, "Each battery front stop must be at least 3 mm wide.");
assert(pcb_rear_stop_z_min + pcb_rear_stop_chamfer <= pcb_board_bottom_z,
    "PCB rear stops must bear on the full board edge above their chamfer.");
assert(pcb_top_clamp_inset > pcb_rear_stop_clear,
    "PCB rear stops must engage before a B.Cu part reaches a clamp.");
assert(battery_side_wall_l <= inner_y_max - inner_y_min,
    str("Battery side wall length exceeds inner cavity span by ",
        battery_side_wall_l - (inner_y_max - inner_y_min), " mm (Y)."));
assert(pcb_top_clamp_h > 0,
    "PCB clamps must reach down from the lid.");
for (w = pcb_clamp_windows)
    assert(w[0] >= -pcb_W / 2 && w[1] <= pcb_W / 2 && w[2] >= -pcb_L / 2 && w[3] <= pcb_L / 2,
        str("PCB clamp window must stay on the board: ", w));
assert(led_view_chamfer_depth > 0 && led_view_chamfer_depth <= lid_t,
    str("led_view_chamfer_depth must be within (0, lid_t]. depth=", led_view_chamfer_depth,
        " lid_t=", lid_t));
assert(status_led_view_x - status_led_view_d / 2 >= -pcb_W / 2 - 0.001
    && status_led_view_x + status_led_view_d / 2 <= pcb_W / 2 + 0.001
    && status_led_y - status_led_view_d / 2 >= -pcb_L / 2 - 0.001
    && status_led_y + status_led_view_d / 2 <= pcb_L / 2 + 0.001,
    "Status LED viewing hole must stay within PCB footprint.");
assert(rgb_led_view_x - rgb_led_view_d / 2 >= -pcb_W / 2 - 0.001
    && rgb_led_view_x + rgb_led_view_d / 2 <= pcb_W / 2 + 0.001
    && rgb_led_y - rgb_led_view_d / 2 >= -pcb_L / 2 - 0.001
    && rgb_led_y + rgb_led_view_d / 2 <= pcb_L / 2 + 0.001,
    "RGB LED viewing hole must stay within PCB footprint.");

module corner_holes(d, z0, z1) {
    each_corner((z0 + z1) / 2)
        cylinder(d = d, h = z1 - z0 + 0.2, center = true);
}

// Runs 0.1 mm past the lid top at the same 45 degree slope.
module corner_countersinks() {
    each_corner(lid_z_max - countersink_depth)
        cylinder(d1 = screw_clear_d, d2 = screw_countersink_d + 0.2, h = countersink_depth + 0.1);
}

module corner_hole_lead_ins(d0, d1, depth) {
    each_corner(lid_z_min + depth / 2)
        cylinder(d1 = d0, d2 = d1, h = depth + 0.2, center = true);
}

module lid_screw_shank_fit_probe() {
    corner_holes(screw_d, lid_z_min - align_lip_h - 0.2, lid_z_max + 0.2);
}

// Seated countersunk heads, raised by dz.
module lid_screw_head_probe(dz) {
    each_corner(lid_z_max - screw_head_sink - screw_head_h + dz)
        cylinder(d1 = screw_d, d2 = screw_head_d, h = screw_head_h);
}

// grow widens each hole by that much on every side.
module led_view_hole(x, y, d, grow) {
    translate([x, y, lid_z_min - 0.1])
        cylinder(d = d + 2 * grow, h = lid_t + 0.3, center = false);

    translate([x, y, lid_z_max - led_view_chamfer_depth])
        cylinder(
            d1 = d + 2 * grow,
            d2 = d + 2 * (led_view_chamfer_delta + grow),
            h = led_view_chamfer_depth + 0.2,
            center = false
        );
}

module led_view_holes(grow = 0) {
    led_view_hole(status_led_view_x, status_led_view_y, status_led_view_d, grow);
    led_view_hole(rgb_led_view_x, rgb_led_view_y, rgb_led_view_d, grow);
}

module lid_carabiner_slot_walls() {
    wall_z_max = lid_z_min + internal_feature_embed;

    // Close the electronics bay above the load cell around each slot.
    translate([0, 0, hold_down_target_z])
        linear_extrude(height = wall_z_max - hold_down_target_z)
            intersection() {
                union() {
                    carabiner_slot_wall_2d(-1);
                    carabiner_slot_wall_2d(1);
                }
                case_outline_2d(wall_t + slot_wall_fit);
            }
}

module lid_carabiner_slot_cuts() {
    translate([0, 0, lid_z_min - 0.1])
        linear_extrude(height = lid_t + 0.2)
            for (x_sign = [-1, 1])
                carabiner_slot_2d(x_sign);
}

module lid_alignment_lip() {
    lip_y = inner_y_min + align_lip_clear;
    box(span(0, align_lip_len / 2), [lip_y, lip_y + align_lip_t],
        [lid_z_min - align_lip_h, lid_z_min + internal_feature_embed]);
}

module battery_side_walls() {
    wall_z = hold_down_target_z + battery_side_wall_h / 2;

    for (x_sign = [-1, 1])
        translate([x_sign * battery_side_wall_x, 0, wall_z])
            cube([battery_side_wall_t, battery_side_wall_l, battery_side_wall_h], center = true);
}

module pcb_top_clamps() {
    translate([0, pcb_y_offset, pcb_board_top_z - pcb_top_clamp_preload])
        linear_extrude(height = pcb_top_clamp_h + internal_feature_embed)
            for (w = pcb_clamp_windows)
                offset(delta = -pcb_top_clamp_inset)
                    pcb_rect_2d(w);
}

// Clamp the battery onto its rear pads, so the clamp load goes into the floor
// and not the load cell.
module battery_hold_downs() {
    for (s = [-1, 1])
        box(s * battery_hold_down_x, battery_hold_down_y,
            [battery_hold_down_z_min, lid_z_min + internal_feature_embed]);
}

// Wall in front of the battery, so it cannot slide forward off its clamped
// rear pads. It reaches down to the battery's mid-height, high above the gauge
// cover.
module battery_front_stop() {
    for (x = battery_front_stop_x)
        box(x, [battery_front_stop_y, battery_front_stop_y + battery_front_stop_t],
            [battery_bottom_z + bat_T / 2, lid_z_min + internal_feature_embed]);
}

module pcb_rear_stops() {
    w = pcb_rear_stop_x[1] - pcb_rear_stop_x[0];
    y0 = pcb_rear_y - pcb_rear_stop_clear - pcb_rear_stop_t;
    z_chamfer = pcb_rear_stop_z_min + pcb_rear_stop_chamfer;
    for (s = [-1, 1])
        translate([s > 0 ? pcb_rear_stop_x[0] : -pcb_rear_stop_x[1], y0, 0])
            hull() {
                translate([0, 0, z_chamfer])
                    cube([w, pcb_rear_stop_t, lid_z_min - z_chamfer + internal_feature_embed]);
                translate([0, 0, pcb_rear_stop_z_min])
                    cube([w, pcb_rear_stop_t - pcb_rear_stop_chamfer, 0.01]);
            }
}

module brand_engrave_lid() {
    // Carved on outer top face (same plane as load cell), horizontal and centered.
    translate([0, brand_y, lid_z_max - brand_depth - 0.1])
        linear_extrude(height = brand_depth + 0.2, center = false)
            rotate([0, 0, 90])
                text(brand_text, size = brand_size, font = brand_font, halign = "center", valign = "center");
}

module lid_part() {
    difference() {
        union() {
            translate([0, 0, lid_z_min])
                linear_extrude(height = lid_t)
                    case_outline_2d();
            lid_alignment_lip();
            battery_side_walls();
            pcb_top_clamps();
            pcb_rear_stops();
            battery_hold_downs();
            battery_front_stop();
            lid_carabiner_slot_walls();
        }
        corner_holes(screw_clear_d, lid_z_min - align_lip_h, lid_z_max);
        corner_hole_lead_ins(screw_hole_lead_in_d, screw_clear_d, screw_hole_lead_in_depth);
        corner_countersinks();
        led_view_holes();
        lid_carabiner_slot_cuts();
        // Brand engraving on outer top face.
        brand_engrave_lid();
    }
}

module lid_part_print_layout() {
    translate([0, 0, lid_z_max])
        rotate([180, 0, 0])
            lid_part();
}

if (print_layout) {
    lid_part_print_layout();
} else {
    lid_part();
}
