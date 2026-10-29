//
// Lid enclosure part
// - screw holes aligned with case_main.scad
// - carabiner slot walls that close the electronics bay above the load cell
// - USB-C shell clamp, PCB rear stops and battery hold-downs
//

include <placement.scad>
use <pcb.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
screw_clear_d = 3.0; // slightly looser clearance so the lid seats more easily on the posts
screw_hole_lead_in_d = 3.8; // underside funnel for easier post entry during assembly
screw_hole_lead_in_depth = 1.0;
screw_fit_shank_d = 2.6; // fit-check envelope for an M2.5 screw shank through the lid
screw_fit_head_d = 5.0; // fit-check envelope for a typical M2.5 pan/button head
screw_fit_head_h = 1.6;

// The clamp presses the board onto the column fingers through the flat top of
// the USB-C shell, right above them, by one 0.2 mm layer: it ends on a layer
// boundary and the lid flexes to absorb it. It stays on the shell top
// wherever the lid seats and the board sits within its play.
usb_clamp_preload = 0.1;
usb_clamp_inset = lid_seat_play + pcb_guide_clear;

// Tabs behind the board's rear edge take USB-C insertion loads. The chamfer
// on each tab's board side pushes a board that slid back during assembly
// forward as the lid closes.
pcb_rear_stop_x = [3.5, pcb_W / 2]; // |x| span
pcb_rear_stop_t = 2.4;
pcb_rear_stop_clear = 0.25;
pcb_rear_stop_below = 1.0; // reach below the board underside
pcb_rear_stop_chamfer = 0.8;

// Bars beside the board over the battery. They stop the battery lifting into
// the board's bottom parts and loosely guide the board's rear end.
battery_hold_down_x = [pcb_W / 2 + pcb_guide_clear + lid_seat_play, bat_W / 2 - 0.5];
battery_hold_down_y = [-12, battery_rear_y - 1];

internal_feature_embed = 0.15; // overlap underside features into the roof for a fused STL

status_led_view_d = 2.6;
rgb_led_view_d = 3.2;
led_view_chamfer_depth = 0.8;
led_view_chamfer_delta = 0.6;

brand_text = "Crimpdeq";
brand_font = "Liberation Sans:style=Bold"; // bundled with OpenSCAD
brand_w = 28;
brand_depth = 0.8;
print_layout = false; // true: flip lid for support-free printing (outer top face on bed)

/*** Derived placement ***/
hold_down_target_z = loadcell_top_z + loadcell_hold_down_clear;
usb_clamp_rect = [
    usb_shell_top_rect[0] + usb_clamp_inset, usb_shell_top_rect[1] - usb_clamp_inset,
    max(usb_shell_top_rect[2], inner_front_y + lid_seat_play - pcb_y), usb_shell_top_rect[3] - usb_clamp_inset
];
pcb_rear_stop_z_min = pcb_board_bottom_z - pcb_rear_stop_below;
status_led_view_y = pcb_y + status_led_y;
rgb_led_view_y = pcb_y + rgb_led_y;

assert(screw_head_recess < lid_t - 0.5,
    str("screw_head_recess must leave lid material under the head. recess=", screw_head_recess, " mm."));
assert(screw_fit_shank_d < screw_clear_d && screw_fit_head_d < screw_head_d && screw_fit_head_h < screw_head_recess,
    "Screw fit envelopes must fit their holes.");
assert(usb_clamp_rect[1] - usb_clamp_rect[0] >= 4 && usb_clamp_rect[3] - usb_clamp_rect[2] >= 3,
    "The USB-C clamp must keep a useful area on the shell top.");
assert(pcb_rear_stop_x[0] > 0 && pcb_rear_stop_x[1] <= pcb_W / 2,
    "PCB rear stops must sit behind the board.");
assert(pcb_rear_stop_z_min >= battery_top_z + 0.5,
    "PCB rear stops must stay above the battery.");
assert(pcb_rear_stop_z_min + pcb_rear_stop_chamfer <= pcb_board_bottom_z,
    "PCB rear stops must bear on the full board edge above their chamfer.");
assert(battery_hold_down_x[1] < carabiner_slot_inner_x - loadcell_slot_wall_t - lid_seat_play,
    "Battery hold-downs must clear the lid slot walls.");
assert(battery_hold_down_y[0] > switch_rear_y + switch_wire_bend,
    "Battery hold-downs must stay behind the switch wire route.");

module screw_holes() {
    each_screw(seam_z - 0.1)
        cylinder(d = screw_clear_d, h = lid_t + 0.2);
    each_screw(seam_z - 0.1)
        cylinder(d1 = screw_hole_lead_in_d, d2 = screw_clear_d, h = screw_hole_lead_in_depth + 0.1);
    each_screw(lid_top_z - screw_head_recess)
        cylinder(d = screw_head_d, h = screw_head_recess + 0.1);
}

module lid_screw_shank_fit_probe() {
    each_screw(seam_z - 0.2)
        cylinder(d = screw_fit_shank_d, h = lid_t + 0.4);
}

module lid_screw_head_fit_probe() {
    each_screw(lid_top_z - screw_fit_head_h)
        cylinder(d = screw_fit_head_d, h = screw_fit_head_h);
}

module led_view_hole(x, y, d) {
    translate([x, y, seam_z - 0.1])
        cylinder(d = d, h = lid_t + 0.3);
    translate([x, y, lid_top_z - led_view_chamfer_depth])
        cylinder(d1 = d, d2 = d + 2 * led_view_chamfer_delta, h = led_view_chamfer_depth + 0.1);
}

module led_view_holes() {
    led_view_hole(status_led_x, status_led_view_y, status_led_view_d);
    led_view_hole(rgb_led_x, rgb_led_view_y, rgb_led_view_d);
}

// Close the electronics bay above the load cell around each slot; the
// straight wall ends reach into the end-wall grooves.
module lid_carabiner_slot_walls() {
    translate([0, 0, hold_down_target_z])
        linear_extrude(height = seam_z + internal_feature_embed - hold_down_target_z)
            intersection() {
                union() {
                    carabiner_slot_wall_2d(-1);
                    carabiner_slot_wall_2d(1);
                }
                lid_slot_wall_bound_2d();
            }
}

module lid_carabiner_slot_cuts() {
    translate([0, 0, seam_z - 0.1])
        linear_extrude(height = lid_t + 0.2)
            for (x_sign = [-1, 1])
                carabiner_slot_2d(x_sign);
}

module usb_clamp() {
    translate([0, pcb_y, usb_top_z - usb_clamp_preload])
        linear_extrude(height = seam_z + internal_feature_embed - (usb_top_z - usb_clamp_preload))
            pcb_rect_2d(usb_clamp_rect);
}

module pcb_rear_stops() {
    w = pcb_rear_stop_x[1] - pcb_rear_stop_x[0];
    y0 = pcb_rear_y + pcb_rear_stop_clear;
    z_chamfer = pcb_rear_stop_z_min + pcb_rear_stop_chamfer;
    for (s = [-1, 1])
        translate([s > 0 ? pcb_rear_stop_x[0] : -pcb_rear_stop_x[1], y0, 0])
            hull() {
                translate([0, 0, z_chamfer])
                    cube([w, pcb_rear_stop_t, seam_z - z_chamfer + internal_feature_embed]);
                translate([0, pcb_rear_stop_chamfer, pcb_rear_stop_z_min])
                    cube([w, pcb_rear_stop_t - pcb_rear_stop_chamfer, 0.01]);
            }
}

module battery_hold_downs() {
    for (s = [-1, 1])
        box(s * battery_hold_down_x, battery_hold_down_y,
            [battery_top_z + battery_hold_down_clear, seam_z + internal_feature_embed]);
}

module brand_engrave_lid() {
    translate([0, 0, lid_top_z - brand_depth])
        linear_extrude(height = brand_depth + 0.1)
            resize([brand_w, 0], auto = true)
                text(brand_text, font = brand_font, halign = "center", valign = "center");
}

module lid_part() {
    difference() {
        union() {
            translate([0, 0, seam_z])
                linear_extrude(height = lid_t)
                    case_outline_2d();
            lid_carabiner_slot_walls();
            usb_clamp();
            pcb_rear_stops();
            battery_hold_downs();
        }
        screw_holes();
        led_view_holes();
        lid_carabiner_slot_cuts();
        usb_pocket_cut();
        brand_engrave_lid();
    }
}

module lid_part_print_layout() {
    translate([0, 0, lid_top_z])
        rotate([180, 0, 0])
            lid_part();
}

if (print_layout) {
    lid_part_print_layout();
} else {
    lid_part();
}
