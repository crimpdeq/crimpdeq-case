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
loadcell_hold_down_clear = 0.6;
slot_wall_fit = 0.2; // gap between lid slot walls and the main-body walls

screw_clear_d = 3.0; // slightly looser clearance so the lid seats more easily on the posts
screw_hole_lead_in_d = 3.8; // underside funnel for easier post entry during assembly
screw_hole_lead_in_depth = 1.0;
screw_fit_shank_d = 2.6; // fit-check envelope for an M2.5 screw shank through the lid
screw_fit_head_d = 5.0; // fit-check envelope for a typical M2.5 pan/button head
screw_fit_head_h = 1.6;

// Alignment tabs (underside) that register in the main cavity.
// Intentionally rear-only so the USB-side connector area stays clear.
align_lip_enable = true;
align_lip_h = 1.2;
align_lip_t = 1.0;
align_lip_clear = 0.6; // extra fit margin for print tolerances / elephant foot
align_lip_front_back_len = 24;

// Battery side walls (lid underside), running parallel to battery length.
battery_side_wall_enable = true;
battery_side_wall_t = 1.2;
battery_side_wall_l = 24;

// PCB clamps press the bare pcb_clamp_windows, directly above the support columns.
pcb_top_clamp_clear = 0.10;
pcb_top_clamp_inset = 0.2; // clearance to the B.Cu parts around each window

// Tabs behind the board's rear edge take USB-C insertion loads, one each side
// of the ESP32 antenna overhang.
pcb_rear_stop_x = [8.5, 13.5]; // |x| span
pcb_rear_stop_t = 2.0;
pcb_rear_stop_clear = 0.25;
pcb_rear_stop_below = 0.5; // reach below the board underside

internal_feature_embed = 0.15; // overlap underside features into the roof for a fused STL

status_led_view_d = 2.6;
rgb_led_view_d = 5.8;
led_view_chamfer_depth = 0.8;
led_view_chamfer_delta = 0.6;

brand_text = "Crimpdeq";
brand_font = "Liberation Sans:style=Bold"; // bundled with OpenSCAD
brand_size = 9.5;
brand_depth = 0.8;
brand_x = 0;
print_layout = false; // true: flip lid for support-free printing (outer top face on bed)

/*** Derived placement ***/
inner_z_max = pcb_top_z + top_clear;
outer_z_max = inner_z_max;

lid_z_min = outer_z_max;
lid_z_max = lid_z_min + lid_t;

hold_down_target_z = loadcell_top_z + loadcell_hold_down_clear;

head_recess_depth = screw_head_recess;
// The rear lip sits behind the PCB, above the battery.
align_lip_h_eff = align_lip_enable ? max(0, min(align_lip_h, lid_z_min - battery_top_z - 0.4)) : 0;
battery_side_wall_x = bat_W / 2 + battery_side_clear + battery_side_wall_t / 2;
// Extend through the lid thickness so the walls fuse into the roof; their
// lower ends also stop the load cell from lifting.
battery_side_wall_h = lid_z_max - hold_down_target_z;
status_led_view_x = status_led_x;
status_led_view_y = pcb_y_offset + status_led_y;
rgb_led_view_x = rgb_led_x;
rgb_led_view_y = pcb_y_offset + rgb_led_y;
pcb_top_clamp_h = lid_z_min - (pcb_board_top_z + pcb_top_clamp_clear);
pcb_rear_stop_z_min = pcb_board_bottom_z - pcb_rear_stop_below;

assert(head_recess_depth < lid_t - 0.5,
    str("screw_head_recess must leave lid material under the head. recess=", head_recess_depth, " mm."));
assert(!battery_side_wall_enable || battery_side_wall_t > 0,
    "battery_side_wall_t must be > 0.");
assert(slot_wall_fit >= 0,
    str("slot_wall_fit must be >= 0. Got ", slot_wall_fit, " mm."));
assert(screw_hole_lead_in_d >= screw_clear_d,
    str("screw_hole_lead_in_d must be >= screw_clear_d. lead_in_d=", screw_hole_lead_in_d,
        " clear_d=", screw_clear_d));
assert(screw_hole_lead_in_depth >= 0 && screw_hole_lead_in_depth <= lid_t,
    str("screw_hole_lead_in_depth must be within [0, lid_t]. depth=", screw_hole_lead_in_depth,
        " lid_t=", lid_t));
assert(screw_fit_shank_d > 0 && screw_fit_shank_d < screw_clear_d,
    str("screw_fit_shank_d must be > 0 and < screw_clear_d. fit=", screw_fit_shank_d,
        " clear=", screw_clear_d));
assert(screw_fit_head_d > 0 && screw_fit_head_d < screw_head_d,
    str("screw_fit_head_d must be > 0 and < screw_head_d. fit=", screw_fit_head_d,
        " recess=", screw_head_d));
assert(screw_fit_head_h > 0 && screw_fit_head_h < head_recess_depth,
    str("screw_fit_head_h must be > 0 and < head_recess_depth. fit=", screw_fit_head_h,
        " recess=", head_recess_depth));
assert(!battery_side_wall_enable || battery_side_wall_x + battery_side_wall_t / 2 <= carabiner_slot_inner_x + 0.001,
    str("Battery side walls reach into the carabiner slots by ",
        battery_side_wall_x + battery_side_wall_t / 2 - carabiner_slot_inner_x, " mm (X)."));
assert(pcb_rear_stop_x[0] >= max(-pcb_module_rect[0], pcb_module_rect[1]) + 1
    && pcb_rear_stop_x[1] <= pcb_W / 2,
    "PCB rear stops must sit behind the board, clear of the antenna overhang.");
assert(pcb_rear_stop_z_min >= battery_top_z + 1,
    "PCB rear stops must stay above the battery.");
assert(!battery_side_wall_enable || battery_side_wall_l <= (inner_y_max - inner_y_min) + 0.001,
    str("Battery side wall length exceeds inner cavity span by ",
        battery_side_wall_l - (inner_y_max - inner_y_min), " mm (Y)."));
assert(pcb_top_clamp_h > 0,
    "PCB clamps must reach down from the lid.");
for (w = pcb_clamp_windows)
    assert(w[0] >= -pcb_W / 2 && w[1] <= pcb_W / 2 && w[2] >= -pcb_L / 2 && w[3] <= pcb_L / 2,
        str("PCB clamp window must stay on the board: ", w));
assert(status_led_view_d > 0 && rgb_led_view_d > 0,
    str("LED view diameters must be > 0. status=", status_led_view_d,
        " rgb=", rgb_led_view_d, " mm."));
assert(led_view_chamfer_depth >= 0 && led_view_chamfer_depth <= lid_t,
    str("led_view_chamfer_depth must be within [0, lid_t]. depth=", led_view_chamfer_depth,
        " lid_t=", lid_t));
assert(led_view_chamfer_delta >= 0,
    str("led_view_chamfer_delta must be >= 0. Got ", led_view_chamfer_delta, " mm."));
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
    hole_h = z1 - z0 + 0.2;
    if (hole_h > 0) {
        hole_z = (z0 + z1) / 2;
        each_corner(hole_z)
            cylinder(d = d, h = hole_h, center = true);
    }
}

module corner_head_recesses(d, depth) {
    if (depth > 0) {
        recess_h = depth + 0.2;
        recess_z = lid_z_max - depth / 2 + 0.1;
        each_corner(recess_z)
            cylinder(d = d, h = recess_h, center = true);
    }
}

module corner_hole_lead_ins(d0, d1, depth) {
    if (depth > 0) {
        lead_in_z = lid_z_min + depth / 2;
        each_corner(lead_in_z)
            cylinder(d1 = d0, d2 = d1, h = depth + 0.2, center = true);
    }
}

module lid_screw_shank_fit_probe() {
    corner_holes(screw_fit_shank_d, lid_z_min - align_lip_h_eff - 0.2, lid_z_max + 0.2);
}

module lid_screw_head_fit_probe() {
    head_z = lid_z_max - screw_fit_head_h / 2;
    each_corner(head_z)
        cylinder(d = screw_fit_head_d, h = screw_fit_head_h, center = true);
}

module led_view_hole(x, y, d) {
    translate([x, y, lid_z_min - 0.1])
        cylinder(d = d, h = lid_t + 0.3, center = false);

    if (led_view_chamfer_depth > 0 && led_view_chamfer_delta > 0)
        translate([x, y, lid_z_max - led_view_chamfer_depth])
            cylinder(
                d1 = d,
                d2 = d + 2 * led_view_chamfer_delta,
                h = led_view_chamfer_depth + 0.2,
                center = false
            );
}

module led_view_holes() {
    led_view_hole(status_led_view_x, status_led_view_y, status_led_view_d);
    led_view_hole(rgb_led_view_x, rgb_led_view_y, rgb_led_view_d);
}

module lid_carabiner_slot_walls() {
    wall_z_min = loadcell_top_z + loadcell_slot_clear_z;
    wall_z_max = lid_z_min + internal_feature_embed;

    // Close the electronics bay above the load cell around each slot.
    translate([0, 0, wall_z_min])
        linear_extrude(height = wall_z_max - wall_z_min)
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

module lid_alignment_lips() {
    lip_h = align_lip_h_eff;
    if (lip_h > 0 && align_lip_t > 0) {
        lip_h_eff = lip_h + internal_feature_embed;
        lip_z = lid_z_min - lip_h / 2 + internal_feature_embed / 2;

        // Keep only the rear tab; remove the USB-side tab to keep connector area clear.
        for (y_sign = [-1]) {
            y_pos = (y_sign > 0)
                ? inner_y_max - align_lip_clear - align_lip_t / 2
                : inner_y_min + align_lip_clear + align_lip_t / 2;

            translate([0, y_pos, lip_z])
                cube([align_lip_front_back_len, align_lip_t, lip_h_eff], center = true);
        }
    }
}

module battery_side_walls() {
    if (battery_side_wall_enable && battery_side_wall_h > 0 && battery_side_wall_t > 0 && battery_side_wall_l > 0) {
        wall_z = hold_down_target_z + battery_side_wall_h / 2;

        for (x_sign = [-1, 1])
            translate([x_sign * battery_side_wall_x, 0, wall_z])
                cube([battery_side_wall_t, battery_side_wall_l, battery_side_wall_h], center = true);
    }
}

module battery_side_wall_features() {
    if (battery_side_wall_enable)
        battery_side_walls();
}

module pcb_top_clamps() {
    translate([0, pcb_y_offset, pcb_board_top_z + pcb_top_clamp_clear])
        linear_extrude(height = pcb_top_clamp_h + internal_feature_embed)
            for (w = pcb_clamp_windows)
                offset(delta = -pcb_top_clamp_inset)
                    pcb_rect_2d(w);
}

module pcb_rear_stops() {
    y_max = pcb_rear_y - pcb_rear_stop_clear;
    for (s = [-1, 1])
        translate([s > 0 ? pcb_rear_stop_x[0] : -pcb_rear_stop_x[1], y_max - pcb_rear_stop_t, pcb_rear_stop_z_min])
            cube([
                pcb_rear_stop_x[1] - pcb_rear_stop_x[0],
                pcb_rear_stop_t,
                lid_z_min - pcb_rear_stop_z_min + internal_feature_embed
            ]);
}

module brand_engrave_lid() {
    // Carved on outer top face (same plane as load cell), horizontal and centered.
    translate([brand_x, brand_y, lid_z_max - brand_depth - 0.1])
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
            lid_alignment_lips();
            battery_side_wall_features();
            pcb_top_clamps();
            pcb_rear_stops();
            lid_carabiner_slot_walls();
        }
        corner_holes(screw_clear_d, lid_z_min - align_lip_h_eff, lid_z_max);
        corner_hole_lead_ins(screw_hole_lead_in_d, screw_clear_d, screw_hole_lead_in_depth);
        corner_head_recesses(screw_head_d, head_recess_depth);
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
