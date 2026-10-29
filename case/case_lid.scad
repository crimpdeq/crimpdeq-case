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

internal_feature_embed = 0.15; // overlap underside features into the roof for a fused STL

print_layout = false; // true: flip lid for support-free printing (outer top face on bed)

/*** Derived placement ***/
assert(led_window_t > 0 && led_window_t < lid_t - 1,
    "The LED windows must close the holes and leave them deep.");
assert(screw_head_recess < lid_t - 0.5,
    str("screw_head_recess must leave lid material under the head. recess=", screw_head_recess, " mm."));
assert(screw_fit_shank_d < screw_clear_d && screw_fit_head_d < screw_head_d && screw_fit_head_h < screw_head_recess,
    "Screw fit envelopes must fit their holes.");

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

// Blind from the underside, leaving the window at the outer face.
module led_view_hole(x, y, d) {
    translate([x, y, seam_z - 0.1])
        cylinder(d = d, h = lid_t - led_window_t + 0.1);
}

module led_view_holes() {
    led_view_hole(status_led_x, status_led_view_y, status_led_view_d);
    led_view_hole(rgb_led_x, rgb_led_view_y, rgb_led_view_d);
}

// Close the electronics bay above the load cell around each slot; the
// straight wall ends reach into the end-wall grooves.
module lid_carabiner_slot_walls() {
    translate([0, 0, lid_hold_down_z])
        linear_extrude(height = seam_z + internal_feature_embed - lid_hold_down_z)
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
    translate([0, brand_y, lid_top_z - brand_depth])
        linear_extrude(height = brand_depth + 0.1)
            rotate([0, 0, 90])
                resize([brand_l, 0], auto = true)
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
        usb_pocket_cut(lid_seat_play);
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
