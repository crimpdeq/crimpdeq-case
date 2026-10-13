//
// Main enclosure part (base body)
// - USB-C opening
// - load-cell saddle with end guards and open carabiner slots
// - corner threaded pilot holes for M2.5x10 screws
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

notch_pin_clear = 0.2;
notch_pin_embed = 0.4;
notch_pin_top_clear = 1.0;
loadcell_notch_guide_len = 7.5;
loadcell_notch_guide_w = 1.0;
loadcell_notch_guide_h = 4;
loadcell_notch_guide_clear = 0.2;
loadcell_support_corner_size = 8;
loadcell_support_corner_inset = 2;
battery_support_corner_size = 8;
battery_support_corner_inset = 1;
battery_support_front_column_clear = 0.3; // also the battery front stop gap
battery_support_bottom_gap = 0.5;
battery_guide_clear = 0.5;
battery_guide_t = 1.8;
battery_guide_h = bat_T * 0.6;
pcb_guide_clear = 0.25;
pcb_guide_above = 1.0; // edge guides rise above the board top face
pcb_guide_lead_in = 0.6;
pcb_part_clear = 0.2; // below F.Cu parts and around the USB-C connector
// Parts can also slide by the guide clearance before the rear stops engage.
pcb_part_clear_xy = pcb_guide_clear + pcb_part_clear;
pcb_rail_battery_clear = 0.2;
pcb_rear_stop_depth = 0.8;
pcb_rear_stop_w = 4;
pcb_battery_tongue_front_clear = 3.5; // overlap under battery front edge
pcb_battery_tongue_top_clear = 0.0; // 0 = touches battery underside
pcb_battery_tongue_bottom_clear = 0.8; // extra load-cell top clearance so battery tabs don't pinch/tilt it

internal_feature_embed = 0.15; // overlap floor-anchored features into the shell for a fused STL

usb_clear_x = 0.55;
usb_hole_extra_w = 0.0; // 9 + 2*0.55 = 10.1 mm total USB opening width
usb_hole_h = usb_h + 1.2;
usb_hole_corner_r = 0.8;
usb_lead_in_depth = 1.0; // outer-face chamfer depth for easier plug insertion
usb_lead_in_delta = 0.45; // outer-face profile expansion for the lead-in chamfer
usb_hole_open_top = false; // closed, connector-sized USB opening
usb_hole_z_offset = 0.0; // align opening center to USB-C connector center

screw_post_d = 6.5;
screw_thread_d = 2.15; // pilot for M2.5 thread-forming screws in plastic
screw_thread_tip_clear = 0.6; // pilot depth beyond the screw tip

switch_hole_w = (abs(switch_rot_y) % 180 == 90) ? switch_h : switch_w;
switch_hole_h = (abs(switch_rot_y) % 180 == 90) ? switch_w : switch_h;
switch_usb_gap = 0.6;

brand_text = "Crimpdeq";
brand_font = "Liberation Sans:style=Bold"; // bundled with OpenSCAD
brand_size = 9.5;
brand_depth = 0.8;
rear_brand_text = "crimpdeq.com";
rear_brand_font = brand_font;
rear_brand_w = 32; // fixed width so the text fits the rear wall
rear_brand_depth = 0.8;
rear_brand_margin = 3;

// Parameters
show_assembly = true;
show_lid_preview = true;
lid_preview_z_offset = 0; // mm (above main part)
lid_preview_alpha = 0.8; // higher alpha = more opaque
print_layout = false; // true: place bottom on Z=0 for direct STL slicing

/*** Derived placement ***/
usb_front_y = usb_y + usb_d / 2;

// Top of stacked electronics (battery + PCB) used to size enclosure height.
inner_z_max = pcb_top_z + top_clear;

outer_z_min = inner_z_min - floor_t;
outer_z_max = inner_z_max;

notch_x1 = -lc_L / 2 + notch_xA;
notch_x2 = -lc_L / 2 + notch_xB;
notch_y1 = -lc_W / 2;
notch_y2 = lc_W / 2;
notch_pin_d = max(0.2, notch_d - notch_pin_clear);
notch_pin_h = 6 + loadcell_lift;

usb_center_z = pcb_board_bottom_z - usb_h / 2;
usb_hole_w = usb_w + 2 * usb_clear_x + usb_hole_extra_w;
usb_hole_center_z = usb_center_z + usb_hole_z_offset;
usb_hole_bottom_z = usb_hole_center_z - usb_hole_h / 2;
usb_hole_top_z = usb_hole_center_z + usb_hole_h / 2;
usb_hole_cut_top_z = usb_hole_open_top ? outer_z_max : usb_hole_top_z;

// The screw passes the lid material under its head recess, then threads in.
thread_depth = screw_len - (lid_t - screw_head_recess) + screw_thread_tip_clear;

switch_hole_z_min = outer_z_min + switch_hole_h / 2;
switch_hole_z_pref = max(switch_z, switch_hole_z_min);
switch_hole_z_max = usb_hole_center_z - usb_hole_h / 2 - switch_usb_gap - switch_hole_h / 2;
switch_hole_z = max(switch_hole_z_min, min(switch_hole_z_pref, switch_hole_z_max));
switch_y_min = switch_y - switch_d / 2;
loadcell_y_max = lc_W / 2;
switch_top_z = switch_z + switch_h_eff / 2;
switch_hole_usb_gap = usb_hole_center_z - usb_hole_h / 2 - (switch_hole_z + switch_hole_h / 2);
battery_rear_gap_actual = (battery_y_offset - bat_L / 2) - inner_y_min;
battery_front_gap_actual = inner_y_max - (battery_y_offset + bat_L / 2);
pcb_rear_gap_actual = (pcb_y_offset - pcb_L / 2) - inner_y_min;
pcb_front_gap_actual = inner_y_max - (pcb_y_offset + pcb_L / 2);
connector_wall_gap_actual = inner_y_max - (pcb_y_offset + usb_front_y);
pcb_guide_top_z = pcb_board_top_z + pcb_guide_above;
bat_col_x = bat_W / 2 - battery_support_corner_inset - battery_support_corner_size / 2;
bat_col_y = bat_L / 2 - battery_support_corner_inset - battery_support_corner_size / 2;
front_column_min_y = loadcell_y_max + battery_support_front_column_clear + battery_support_corner_size / 2;
front_anchor_y = max(battery_y_offset + bat_col_y, front_column_min_y);

assert(switch_y_min >= loadcell_y_max,
    str("Switch overlaps load cell by ", loadcell_y_max - switch_y_min, " mm (Y)."));
assert(switch_top_z <= pcb_bottom_z,
    str("Switch overlaps PCB by ", switch_top_z - pcb_bottom_z, " mm (Z)."));
assert(switch_hole_z_min <= switch_hole_z_max,
    "Switch opening cannot fit below USB opening without overlap.");
assert(switch_hole_usb_gap >= switch_usb_gap - 0.001,
    str("Switch/USB opening gap too small: ", switch_hole_usb_gap, " mm."));
assert(battery_rear_gap_actual >= -0.001 && battery_front_gap_actual >= -0.001,
    str("Battery exceeds cavity bounds. rear_gap=", battery_rear_gap_actual, " front_gap=", battery_front_gap_actual));
assert(pcb_front_gap >= 0 && pcb_front_gap <= front_clear + rear_clear,
    str("pcb_front_gap out of range: ", pcb_front_gap, " mm."));
assert(pcb_rear_gap_actual >= -0.001 && pcb_front_gap_actual >= -0.001,
    str("PCB exceeds cavity bounds. rear_gap=", pcb_rear_gap_actual, " front_gap=", pcb_front_gap_actual));
assert(abs(pcb_front_gap_actual - pcb_front_gap) <= 0.01,
    str("PCB front wall clearance mismatch: target=", pcb_front_gap, " actual=", pcb_front_gap_actual));
assert(connector_wall_gap_actual >= -0.001,
    str("USB connector extends into the front wall by ", -connector_wall_gap_actual, " mm."));
assert(pcb_guide_top_z < outer_z_max - 0.5,
    "PCB edge guides must stay below the lid.");
assert(pcb_battery_tongue_front_clear >= 0,
    str("pcb_battery_tongue_front_clear must be >= 0. Got ", pcb_battery_tongue_front_clear, " mm."));
assert(pcb_battery_tongue_top_clear >= 0,
    str("pcb_battery_tongue_top_clear must be >= 0. Got ", pcb_battery_tongue_top_clear, " mm."));
assert(pcb_battery_tongue_bottom_clear >= 0,
    str("pcb_battery_tongue_bottom_clear must be >= 0. Got ", pcb_battery_tongue_bottom_clear, " mm."));
assert(pcb_guide_lead_in > 0 && pcb_guide_lead_in < pcb_guide_above + pcb_board_t,
    str("pcb_guide_lead_in must stay within the edge guides. Got ", pcb_guide_lead_in, " mm."));
assert(usb_hole_w > 0 && usb_hole_h > 0,
    str("USB opening envelope must be positive. w=", usb_hole_w, " h=", usb_hole_h));
assert(usb_hole_corner_r >= 0,
    str("usb_hole_corner_r must be >= 0. Got ", usb_hole_corner_r, " mm."));
assert(usb_lead_in_depth >= 0,
    str("usb_lead_in_depth must be >= 0. Got ", usb_lead_in_depth, " mm."));
assert(usb_lead_in_delta >= 0,
    str("usb_lead_in_delta must be >= 0. Got ", usb_lead_in_delta, " mm."));
assert(usb_hole_open_top || usb_hole_top_z <= outer_z_max - 0.1,
    str("USB opening reaches lid seam by ", usb_hole_top_z - outer_z_max, " mm. Lower usb_hole_z_offset."));
assert(usb_plug_shell_w > 0 && usb_plug_shell_h > 0,
    str("USB plug shell envelope must be positive. w=", usb_plug_shell_w, " h=", usb_plug_shell_h));
assert(usb_plug_shell_corner_r >= 0,
    str("usb_plug_shell_corner_r must be >= 0. Got ", usb_plug_shell_corner_r, " mm."));
assert(screw_post_d > screw_thread_d,
    str("screw_post_d must exceed screw_thread_d. post_d=", screw_post_d, " thread_d=", screw_thread_d));
assert(thread_depth <= outer_z_max - outer_z_min - 1,
    str("Screw pilot depth ", thread_depth, " mm does not fit the post."));
assert(rear_brand_w <= 2 * (rear_face_x - rear_brand_margin),
    str("Rear brand is wider than the rear wall. w=", rear_brand_w, " face=", 2 * rear_face_x, " mm."));
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

module bottom_rounded_rect_2d(x_min, x_max, y_min, y_max, r) {
    w = x_max - x_min;
    h = y_max - y_min;
    rr = max(0, min(r, w / 2 - 0.01, h - 0.01));

    if (rr > 0) {
        union() {
            translate([x_min, y_min + rr])
                square([w, h - rr], center = false);
            translate([x_min + rr, y_min])
                square([w - 2 * rr, rr], center = false);
            translate([x_min + rr, y_min + rr])
                circle(r = rr);
            translate([x_max - rr, y_min + rr])
                circle(r = rr);
        }
    } else {
        translate([x_min, y_min])
            square([w, h], center = false);
    }
}

module usb_opening_2d() {
    if (usb_hole_open_top)
        bottom_rounded_rect_2d(
            usb_x - usb_hole_w / 2,
            usb_x + usb_hole_w / 2,
             usb_hole_bottom_z,
             usb_hole_cut_top_z,
             usb_hole_corner_r
        );
    else
        rounded_rect_2d(
            usb_x - usb_hole_w / 2,
            usb_x + usb_hole_w / 2,
             usb_hole_bottom_z,
             usb_hole_cut_top_z,
             usb_hole_corner_r
        );
}

module usb_opening_profile_2d(delta = 0) {
    if (delta > 0)
        offset(delta = delta)
            usb_opening_2d();
    else
        usb_opening_2d();
}

module usb_opening_slice(y_pos, delta = 0, slice_t = 0.02) {
    translate([0, y_pos, 0])
        rotate([90, 0, 0])
            linear_extrude(height = slice_t, center = true)
                usb_opening_profile_2d(delta);
}

module usb_opening_cut() {
    translate([0, inner_y_max + wall_t / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = wall_t + 0.3, center = true)
                usb_opening_profile_2d();

    chamfer_depth = min(max(0, usb_lead_in_depth), wall_t + 0.15);
    if (chamfer_depth > 0 && usb_lead_in_delta > 0) {
        hull() {
            usb_opening_slice(outer_y_max - chamfer_depth, 0);
            usb_opening_slice(outer_y_max, usb_lead_in_delta);
        }
    }
}

module usb_plug_shell_profile_2d() {
    rounded_rect_2d(
        usb_x - usb_plug_shell_w / 2,
        usb_x + usb_plug_shell_w / 2,
         usb_center_z - usb_plug_shell_h / 2,
         usb_center_z + usb_plug_shell_h / 2,
         usb_plug_shell_corner_r
    );
}

module usb_cable_fit_probe() {
    probe_y_min = inner_y_max + 0.05;
    probe_y_max = outer_y_max + 0.2;
    probe_y_mid = (probe_y_min + probe_y_max) / 2;

    translate([0, probe_y_mid, 0])
        rotate([90, 0, 0])
            linear_extrude(height = probe_y_max - probe_y_min, center = true)
                usb_plug_shell_profile_2d();
}

module notch_pin(x, y) {
    translate([x, y, inner_z_min + notch_pin_h / 2 - notch_pin_embed])
        cylinder(d = notch_pin_d, h = notch_pin_h, center = true);
}

module loadcell_support() {
    if (loadcell_lift > 0) {
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
}

module battery_support_bed() {
    if (loadcell_to_battery_gap > 0) {
        support_xy = battery_support_corner_size;
        pad_bottom_gap = max(0, min(battery_support_bottom_gap, loadcell_to_battery_gap - 0.2));
        pad_h = max(0.2, loadcell_to_battery_gap - pad_bottom_gap);
        brace_t = max(0.2, min(0.8, pad_h));
        pad_bottom_z = loadcell_top_z + pad_bottom_gap;
        pad_z = loadcell_top_z + pad_bottom_gap + pad_h / 2;
        guide_h = min(battery_guide_h, bat_T);
        guide_bottom_z = battery_bottom_z;
        guide_z = battery_bottom_z + guide_h / 2;
        support_x = bat_W / 2 - battery_support_corner_inset - support_xy / 2;
        support_y = bat_L / 2 - battery_support_corner_inset - support_xy / 2;
        front_column_min_y = loadcell_y_max + battery_support_front_column_clear + support_xy / 2;

        for (x_sign = [-1, 1])
            for (y_sign = [-1, 1])
                let(
                    pad_y = battery_y_offset + y_sign * support_y,
                    col_y = (y_sign > 0) ? max(pad_y, front_column_min_y) : pad_y,
                    col_h = (loadcell_top_z + loadcell_to_battery_gap) - (inner_z_min - internal_feature_embed),
                    col_z = inner_z_min - internal_feature_embed + col_h / 2,
                    shelf_len = abs(col_y - pad_y) + support_xy,
                    shelf_y = (col_y + pad_y) / 2,
                    x_leg_x = x_sign * (bat_W / 2 + battery_guide_clear + battery_guide_t / 2),
                    y_leg_y = battery_y_offset + y_sign * (bat_L / 2 + battery_guide_clear + battery_guide_t / 2),
                    x_bridge_x0 = x_sign * (support_x + support_xy / 2),
                    x_bridge_x1 = x_sign * (bat_W / 2 + battery_guide_clear),
                    x_bridge_len = abs(x_bridge_x1 - x_bridge_x0),
                    x_bridge_x = (x_bridge_x0 + x_bridge_x1) / 2,
                    y_bridge_y0 = pad_y + y_sign * support_xy / 2,
                    y_bridge_y1 = battery_y_offset + y_sign * (bat_L / 2 + battery_guide_clear),
                    y_bridge_len = abs(y_bridge_y1 - y_bridge_y0),
                    y_bridge_y = (y_bridge_y0 + y_bridge_y1) / 2,
                    x_leg_col_h = max(0, guide_bottom_z - (inner_z_min - internal_feature_embed)),
                    x_leg_col_z = inner_z_min - internal_feature_embed + x_leg_col_h / 2,
                    y_leg_col_h = max(0, guide_bottom_z - (inner_z_min - internal_feature_embed)),
                    y_leg_col_z = inner_z_min - internal_feature_embed + y_leg_col_h / 2
                ) {
                    // Floor-anchored column.
                    translate([x_sign * support_x, col_y, col_z])
                        cube([support_xy, support_xy, col_h], center = true);

                    // Keep the load-cell top insertion path clear:
                    // only support/guide the battery from the rear corners (outside load-cell Y footprint).
                    if (y_sign < 0) {
                        // Battery corner support pad in the 2 mm gap (rear only).
                        translate([x_sign * support_x, pad_y, pad_z])
                            cube([support_xy, support_xy, pad_h], center = true);

                        // Brace column to rear pad to avoid a flat bridge.
                        if (abs(col_y - pad_y) > 0.01)
                            hull() {
                                translate([x_sign * support_x, col_y, guide_bottom_z - brace_t / 2])
                                    cube([support_xy, support_xy, brace_t], center = true);
                                translate([x_sign * support_x, pad_y, pad_bottom_z + brace_t / 2])
                                    cube([support_xy, support_xy, brace_t], center = true);
                            }

                        // Rear corner guides keep the battery located without blocking top load-cell insertion.
                        translate([x_leg_x, pad_y, guide_z])
                            cube([battery_guide_t, support_xy, guide_h], center = true);
                        translate([x_sign * support_x, y_leg_y, guide_z])
                            cube([support_xy, battery_guide_t, guide_h], center = true);

                        // Fully support the horizontal guide tabs to improve printability.
                        if (x_leg_col_h > 0.01)
                            translate([x_leg_x, pad_y, x_leg_col_z])
                                cube([battery_guide_t, support_xy, x_leg_col_h], center = true);
                        if (y_leg_col_h > 0.01)
                            translate([x_sign * support_x, y_leg_y, y_leg_col_z])
                                cube([support_xy, battery_guide_t, y_leg_col_h], center = true);
                        if (x_bridge_len > 0.01 && x_leg_col_h > 0.01)
                            translate([x_bridge_x, pad_y, x_leg_col_z])
                                cube([x_bridge_len, support_xy, x_leg_col_h], center = true);
                        if (y_bridge_len > 0.01 && y_leg_col_h > 0.01)
                            translate([x_sign * support_x, y_bridge_y, y_leg_col_z])
                                cube([support_xy, y_bridge_len, y_leg_col_h], center = true);

                        if (x_bridge_len > 0.01)
                            hull() {
                                translate([x_leg_x, pad_y, guide_bottom_z - brace_t / 2])
                                    cube([battery_guide_t, support_xy, brace_t], center = true);
                                translate([x_sign * support_x, pad_y, pad_bottom_z + brace_t / 2])
                                    cube([support_xy, support_xy, brace_t], center = true);
                            }
                        if (y_bridge_len > 0.01)
                            hull() {
                                translate([x_sign * support_x, y_leg_y, guide_bottom_z - brace_t / 2])
                                    cube([support_xy, battery_guide_t, brace_t], center = true);
                                translate([x_sign * support_x, pad_y, pad_bottom_z + brace_t / 2])
                                    cube([support_xy, support_xy, brace_t], center = true);
                            }
                    }
                }
    }
}

module box(x, y, z) {
    translate([min(x), min(y), min(z)])
        cube([abs(x[1] - x[0]), abs(y[1] - y[0]), abs(z[1] - z[0])]);
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

// Front columns stop the battery and carry the front PCB pads; rails over the
// battery edges guide the PCB sides and carry the rear pads and rear stops.
module pcb_supports() {
    col_x = [bat_col_x - battery_support_corner_size / 2, bat_col_x + battery_support_corner_size / 2];
    col_y = [front_anchor_y - battery_support_corner_size / 2, front_anchor_y + battery_support_corner_size / 2];
    rail_x = [pcb_W / 2 + pcb_guide_clear, bat_W / 2 + battery_guide_clear];
    rail_z = [battery_top_z + pcb_rail_battery_clear, pcb_guide_top_z];
    stop_y = [pcb_rear_y - pcb_guide_clear - pcb_rear_stop_depth, pcb_rear_y];
    tongue_y = [battery_front_y - pcb_battery_tongue_front_clear, col_y[0] + 0.01];
    tongue_z = [loadcell_top_z + pcb_battery_tongue_bottom_clear, battery_bottom_z - pcb_battery_tongue_top_clear];

    difference() {
        union() {
            for (s = [-1, 1]) {
                box(s * col_x, col_y, [battery_bottom_z, pcb_guide_top_z]);
                box(s * rail_x, [stop_y[0], col_y[0] + 0.01], rail_z);
                box(s * [pcb_W / 2 - pcb_rear_stop_w, rail_x[1]], stop_y, rail_z);
                // Prop the battery front underside.
                box(s * col_x, tongue_y, tongue_z);
            }

            // Pads under the windows that sit over the battery, tied to the rails.
            for (w = pcb_support_windows)
                if (pcb_y_offset + w[2] < battery_front_y)
                    box(
                        w[0] > 0 ? [w[0], rail_x[0] + 0.01] : [-rail_x[0] - 0.01, w[1]],
                        [pcb_y_offset + w[2], pcb_y_offset + w[3]],
                        [rail_z[0], pcb_board_bottom_z]
                    );
        }
        pcb_keepout();
    }
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
    if (depth > 0) {
        hole_h = depth + 0.2;
        hole_z = z_top - depth / 2 + 0.1;
        each_corner(hole_z)
            cylinder(d = d, h = hole_h, center = true);
    }
}

module corner_screw_posts(d, z0, z1) {
    post_h = z1 - z0;
    if (post_h > 0) {
        post_z = (z0 + z1) / 2;
        each_corner(post_z)
            cylinder(d = d, h = post_h, center = true);
    }
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
            battery_support_bed();
            pcb_supports();
            notch_pins();
            loadcell_notch_guides();
            main_carabiner_slot_walls();

            // Internal cylindrical bosses for screw engagement.
            corner_screw_posts(screw_post_d, outer_z_min, outer_z_max);
        }

        corner_thread_holes(screw_thread_d, outer_z_max, thread_depth);

        carabiner_slot_cuts();

        // Internal cavity for side switch (KCD11, 10x15 face).
        translate([switch_x, switch_y, switch_z])
            rotate([0, switch_rot_y, 0])
                cube(
                    [switch_w + 2 * switch_clear, switch_d + 2 * switch_clear, switch_h + 2 * switch_clear],
                    center = true
                );

        // Side opening for switch face on +Y wall (USB side).
        translate([switch_x, inner_y_max + wall_t / 2, switch_hole_z])
            cube([switch_hole_w, wall_t + 0.3, switch_hole_h], center = true);

        // Connector-sized USB opening with rounded corners and an outer lead-in chamfer.
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
