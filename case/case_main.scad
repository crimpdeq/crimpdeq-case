//
// Main enclosure part (base body)
// - USB-C opening
// - load-cell notch retention pins
// - load-cell eye access holes
// - corner threaded pilot holes for M2.5x10 screws
//

include <dimensions.scad>
use <load_cell.scad>
use <assembly.scad>
use <case_lid.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
wall_t = 3;
floor_t = 3;
corner_r = 6;

eye_access_clear = 1.0;
notch_pin_clear = 0.2;
notch_pin_embed = 0.4;
notch_pin_top_clear = 1.0;
u_cutout_clear = 2.0;
loadcell_notch_guide_len = 7.5;
loadcell_notch_guide_w = 1.0;
loadcell_notch_guide_h = 4;
loadcell_notch_guide_clear = 0.2;
loadcell_support_corner_size = 8;
loadcell_support_corner_inset = 2;
loadcell_u_support_t = 2;
battery_support_corner_size = 8;
battery_support_corner_inset = 2;
battery_support_front_column_clear = 2;
battery_support_bottom_gap = 0.5;
battery_guide_clear = 0.5;
battery_guide_t = 1.8;
battery_guide_h = bat_T * 0.6;
pcb_guide_clear = 0.35; // a bit more drop-in tolerance without giving up positive side location
pcb_guide_h = 2.6;
pcb_guide_lead_in_h = 0.8;
pcb_guide_side_lead_in = 0.6;
pcb_rear_stop_lead_in = 0.8;
pcb_rear_stop_bottom_gap = 0.6;
pcb_rear_stop_battery_clear = 0.2;
pcb_rear_gap = front_clear + rear_clear - pcb_front_gap;
pcb_rear_stop_w = 4;
pcb_rear_rest_w = 5;
pcb_rear_rest_depth = 3.8; // extends slightly under the PCB rear edge so it actually lands on the shelves
pcb_rear_rest_stop_gap = 0.0; // merge the rear shelf into the stopper as a single rear corner cradle
pcb_battery_tongue_enable = true;
pcb_battery_tongue_front_clear = 3.5; // overlap under battery front edge
pcb_battery_tongue_top_clear = 0.0; // 0 = touches battery underside
pcb_battery_tongue_bottom_clear = 0.2; // keep clear of load-cell top

usb_clear_x = 1.2;
usb_hole_extra_w = 0.6; // 9 + 2*1.2 + 0.6 = 12.0 mm total USB opening width
usb_hole_h = 10.5;
usb_hole_corner_r = 1.0;
usb_lead_in_depth = 1.0; // outer-face chamfer depth for easier plug insertion
usb_lead_in_delta = 0.6; // outer-face profile expansion for the lead-in chamfer
usb_hole_open_top = true; // remove the thin upper wall above the USB opening for printability
usb_hole_z_offset = 2.0; // shift USB opening upward relative to connector center

screw_post_d = 6.5;
screw_thread_d = 2.15; // pilot for M2.5 thread-forming screws in plastic
screw_thread_depth = 9.0; // for M2.5x10 with recessed-head lid and better thread engagement margin
screw_thread_tip_clear = 1.0;

switch_hole_w = (abs(switch_rot_y) % 180 == 90) ? switch_h : switch_w;
switch_hole_h = (abs(switch_rot_y) % 180 == 90) ? switch_w : switch_h;
switch_usb_gap = 0.6;

brand_text = "Crimpdeq";
brand_font = "Inter:style=Bold";
brand_size = 9.5;
brand_depth = 0.8;
rear_brand_text = "crimpdeq.com";
rear_brand_font = "Inter:style=Bold";
rear_brand_size = 6.0;
rear_brand_depth = 0.8;

// Parameters
show_assembly = true;
show_lid_preview = true;
lid_preview_z_offset = 0; // mm (above main part)
lid_preview_alpha = 0.8; // higher alpha = more opaque
print_layout = false; // true: place bottom on Z=0 for direct STL slicing

/*** Derived placement ***/
inner_x_min = -lc_L / 2 - clear_x;
inner_x_max = lc_L / 2 + clear_x;

inner_y_min = -pcb_L / 2 - rear_clear;
usb_front_y = pcb_L / 2; // connector flush with PCB edge (no overhang)
inner_y_max = usb_front_y + front_clear;
brand_y = 0; // centered between U cutouts

inner_z_min = -lc_T / 2;
loadcell_bottom_z = inner_z_min + loadcell_lift;
loadcell_center_z = loadcell_bottom_z + lc_T / 2;
loadcell_top_z = loadcell_bottom_z + lc_T;
// Top of stacked electronics (battery + PCB) used to size enclosure height.
pcb_top_z = loadcell_top_z + loadcell_to_battery_gap + bat_T + battery_to_pcb_gap + pcb_T;
inner_z_max = pcb_top_z + top_clear;

outer_x_min = inner_x_min - wall_t;
outer_x_max = inner_x_max + wall_t;
outer_y_min = inner_y_min - wall_t;
outer_y_max = inner_y_max + wall_t;
outer_z_min = inner_z_min - floor_t;
outer_z_max = inner_z_max;
inner_corner_r = max(0, corner_r - wall_t);

eye_x1 = -lc_L / 2 + eye_center_offset;
eye_x2 = lc_L / 2 - eye_center_offset;
eye_access_d = eye_d + eye_access_clear;
u_cutout_z_d = eye_access_d + 2 * u_cutout_clear;
u_cutout_z_r = u_cutout_z_d / 2;
u_cutout_y_span = lc_W;
battery_y_offset = inner_y_min + battery_rear_gap + bat_L / 2;
battery_bottom_z = loadcell_top_z + loadcell_to_battery_gap;
pcb_y_offset = front_clear - pcb_front_gap;

notch_x2 = -lc_L / 2 + notch_xB;
notch_y1 = -lc_W / 2;
notch_y2 = lc_W / 2;
notch_pin_d = max(0.2, notch_d - notch_pin_clear);
notch_pin_h = 6 + loadcell_lift;

pcb_center_z = loadcell_top_z + loadcell_to_battery_gap + bat_T + battery_to_pcb_gap + pcb_T / 2;
usb_center_z = pcb_center_z + (pcb_T / 2 + usb_h / 2 - usb_inset);
usb_hole_w = usb_w + 2 * usb_clear_x + usb_hole_extra_w;
usb_hole_center_z = usb_center_z + usb_hole_z_offset;
usb_hole_bottom_z = usb_hole_center_z - usb_hole_h / 2;
usb_hole_top_z = usb_hole_center_z + usb_hole_h / 2;
usb_hole_cut_top_z = usb_hole_open_top ? outer_z_max : usb_hole_top_z;

screw_x1 = outer_x_min + screw_corner_inset;
screw_x2 = outer_x_max - screw_corner_inset;
screw_y1 = outer_y_min + screw_corner_inset;
screw_y2 = outer_y_max - screw_corner_inset;
max_thread_depth = max(0, (outer_z_max - outer_z_min) - screw_thread_tip_clear);
thread_depth = min(screw_thread_depth, max_thread_depth);

switch_x = 0;
switch_y = inner_y_max - switch_d / 2 - switch_clear;
switch_h_eff = (abs(switch_rot_y) % 180 == 90) ? switch_w : switch_h;
switch_z = inner_z_min + switch_h_eff / 2;
switch_hole_z_min = outer_z_min + switch_hole_h / 2;
switch_hole_z_pref = max(switch_z, switch_hole_z_min);
switch_hole_z_max = usb_hole_center_z - usb_hole_h / 2 - switch_usb_gap - switch_hole_h / 2;
switch_hole_z = max(switch_hole_z_min, min(switch_hole_z_pref, switch_hole_z_max));
switch_y_min = switch_y - switch_d / 2;
loadcell_y_max = lc_W / 2;
switch_top_z = switch_z + switch_h_eff / 2;
pcb_bottom_z = loadcell_top_z + loadcell_to_battery_gap + bat_T + battery_to_pcb_gap;
switch_hole_usb_gap = usb_hole_center_z - usb_hole_h / 2 - (switch_hole_z + switch_hole_h / 2);
battery_rear_gap_actual = (battery_y_offset - bat_L / 2) - inner_y_min;
battery_front_gap_actual = inner_y_max - (battery_y_offset + bat_L / 2);
pcb_rear_gap_actual = (pcb_y_offset - pcb_L / 2) - inner_y_min;
pcb_front_gap_actual = inner_y_max - (pcb_y_offset + pcb_L / 2);
pcb_guide_riser_w = (bat_W / 2 - battery_support_corner_inset) - (pcb_W / 2 + pcb_guide_clear);

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
    str("PCB front gap mismatch: target=", pcb_front_gap, " actual=", pcb_front_gap_actual));
assert(pcb_rear_stop_bottom_gap >= 0 && pcb_rear_stop_bottom_gap <= pcb_T - 0.2,
    str("pcb_rear_stop_bottom_gap out of range: ", pcb_rear_stop_bottom_gap, " mm."));
assert(pcb_rear_stop_battery_clear >= 0,
    str("pcb_rear_stop_battery_clear must be >= 0. Got ", pcb_rear_stop_battery_clear, " mm."));
assert(pcb_rear_rest_w > 0,
    str("pcb_rear_rest_w must be > 0. Got ", pcb_rear_rest_w, " mm."));
assert(pcb_rear_rest_depth >= 0,
    str("pcb_rear_rest_depth must be >= 0. Got ", pcb_rear_rest_depth, " mm."));
assert(pcb_rear_rest_stop_gap >= 0,
    str("pcb_rear_rest_stop_gap must be >= 0. Got ", pcb_rear_rest_stop_gap, " mm."));
assert(pcb_battery_tongue_front_clear >= 0,
    str("pcb_battery_tongue_front_clear must be >= 0. Got ", pcb_battery_tongue_front_clear, " mm."));
assert(pcb_battery_tongue_top_clear >= 0,
    str("pcb_battery_tongue_top_clear must be >= 0. Got ", pcb_battery_tongue_top_clear, " mm."));
assert(pcb_battery_tongue_bottom_clear >= 0,
    str("pcb_battery_tongue_bottom_clear must be >= 0. Got ", pcb_battery_tongue_bottom_clear, " mm."));
assert(pcb_guide_riser_w > 0.01,
    str("PCB side-guide riser collapsed. Increase battery width support or reduce pcb_guide_clear. riser_w=", pcb_guide_riser_w));
assert(pcb_guide_lead_in_h >= 0 && pcb_guide_side_lead_in >= 0 && pcb_rear_stop_lead_in >= 0,
    str("PCB drop-in lead-in parameters must be >= 0. h=", pcb_guide_lead_in_h,
        " side=", pcb_guide_side_lead_in, " rear=", pcb_rear_stop_lead_in));
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
assert(usb_cable_boot_w > 0 && usb_cable_boot_h > 0,
    str("USB cable boot envelope must be positive. w=", usb_cable_boot_w, " h=", usb_cable_boot_h));
assert(usb_cable_boot_corner_r >= 0,
    str("usb_cable_boot_corner_r must be >= 0. Got ", usb_cable_boot_corner_r, " mm."));
assert(screw_post_d > screw_thread_d,
    str("screw_post_d must exceed screw_thread_d. post_d=", screw_post_d, " thread_d=", screw_thread_d));
assert(screw_x1 < screw_x2 && screw_y1 < screw_y2,
    str("screw_corner_inset too large for enclosure footprint. inset=", screw_corner_inset, " mm."));
assert(rear_brand_depth > 0 && rear_brand_depth < wall_t,
    str("rear_brand_depth must be > 0 and < wall_t (", wall_t, " mm)."));

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

module rounded_block_xy(min_v, max_v, r) {
    translate([0, 0, min_v[2]])
        linear_extrude(height = max_v[2] - min_v[2], center = false)
            rounded_rect_2d(min_v[0], max_v[0], min_v[1], max_v[1], r);
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
            -usb_hole_w / 2,
             usb_hole_w / 2,
             usb_hole_bottom_z,
             usb_hole_cut_top_z,
             usb_hole_corner_r
        );
    else
        rounded_rect_2d(
            -usb_hole_w / 2,
             usb_hole_w / 2,
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

module usb_cable_boot_profile_2d() {
    rounded_rect_2d(
        -usb_cable_boot_w / 2,
         usb_cable_boot_w / 2,
         usb_center_z - usb_cable_boot_h / 2,
         usb_center_z + usb_cable_boot_h / 2,
         usb_cable_boot_corner_r
    );
}

module usb_cable_fit_probe() {
    probe_y_min = inner_y_max + 0.05;
    probe_y_max = outer_y_max + 0.2;
    probe_y_mid = (probe_y_min + probe_y_max) / 2;

    translate([0, probe_y_mid, 0])
        rotate([90, 0, 0])
            linear_extrude(height = probe_y_max - probe_y_min, center = true)
                usb_cable_boot_profile_2d();
}

module notch_pin(x, y) {
    translate([x, y, inner_z_min + notch_pin_h / 2 - notch_pin_embed])
        cylinder(d = notch_pin_d, h = notch_pin_h, center = true);
}

module loadcell_support() {
    if (loadcell_lift > 0) {
        support_xy = loadcell_support_corner_size;
        support_z = inner_z_min + loadcell_lift / 2;
        support_x = lc_L / 2 - loadcell_support_corner_inset - support_xy / 2;
        support_y = lc_W / 2 - loadcell_support_corner_inset - support_xy / 2;

        for (x_sign = [-1, 1])
            for (y_sign = [-1, 1])
                let(
                    sx = x_sign * support_x,
                    sy = y_sign * support_y,
                    x0 = sx - support_xy / 2,
                    x1 = sx + support_xy / 2,
                    y0 = sy - support_xy / 2,
                    y1 = sy + support_xy / 2,
                    gap_x_min = x0 - inner_x_min,
                    gap_x_max = inner_x_max - x1,
                    gap_y_min = y0 - inner_y_min,
                    gap_y_max = inner_y_max - y1,
                    use_x_min = gap_x_min <= gap_x_max && gap_x_min <= gap_y_min && gap_x_min <= gap_y_max,
                    use_x_max = !use_x_min && gap_x_max <= gap_y_min && gap_x_max <= gap_y_max,
                    use_y_min = !use_x_min && !use_x_max && gap_y_min <= gap_y_max,
                    span_x = use_x_min ? (x1 - inner_x_min) : use_x_max ? (inner_x_max - x0) : support_xy,
                    span_y = use_y_min ? (y1 - inner_y_min) : (!use_x_min && !use_x_max && !use_y_min) ? (inner_y_max - y0) : support_xy,
                    center_x = use_x_min ? (inner_x_min + x1) / 2 : use_x_max ? (x0 + inner_x_max) / 2 : sx,
                    center_y = use_y_min ? (inner_y_min + y1) / 2 : (!use_x_min && !use_x_max && !use_y_min) ? (y0 + inner_y_max) / 2 : sy
                )
                    translate([center_x, center_y, support_z])
                        cube([span_x, span_y, loadcell_lift], center = true);
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
                    col_h = (loadcell_top_z + loadcell_to_battery_gap) - inner_z_min,
                    col_z = inner_z_min + col_h / 2,
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
                    x_leg_col_h = max(0, guide_bottom_z - inner_z_min),
                    x_leg_col_z = inner_z_min + x_leg_col_h / 2,
                    y_leg_col_h = max(0, guide_bottom_z - inner_z_min),
                    y_leg_col_z = inner_z_min + y_leg_col_h / 2
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

module pcb_horizontal_guides() {
    guide_h = min(pcb_guide_h, pcb_T);
    guide_top_z = pcb_bottom_z + guide_h;
    bat_col_x = bat_W / 2 - battery_support_corner_inset - battery_support_corner_size / 2;
    bat_col_y = bat_L / 2 - battery_support_corner_inset - battery_support_corner_size / 2;
    front_column_min_y = loadcell_y_max + battery_support_front_column_clear + battery_support_corner_size / 2;
    front_anchor_y = max(battery_y_offset + bat_col_y, front_column_min_y);
    riser_z0 = battery_bottom_z;
    riser_h = max(0, guide_top_z - riser_z0);
    riser_z = riser_z0 + riser_h / 2;
    pcb_support_h = max(0, pcb_bottom_z - riser_z0);
    pcb_support_z = riser_z0 + pcb_support_h / 2;
    col_inner_x = bat_col_x - battery_support_corner_size / 2;
    col_outer_x = bat_col_x + battery_support_corner_size / 2;
    guide_inner_x = pcb_W / 2 + pcb_guide_clear;
    // Fill the seam below the PCB while keeping the side-guide clearance above the PCB underside.
    pcb_support_outer_x = min(col_outer_x, guide_inner_x);
    pcb_support_w = pcb_support_outer_x - col_inner_x;
    pcb_support_x = (col_inner_x + pcb_support_outer_x) / 2;
    riser_w = col_outer_x - guide_inner_x;
    riser_x = (col_outer_x + guide_inner_x) / 2;
    riser_lead_in_h = min(riser_h, pcb_guide_lead_in_h);
    riser_body_h = max(0, riser_h - riser_lead_in_h);
    riser_top_inset = min(max(0, pcb_guide_side_lead_in), max(0, riser_w - 0.2));
    riser_top_w = max(0.2, riser_w - riser_top_inset);
    riser_top_x = riser_x + riser_top_inset / 2;
    battery_front_y = battery_y_offset + bat_L / 2;
    support_back_y = front_anchor_y;
    tongue_front_y = battery_front_y - pcb_battery_tongue_front_clear;
    tongue_l = max(0, support_back_y - tongue_front_y);
    tongue_y = (support_back_y + tongue_front_y) / 2;
    tongue_top_z = battery_bottom_z - pcb_battery_tongue_top_clear;
    tongue_bottom_z = loadcell_top_z + pcb_battery_tongue_bottom_clear;
    tongue_h = max(0, tongue_top_z - tongue_bottom_z);
    tongue_z = tongue_bottom_z + tongue_h / 2;

    for (x_sign = [-1, 1]) {
        if (pcb_support_h > 0 && pcb_support_w > 0.01)
            // Extend the inner strip up to the PCB underside to support the front overhang.
            translate([x_sign * pcb_support_x, front_anchor_y, pcb_support_z])
                cube([pcb_support_w, battery_support_corner_size, pcb_support_h], center = true);

        if (riser_h > 0 && riser_w > 0.01) {
            // Use only the outer strip above the PCB to avoid PCB collision, and add
            // a small top lead-in so the PCB edges self-center instead of catching.
            if (riser_body_h > 0.01)
                translate([x_sign * riser_x, front_anchor_y, riser_z0 + riser_body_h / 2])
                    cube([riser_w, battery_support_corner_size, riser_body_h], center = true);

            if (riser_lead_in_h > 0.01)
                hull() {
                    translate([x_sign * riser_x, front_anchor_y, riser_z0 + riser_body_h + 0.01])
                        cube([riser_w, battery_support_corner_size, 0.02], center = true);
                    translate([x_sign * riser_top_x, front_anchor_y, guide_top_z - 0.01])
                        cube([riser_top_w, battery_support_corner_size, 0.02], center = true);
                }
        }

        if (pcb_battery_tongue_enable && tongue_h > 0.01 && tongue_l > 0.01 && pcb_support_w > 0.01)
            // Small tongue from PCB vertical supports to prop the battery front underside.
            translate([x_sign * pcb_support_x, tongue_y, tongue_z])
                cube([pcb_support_w, tongue_l, tongue_h], center = true);
    }
}

module pcb_rear_corner_cradles() {
    stop_top_z = pcb_bottom_z + min(pcb_guide_h, pcb_T);
    stop_bottom_z_pcb = pcb_bottom_z + max(0, min(pcb_rear_stop_bottom_gap, pcb_T - 0.2));
    stop_bottom_z_battery = battery_bottom_z + bat_T + pcb_rear_stop_battery_clear;
    stop_bottom_z = min(stop_bottom_z_pcb, stop_bottom_z_battery, stop_top_z - 0.2);
    stop_h = max(0.2, stop_top_z - stop_bottom_z);
    stop_z = stop_bottom_z + stop_h / 2;
    stop_depth = max(0, pcb_rear_gap);
    stop_x = pcb_W / 2 - pcb_rear_stop_w / 2;
    stop_lead_in_h = min(stop_h, pcb_guide_lead_in_h);
    stop_body_h = max(0, stop_h - stop_lead_in_h);
    stop_top_inset = min(max(0, pcb_rear_stop_lead_in), max(0, stop_depth - 0.2));
    stop_top_depth = max(0.2, stop_depth - stop_top_inset);
    stop_top_y = inner_y_min + stop_top_depth / 2;

    // Rear corner shelf that merges into the wall stop, forming a small cradle
    // for each PCB rear corner instead of two separate features.
    rest_depth = max(0, pcb_rear_rest_depth);
    rest_top_z = pcb_bottom_z;
    rest_bottom_z = stop_bottom_z_battery;
    rest_h = max(0, rest_top_z - rest_bottom_z);
    rest_z = rest_bottom_z + rest_h / 2;
    cradle_overlap = min(pcb_rear_stop_w, 0.2);
    rest_w = pcb_rear_rest_w + cradle_overlap;
    rest_x = pcb_W / 2 - pcb_rear_stop_w - pcb_rear_rest_stop_gap - pcb_rear_rest_w / 2 + cradle_overlap / 2;

    if (stop_depth > 0.01) {
        for (x_sign = [-1, 1]) {
            if (stop_body_h > 0.01)
                translate([x_sign * stop_x, inner_y_min + stop_depth / 2, stop_bottom_z + stop_body_h / 2])
                    cube([pcb_rear_stop_w, stop_depth, stop_body_h], center = true);

            if (stop_lead_in_h > 0.01)
                hull() {
                    translate([x_sign * stop_x, inner_y_min + stop_depth / 2, stop_bottom_z + stop_body_h + 0.01])
                        cube([pcb_rear_stop_w, stop_depth, 0.02], center = true);
                    translate([x_sign * stop_x, stop_top_y, stop_top_z - 0.01])
                        cube([pcb_rear_stop_w, stop_top_depth, 0.02], center = true);
                }

            if (rest_depth > 0.01 && rest_h > 0.01 && rest_x - rest_w / 2 >= 0)
                translate([x_sign * rest_x, inner_y_min + rest_depth / 2, rest_z])
                    cube([rest_w, rest_depth, rest_h], center = true);
        }
    }
}

module notch_pins() {
    for (y = [notch_y1, notch_y2])
        notch_pin(notch_x2, y);
}

module loadcell_notch_guides() {
    guide_h = loadcell_notch_guide_h + loadcell_lift;
    guide_z = inner_z_min + guide_h / 2;
    guide_x = notch_x2 - loadcell_notch_guide_len / 2;
    guide_bottom_y = notch_y1 - loadcell_notch_guide_clear - loadcell_notch_guide_w / 2;
    guide_top_y = notch_y2 + loadcell_notch_guide_clear + loadcell_notch_guide_w / 2;

    translate([guide_x, guide_bottom_y, guide_z])
        cube([loadcell_notch_guide_len, loadcell_notch_guide_w, guide_h], center = true);
    translate([guide_x, guide_top_y, guide_z])
        cube([loadcell_notch_guide_len, loadcell_notch_guide_w, guide_h], center = true);
}

module each_corner(z_pos) {
    for (x = [screw_x1, screw_x2])
        for (y = [screw_y1, screw_y2])
            translate([x, y, z_pos])
                children();
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

module eye_access_holes() {
    for (eye_x = [eye_x1, eye_x2])
        translate([eye_x, 0, outer_z_min - 0.1])
            cylinder(d = eye_access_d, h = floor_t + loadcell_lift + 0.3, center = false);
}

module eye_u_profile_2d(eye_x, open_left = true, x_open_min = outer_x_min - 0.2, x_open_max = outer_x_max + 0.2) {
    union() {
        translate([eye_x, 0])
            circle(d = u_cutout_z_d);

        if (open_left) {
            translate([x_open_min, -u_cutout_z_r])
                square([eye_x - x_open_min, u_cutout_z_d]);
        } else {
            translate([eye_x, -u_cutout_z_r])
                square([x_open_max - eye_x, u_cutout_z_d]);
        }
    }
}

module eye_u_cutout(eye_x, open_left = true) {
    // Overcut in Z so no thin roof remains at the top rim of the main enclosure.
    u_cutout_extrude_h = max(u_cutout_y_span, 2 * (outer_z_max - loadcell_center_z) + 0.4);
    linear_extrude(height = u_cutout_extrude_h, center = true)
        eye_u_profile_2d(eye_x, open_left = open_left);
}

module loadcell_u_cutout_support() {
    support_h = loadcell_lift - 0.5;
    if (support_h > 0 && loadcell_u_support_t > 0) {
        translate([0, 0, inner_z_min])
            linear_extrude(height = support_h, center = false)
                intersection() {
                    union() {
                        difference() {
                            offset(delta = loadcell_u_support_t)
                                eye_u_profile_2d(eye_x1, open_left = true, x_open_min = inner_x_min, x_open_max = inner_x_max);
                            eye_u_profile_2d(eye_x1, open_left = true, x_open_min = inner_x_min, x_open_max = inner_x_max);
                        }
                        difference() {
                            offset(delta = loadcell_u_support_t)
                                eye_u_profile_2d(eye_x2, open_left = false, x_open_min = inner_x_min, x_open_max = inner_x_max);
                            eye_u_profile_2d(eye_x2, open_left = false, x_open_min = inner_x_min, x_open_max = inner_x_max);
                        }
                    }

                    // Keep this support inside the inner cavity footprint.
                    translate([inner_x_min, inner_y_min])
                        square([inner_x_max - inner_x_min, inner_y_max - inner_y_min], center = false);
                }
    }
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
                text(rear_brand_text, size = rear_brand_size, font = rear_brand_font, halign = "center", valign = "center");
}

module main_part() {
    difference() {
        union() {
            difference() {
                rounded_block_xy(
                    [outer_x_min, outer_y_min, outer_z_min],
                    [outer_x_max, outer_y_max, outer_z_max],
                    corner_r
                );
                rounded_block_xy(
                    [inner_x_min, inner_y_min, inner_z_min],
                    [inner_x_max, inner_y_max, outer_z_max + 0.1],
                    inner_corner_r
                );
            }

            loadcell_support();
            loadcell_u_cutout_support();
            battery_support_bed();
            pcb_horizontal_guides();
            pcb_rear_corner_cradles();
            notch_pins();
            loadcell_notch_guides();

            // Internal cylindrical bosses for screw engagement.
            corner_screw_posts(screw_post_d, outer_z_min, outer_z_max);
        }

        corner_thread_holes(screw_thread_d, outer_z_max, thread_depth);

        eye_access_holes();

        // U-shape side access for load-cell eye holes.
        translate([0, 0, loadcell_center_z]) eye_u_cutout(eye_x1, open_left = true);
        translate([0, 0, loadcell_center_z]) eye_u_cutout(eye_x2, open_left = false);

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

        // USB opening with rounded top/bottom corners, an open top seam, and an outer lead-in chamfer.
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

if (show_assembly) {
    if (print_layout) {
        translate([0, 0, -outer_z_min]) %full_assembly();
    } else {
        %full_assembly();
    }
}

if (show_lid_preview) {
    preview_z = (print_layout ? -outer_z_min : 0) + lid_preview_z_offset;
    translate([0, 0, preview_z]) {
        // In preview, show lid with configurable opacity. For renders/exports, keep it as %.
        if ($preview) {
            color([0.8, 0.8, 0.8, lid_preview_alpha])
                if (print_layout) lid_part_print_layout(); else lid_part();
        } else {
            if (print_layout) %lid_part_print_layout(); else %lid_part();
        }
    }
}
