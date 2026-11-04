//
// Main enclosure part (base body)
// - USB-C opening
// - load-cell saddle with open carabiner U-slots
// - corner pilot holes for M2.5x10 screws, threaded only near the tip
//

include <placement.scad>
use <load_cell.scad>
use <pcb.scad>
use <assembly.scad>
use <case_lid.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
floor_t = 2.4;

notch_pin_embed = 0.4;
loadcell_notch_guide_len = 7.5;
loadcell_notch_guide_w = 1.0;
loadcell_notch_guide_h = 4;
loadcell_notch_guide_clear = 0.2;
loadcell_support_corner_size = 8;
loadcell_support_corner_inset = 2;
battery_guide_clear = 0.5;
battery_guide_t = 1.8;
battery_guide_h = bat_T * 0.6;
pcb_guide_above = 1.0; // edge guides rise above the board top face
pcb_guide_lead_in = 0.6;

usb_hole_corner_r = 0.8;

screw_post_d = 6.5;
screw_thread_tip_clear = 0.6; // pilot depth beyond the screw tip

rear_brand_text = "crimpdeq.com";
rear_brand_font = brand_font;
rear_brand_depth = 0.8;
rear_brand_margin = 2; // from each end of the flat rear wall

// Parameters
show_assembly = true;
show_lid_preview = true;
lid_preview_z_offset = 0; // mm (above main part)
lid_preview_alpha = 0.8; // higher alpha = more opaque
print_layout = false; // true: place bottom on Z=0 for direct STL slicing

/*** Derived placement ***/
// Span the flat rear wall up to where the facets start.
rear_brand_w = 2 * (case_corner_x - rear_brand_margin);

outer_z_min = inner_z_min - floor_t;
outer_z_max = inner_z_max;

notch_x1 = -lc_L / 2 + notch_xA;
notch_x2 = -lc_L / 2 + notch_xB;
notch_y1 = -lc_W / 2;
notch_y2 = lc_W / 2;
notch_pin_d = notch_d - notch_pin_clear;
notch_pin_h = 6 + loadcell_lift;

thread_depth = screw_tip_depth + screw_thread_tip_clear;
shank_clear_depth = screw_tip_depth - screw_thread_len;

pcb_guide_top_z = pcb_board_top_z + pcb_guide_above;

assert(abs(switch_x) + switch_w / 2 + switch_collar_t <= case_corner_x - 1,
    "The switch opening and its collar must stay on the flat front wall.");
assert(switch_grip_len >= wall_t,
    str("switch_grip_len must be at least wall_t. Got ", switch_grip_len, " mm."));
assert(usb_pocket_floor_y - inner_y_max >= usb_pocket_min_web && usb_pocket_floor_y < outer_y_max,
    str("USB-C pocket must leave a front-wall web. web=", usb_pocket_floor_y - inner_y_max, " mm."));
assert(usb_center_z + usb_pocket_h / 2 <= outer_z_max - 1,
    "USB-C pocket must stay below the lid seam.");
assert(abs(usb_x) + usb_pocket_w / 2 <= case_corner_x - 1,
    "USB-C pocket must stay on the flat front wall.");
assert(pcb_support_columns[0][1] + 0.3 <= switch_cavity_x[0]
    && switch_cavity_x[1] + 0.3 <= pcb_support_columns[1][0],
    "PCB columns must clear the switch cavity.");
assert(pcb_guide_top_z < outer_z_max - 0.5,
    "PCB edge guides must stay below the lid.");
assert(pcb_guide_lead_in > 0 && pcb_guide_lead_in < pcb_guide_above + pcb_board_t,
    str("pcb_guide_lead_in must stay within the edge guides. Got ", pcb_guide_lead_in, " mm."));
assert(screw_edge_inset - screw_post_d / 2 < wall_t,
    "Screw posts must merge into the walls.");
assert(screw_thread_d < screw_d && screw_d < screw_shank_clear_d && screw_shank_clear_d <= screw_post_d - 3,
    "The screw must thread in the pilot, pass the clear bore and leave 1.5 mm of post rim.");
assert(shank_clear_depth > 0 && screw_thread_len >= 2 * screw_d,
    "The screw must thread at least two diameters below a clear bore.");
assert(thread_depth <= outer_z_max - outer_z_min - 1,
    str("Screw pilot depth ", thread_depth, " mm does not fit the post."));
assert(rear_brand_depth > 0 && rear_brand_depth < wall_t,
    str("rear_brand_depth must be > 0 and < wall_t (", wall_t, " mm)."));
assert(case_inner_x_half >= bat_W / 2 + battery_guide_clear + battery_guide_t,
    str("Electronics pod is too narrow for the battery guides. inner_half=", case_inner_x_half, " mm."));

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

// Profile centered on the USB-C connector, in the front-wall (XZ) plane.
module usb_profile_2d(w, h, r) {
    rounded_rect_2d(usb_x - w / 2, usb_x + w / 2,
        usb_center_z - h / 2, usb_center_z + h / 2, r);
}

// Prism along Y from y0 to y1 with a usb_profile_2d cross section.
module usb_prism(y0, y1, w, h, r) {
    translate([0, y1, 0])
        rotate([90, 0, 0])
            linear_extrude(height = y1 - y0)
                usb_profile_2d(w, h, r);
}

module usb_opening_cut() {
    usb_prism(inner_y_max - 0.1, usb_pocket_floor_y + 0.01,
        usb_hole_w, usb_hole_h, usb_hole_corner_r);
    usb_prism(usb_pocket_floor_y, outer_y_max + 0.1,
        usb_pocket_w, usb_pocket_h, usb_overmold_corner_r + usb_pocket_clear);
}

// A fully mated cable: the plug shell inside the receptacle and the largest
// recommended overmold stopped usb_overmold_stop_gap in front of it.
module usb_cable_fit_probe() {
    usb_prism(usb_face_y - 6.5, usb_pocket_floor_y,
        usb_plug_shell_w, usb_plug_shell_h, usb_plug_shell_corner_r);
    usb_prism(usb_pocket_floor_y + 0.01, outer_y_max + 15,
        usb_overmold_w, usb_overmold_h, usb_overmold_corner_r);
}

module notch_pin(x, y) {
    translate([x, y, inner_z_min + notch_pin_h / 2 - notch_pin_embed])
        cylinder(d = notch_pin_d, h = notch_pin_h, center = true);
}

module loadcell_support() {
    support_xy = loadcell_support_corner_size;
    support_h = loadcell_lift + internal_feature_embed;
    support_z = inner_z_min - internal_feature_embed + support_h / 2;
    support_x = pod_half_x - loadcell_support_corner_inset - support_xy / 2;
    support_y = lc_W / 2 - loadcell_support_corner_inset - support_xy / 2;

    for (x_sign = [-1, 1])
        for (y_sign = [-1, 1])
            translate([x_sign * support_x, y_sign * support_y, support_z])
                cube([support_xy, support_xy, support_h], center = true);
}

// Floor-anchored pads under the rear battery corners, behind the load cell,
// with guides beside and behind each corner. Lid hold-downs clamp the battery
// onto them. Its front settles onto the strain-gauge cover. Nothing may hang
// over the load cell, or it would not drop in.
module battery_rear_supports() {
    floor_z = inner_z_min - internal_feature_embed;
    guide_top_z = battery_bottom_z + min(battery_guide_h, bat_T);
    pad_x = battery_pad_x;
    pad_y = battery_pad_y;
    side_x0 = bat_W / 2 + battery_guide_clear;
    side_x = [side_x0, side_x0 + battery_guide_t];
    rear_y1 = battery_y_offset - bat_L / 2 - battery_guide_clear;
    rear_y = [rear_y1 - battery_guide_t, rear_y1];

    for (s = [-1, 1]) {
        box(s * [pad_x[0], side_x[0]], pad_y, [floor_z, battery_bottom_z]);
        box(s * pad_x, [rear_y[1], pad_y[0]], [floor_z, battery_bottom_z]);
        box(s * side_x, pad_y, [floor_z, guide_top_z]);
        box(s * pad_x, rear_y, [floor_z, guide_top_z]);
    }
}

// Everything the PCB occupies, plus its vertical drop-in path. Supports are
// cut by this volume, so they touch only the bare support windows.
module pcb_keepout() {
    lead_z = pcb_guide_top_z - pcb_guide_lead_in;
    space_top_z = outer_z_max + 0.1;

    translate([0, pcb_y_offset, 0]) {
        // Board, flared above the edge guides for self-centering.
        translate([0, 0, pcb_board_bottom_z])
            linear_extrude(height = lead_z - pcb_board_bottom_z)
                offset(delta = pcb_guide_clear)
                    square([pcb_W, pcb_L], center = true);
        hull() {
            translate([0, 0, lead_z])
                linear_extrude(height = 0.01)
                    offset(delta = pcb_guide_clear)
                        square([pcb_W, pcb_L], center = true);
            translate([0, 0, pcb_guide_top_z])
                linear_extrude(height = space_top_z - pcb_guide_top_z)
                    offset(delta = pcb_guide_clear + pcb_guide_lead_in)
                        square([pcb_W, pcb_L], center = true);
        }

        // ESP32 antenna overhang beyond the rear board edge.
        translate([0, 0, pcb_board_top_z])
            linear_extrude(height = space_top_z - pcb_board_top_z)
                offset(delta = pcb_guide_clear)
                    pcb_rect_2d(pcb_module_rect);

        // F.Cu parts outside the support windows.
        translate([0, 0, pcb_board_bottom_z - pcb_bottom_parts_h - pcb_part_clear])
            linear_extrude(height = pcb_bottom_parts_h + pcb_part_clear + 0.01)
                offset(delta = pcb_part_clear_xy)
                    pcb_parts_2d(pcb_support_windows);

        // USB-C connector.
        translate([usb_x, usb_y, pcb_bottom_z - pcb_part_clear])
            linear_extrude(height = space_top_z - pcb_bottom_z)
                offset(delta = pcb_part_clear_xy)
                    square([usb_w, usb_d], center = true);
    }
}

// Floor-anchored columns in front of the load cell carry the board under its
// support windows. Nothing hangs over the load cell or battery, so they print
// without support and both drop straight in. Lid tabs behind the board take USB-C insertion loads.
module pcb_supports() {
    difference() {
        for (c = pcb_support_columns)
            box([c[0], c[1]], [max(pcb_y_offset + c[2], pcb_column_rear_y), pcb_y_offset + c[3]],
                [inner_z_min - internal_feature_embed, pcb_guide_top_z]);
        pcb_keepout();
    }
}

// Thickens the front wall round the switch opening to switch_grip_len,
// standing on the floor.
module switch_collar() {
    box(span(switch_x, switch_w / 2 + switch_collar_t), [switch_grip_y, inner_y_max + internal_feature_embed],
        [inner_z_min - internal_feature_embed, switch_z + switch_h / 2 + switch_collar_t]);
}

// Cavity for the switch body, ending at the collar, and the opening through
// the wall and collar that grips the bezel over switch_grip_len.
module switch_cut() {
    box(switch_cavity_x, [switch_rear_y - switch_clear, switch_grip_y],
        span(switch_z, switch_h / 2 + switch_clear));
    box(span(switch_x, switch_w / 2), [switch_grip_y - 0.1, outer_y_max + 0.1],
        span(switch_z, switch_h / 2));
}

module notch_pins() {
    for (x = [notch_x1, notch_x2])
        for (y = [notch_y1, notch_y2])
            notch_pin(x, y);
}

module loadcell_notch_guides() {
    guide_h = loadcell_notch_guide_h + loadcell_lift + internal_feature_embed;
    guide_z = inner_z_min - internal_feature_embed + guide_h / 2;
    guide_bottom_y = notch_y1 - loadcell_notch_guide_clear - loadcell_notch_guide_w / 2;
    guide_top_y = notch_y2 + loadcell_notch_guide_clear + loadcell_notch_guide_w / 2;

    for (notch_x = [notch_x1, notch_x2]) {
        guide_x = notch_x - sign(notch_x) * loadcell_notch_guide_len / 2;
        translate([guide_x, guide_bottom_y, guide_z])
            cube([loadcell_notch_guide_len, loadcell_notch_guide_w, guide_h], center = true);
        translate([guide_x, guide_top_y, guide_z])
            cube([loadcell_notch_guide_len, loadcell_notch_guide_w, guide_h], center = true);
    }
}

module corner_thread_holes(d, z_top, depth) {
    each_corner(z_top - depth / 2 + 0.1)
        cylinder(d = d, h = depth + 0.2, center = true);
}

module corner_screw_posts(d, z0, z1) {
    each_corner((z0 + z1) / 2)
        cylinder(d = d, h = z1 - z0, center = true);
}

module main_carabiner_slot_walls() {
    wall_z_min = outer_z_min;
    wall_z_max = loadcell_bottom_z - loadcell_slot_clear_z;

    // Close the electronics bay below the load cell around each slot.
    translate([0, 0, wall_z_min])
        linear_extrude(height = wall_z_max - wall_z_min)
            intersection() {
                union() {
                    carabiner_slot_wall_2d(-1);
                    carabiner_slot_wall_2d(1);
                }
                case_outline_2d();
            }
}

module slot_seal_fins() {
    translate([0, 0, outer_z_min])
        linear_extrude(height = outer_z_max - outer_z_min)
            slot_seal_fins_2d();
}

module carabiner_slot_cuts() {
    translate([0, 0, outer_z_min - 0.2])
        linear_extrude(height = outer_z_max - outer_z_min + 0.4)
            for (x_sign = [-1, 1])
                carabiner_slot_2d(x_sign);
}

module brand_engrave_main() {
    // Carved on outer bottom face, horizontal and centered.
    translate([0, brand_y, outer_z_min - 0.1])
        linear_extrude(height = brand_depth + 0.2, center = false)
            // Mirrored so it reads correctly when viewed from outside (underside).
            mirror([1, 0, 0])
                rotate([0, 0, -90])
                    text(brand_text, size = brand_size, font = brand_font, halign = "center", valign = "center");
}

module brand_engrave_main_rear_wall() {
    rear_brand_z = (outer_z_min + outer_z_max) / 2;

    // Carved on outer rear wall (-Y), opposite the switch and USB openings.
    // Start from inside the wall and extrude outward so the recess depth stays controlled.
    translate([0, outer_y_min + rear_brand_depth, rear_brand_z])
        rotate([90, 0, 0])
            linear_extrude(height = rear_brand_depth + 0.2, center = false)
                resize([rear_brand_w, 0], auto = true)
                    text(rear_brand_text, font = rear_brand_font, halign = "center", valign = "center");
}

module main_part() {
    difference() {
        union() {
            difference() {
                translate([0, 0, outer_z_min])
                    linear_extrude(height = outer_z_max - outer_z_min)
                        case_outline_2d();
                translate([0, 0, inner_z_min])
                    linear_extrude(height = outer_z_max - inner_z_min + 0.1)
                        case_outline_2d(wall_t);
            }

            loadcell_support();
            battery_rear_supports();
            pcb_supports();
            switch_collar();
            notch_pins();
            loadcell_notch_guides();
            main_carabiner_slot_walls();
            slot_seal_fins();

            // Internal cylindrical bosses for screw engagement.
            corner_screw_posts(screw_post_d, outer_z_min, outer_z_max);
        }

        corner_thread_holes(screw_thread_d, outer_z_max, thread_depth);
        corner_thread_holes(screw_shank_clear_d, outer_z_max, shank_clear_depth);

        carabiner_slot_cuts();

        switch_cut();

        // USB-C opening and cable overmold pocket.
        usb_opening_cut();

        // Brand engraving on outer bottom face.
        brand_engrave_main();
        // Rear wall engraving on side opposite the switch/USB wall.
        brand_engrave_main_rear_wall();
    }
}

module main_part_print_layout() {
    translate([0, 0, -outer_z_min]) {
        main_part();
    }
}

if (print_layout) {
    main_part_print_layout();
} else {
    main_part();
}

if ($preview && show_assembly) {
    if (print_layout) {
        translate([0, 0, -outer_z_min]) %full_assembly();
    } else {
        %full_assembly();
    }
}

if ($preview && show_lid_preview) {
    preview_z = (print_layout ? -outer_z_min : 0) + lid_preview_z_offset;
    translate([0, 0, preview_z]) {
        color([0.8, 0.8, 0.8, lid_preview_alpha])
            if (print_layout) lid_part_print_layout(); else lid_part();
    }
}
