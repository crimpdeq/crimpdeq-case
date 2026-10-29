//
// Main enclosure part (base body)
// - load-cell pads and notch pins
// - floor column carrying the PCB under the USB-C connector
// - front-wall USB-C opening and switch opening
// - open carabiner U-slots
//

include <placement.scad>
use <assembly.scad>
use <case_lid.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
internal_feature_embed = 0.15; // overlap internal features into the shell for a fused STL

// Pads under the battery's side edges, 2 mm inside the plate's long edges,
// clear of the gauge cover, its wire route and the slot walls.
loadcell_pad_x = bat_W / 2 - loadcell_pad_size / 2;
loadcell_pad_y = lc_W / 2 - 2 - loadcell_pad_size / 2;
// Rib behind the battery, in the rear band.
battery_rear_stop_t = 1.5;

pcb_part_clear = 0.2; // column top below the bottom parts

rear_brand_text = "crimpdeq.com";
rear_brand_w = 60;
rear_brand_depth = 0.8;

// Parameters
show_assembly = true;
show_lid_preview = true;
lid_preview_alpha = 0.8; // higher alpha = more opaque

/*** Derived placement ***/
// The screw passes the lid material under its head recess, then threads in.
thread_depth = screw_len - (lid_t - screw_head_recess) + screw_thread_tip_clear;
notch_pin_d = notch_d - 2 * notch_pin_clear;
stop_y = battery_front_y - battery_stop_clear;
pcb_column_x = [pcb_support_windows[0][0], pcb_support_windows[1][1]];
pcb_column_top_z = pcb_board_bottom_z - pcb_bottom_parts_h - pcb_part_clear;

assert(loadcell_pad_x - loadcell_pad_size / 2 > gauge_cover_w / 2 + loadcell_wire_bundle[0],
    "Load-cell pads must clear the gauge cover and its wires.");
assert(loadcell_pad_y - loadcell_pad_size / 2 > slot_wall_outer_y,
    "Load-cell pads must clear the carabiner slot walls.");
assert(loadcell_top_z < switch_z - switch_h / 2 - switch_clear,
    "The notch pins must stay below the switch.");
assert(battery_rear_y + battery_stop_clear + battery_rear_stop_t < screw_y - screw_post_d / 2,
    "The battery rear stop must stay in front of the rear screw posts.");
assert(thread_depth <= seam_z - floor_t,
    str("Screw pilot depth ", thread_depth, " mm does not fit the posts."));
assert(screw_thread_d + 2 * screw_pilot_chamfer <= screw_post_d - 2,
    "Screw pilot chamfers must leave at least 1 mm of post rim.");
assert(pcb_column_top_z > battery_top_z,
    "The PCB column must cover the battery's front face.");
for (p = pcb_cable_pads)
    assert(abs(p[0]) - wire_d / 2 > pcb_column_x[1] + 0.1,
        str("The PCB column must clear the wire at pad ", p));
assert(screw_x - screw_post_d / 2 > max([for (p = pcb_cable_pads) abs(p[0])]) + wire_d / 2 + 0.5,
    "The front screw posts must leave a lane beside the wire pads.");
assert(usb_x + usb_pocket_w / 2 < switch_x - switch_w / 2 - switch_flange - 1,
    "The switch flange must clear the USB-C pocket.");

module loadcell_pads() {
    for (x_sign = [-1, 1], y_sign = [-1, 1])
        box(x_sign * span(loadcell_pad_x, loadcell_pad_size / 2),
            y_sign * span(loadcell_pad_y, loadcell_pad_size / 2),
            [floor_top_z - internal_feature_embed, loadcell_bottom_z]);
}

// Floor pins in the four edge notches hold the plate in X and Y. They end
// flush with its top face, below the switch.
module notch_pins() {
    for (x_sign = [-1, 1], y_sign = [-1, 1])
        translate([x_sign * notch_x, y_sign * lc_W / 2, floor_top_z - internal_feature_embed])
            cylinder(d = notch_pin_d, h = loadcell_top_z - floor_top_z + internal_feature_embed);
}

module battery_rear_stop() {
    y0 = battery_rear_y + battery_stop_clear;
    box(span(0, bat_W / 2 - 3), [y0, y0 + battery_rear_stop_t],
        [floor_top_z - internal_feature_embed, battery_top_z - 1]);
}

// Floor column from the front wall to the battery front, which it stops. It
// stays below the bottom parts; fingers on top carry the board on its bare
// support windows, inset by the board's play: pcb_guide_clear sideways and
// pcb_front_gap toward the rear. The lid clamps the board onto them through
// the USB-C shell, right above.
module pcb_column() {
    box(pcb_column_x, [inner_front_y - internal_feature_embed, stop_y],
        [floor_top_z - internal_feature_embed, pcb_column_top_z]);
    translate([0, pcb_y, 0])
        for (w = pcb_support_windows)
            box([w[0] + pcb_guide_clear, w[1] - pcb_guide_clear], [w[2], w[3] - pcb_front_gap],
                [pcb_column_top_z - internal_feature_embed, pcb_board_bottom_z]);
}

// The posts merge into the front and rear walls; the front posts' flat inner
// faces guide the board's long edges, and the rear ones mirror them.
module screw_posts() {
    guide_x = pcb_W / 2 + pcb_guide_clear;
    for (x_sign = [-1, 1], y_sign = [-1, 1])
        linear_extrude(height = seam_z)
            hull() {
                translate([x_sign * screw_x, y_sign * screw_y])
                    circle(d = screw_post_d);
                translate([x_sign > 0 ? guide_x : -screw_x, y_sign > 0 ? screw_y : -inner_rear_y - internal_feature_embed])
                    square([screw_x - guide_x, inner_rear_y + internal_feature_embed - screw_y]);
            }
}

module screw_pilots() {
    each_screw(seam_z - thread_depth)
        cylinder(d = screw_thread_d, h = thread_depth + 0.1);
    each_screw(seam_z - screw_pilot_chamfer)
        cylinder(d1 = screw_thread_d, d2 = screw_thread_d + 2 * (screw_pilot_chamfer + 0.1), h = screw_pilot_chamfer + 0.1);
}

// Close the electronics bay below the load cell around each slot.
module main_carabiner_slot_walls() {
    linear_extrude(height = loadcell_bottom_z - loadcell_slot_clear_z)
        intersection() {
            union() {
                carabiner_slot_wall_2d(-1);
                carabiner_slot_wall_2d(1);
            }
            case_outline_2d();
        }
}

module carabiner_slot_cuts() {
    translate([0, 0, -0.2])
        linear_extrude(height = seam_z + 0.4)
            for (x_sign = [-1, 1])
                carabiner_slot_2d(x_sign);
}

// Thickens the front wall round the switch opening to switch_grip_len,
// standing on the floor.
module switch_collar() {
    box(span(switch_x, switch_w / 2 + switch_collar_t),
        [switch_grip_y, inner_front_y + internal_feature_embed],
        [floor_top_z - internal_feature_embed, switch_z + switch_h / 2 + switch_collar_t]);
}

// The opening grips the bezel over switch_grip_len; the cavity behind it
// clears the switch body.
module switch_cuts() {
    box(span(switch_x, switch_w / 2), [outer_front_y - 0.1, switch_grip_y + 0.01],
        span(switch_z, switch_h / 2));
    box(span(switch_x, switch_w / 2 + switch_clear), [switch_grip_y, switch_rear_y + switch_clear],
        span(switch_z, switch_h / 2 + switch_clear));
}

// Centered on the bottom face, mirrored so it reads from below.
module brand_engrave_bottom() {
    translate([0, 0, -0.1])
        linear_extrude(height = brand_depth + 0.1)
            mirror([1, 0, 0])
                rotate([0, 0, -90])
                    resize([brand_l, 0], auto = true)
                        text(brand_text, font = brand_font, halign = "center", valign = "center");
}

// Reads from behind the rear wall.
module brand_engrave_rear_wall() {
    translate([0, outer_rear_y - rear_brand_depth, seam_z / 2])
        rotate([90, 0, 180])
            linear_extrude(height = rear_brand_depth + 0.1)
                resize([rear_brand_w, 0], auto = true)
                    text(rear_brand_text, font = brand_font, halign = "center", valign = "center");
}

module main_part() {
    difference() {
        union() {
            difference() {
                linear_extrude(height = seam_z)
                    case_outline_2d();
                translate([0, 0, floor_top_z])
                    linear_extrude(height = seam_z)
                        cavity_2d();
            }
            loadcell_pads();
            notch_pins();
            battery_rear_stop();
            pcb_column();
            screw_posts();
            main_carabiner_slot_walls();
            switch_collar();
        }
        screw_pilots();
        carabiner_slot_cuts();
        end_wall_grooves();
        switch_cuts();
        usb_hole_cut();
        usb_pocket_cut();
        brand_engrave_bottom();
        brand_engrave_rear_wall();
    }
}

main_part();

if ($preview && show_assembly)
    %full_assembly();

if ($preview && show_lid_preview)
    color([0.8, 0.8, 0.8, lid_preview_alpha])
        lid_part();
