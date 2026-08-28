//
// Main enclosure part (base body)
// - USB-C opening
// - central load-cell saddle with exposed ends
// - corner threaded pilot holes for M2.5x10 screws
//

include <placement.scad>
use <load_cell.scad>
use <assembly.scad>
use <case_lid.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
wall_t = 2.4;
floor_t = 2.4;
corner_r = 6;

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
battery_guide_clear = 0.5;
battery_guide_t = 1.8;
battery_guide_h = bat_T * 0.6;
battery_end_guide_clear = 0.5;
battery_end_guide_t = 1.2;
battery_end_guide_w = 4.0;
pcb_guide_clear = 0.25;
pcb_guide_h = 2.6;
pcb_guide_lead_in_h = 0.8;
pcb_guide_side_lead_in = 0.6;
pcb_rear_stop_lead_in = 0.8;
pcb_rear_stop_bottom_gap = 0.6;
pcb_rear_stop_battery_clear = 0.2;
pcb_rear_stop_depth = 0.8;
pcb_rear_stop_w = 4;
pcb_rear_rest_w = 5;
pcb_rear_rest_depth = 3.8; // extends slightly under the PCB rear edge so it actually lands on the shelves
pcb_rear_rest_stop_gap = 0.0; // merge the rear shelf into the stopper as a single rear corner cradle
pcb_battery_tongue_enable = true;
pcb_battery_tongue_front_clear = 3.5; // overlap under battery front edge
pcb_battery_tongue_top_clear = 0.0; // 0 = touches battery underside
pcb_battery_tongue_bottom_clear = 0.2; // keep clear of load-cell top

internal_feature_embed = 0.15; // overlap floor-anchored features into the shell for a fused STL

usb_clear_x = 0.55;
usb_hole_extra_w = 0.0; // 9 + 2*0.55 = 10.1 mm total USB opening width
usb_hole_h = usb_h + 1.2;
usb_hole_corner_r = 0.8;
usb_lead_in_depth = 1.0; // outer-face chamfer depth for easier plug insertion
usb_lead_in_delta = 0.45; // outer-face profile expansion for the lead-in chamfer
usb_hole_open_top = false; // closed, connector-sized USB opening
usb_hole_z_offset = 0.0; // align opening center to USB-C connector center

screw_post_d = notch_d - notch_pin_clear; // share the load-cell notch axis without touching the metal
screw_thread_d = 2.15; // pilot for M2.5 thread-forming screws in plastic
screw_thread_depth = 9.0; // for M2.5x10 with recessed-head lid and better thread engagement margin
screw_thread_tip_clear = 1.0;

switch_hole_w = switch_actuator_w + switch_travel + 2 * switch_opening_clear;
switch_hole_h = switch_actuator_h + 2 * switch_opening_clear;
switch_recess_w = switch_hole_w + 2.4;
switch_recess_h = switch_hole_h + 1.0;
switch_recess_depth = 1.0;
switch_snap_rail_t = 0.8;
switch_snap_hook_overlap = 0.55;
switch_snap_hook_h = 0.8;
switch_snap_hook_d = switch_d - 0.8;
switch_snap_rear_stop_t = 0.8;
switch_snap_rear_stop_w = 0.8;
switch_snap_rear_stop_h = 1.6;
switch_front_stop_w = 2.0;
switch_front_stop_h = switch_h - 1.0;

brand_text = "Crimpdeq";
brand_font = "Inter:style=Bold";
brand_size = 7.0;
brand_depth = 0.8;
rear_brand_text = "crimpdeq.com";
rear_brand_font = "Inter:style=Bold";
rear_brand_size = 3.0;
rear_brand_depth = 0.8;

// Parameters
show_assembly = true;
show_lid_preview = true;
lid_preview_z_offset = 0; // mm (above main part)
lid_preview_alpha = 0.8; // higher alpha = more opaque
print_layout = false; // true: place bottom on Z=0 for direct STL slicing

/*** Derived placement ***/
inner_x_min = -case_inner_x_half;
inner_x_max = case_inner_x_half;

inner_y_min = case_inner_y_min;
inner_y_max = case_inner_y_max;
usb_front_y = usb_y + usb_d / 2;

// Top of stacked electronics (battery + PCB) used to size enclosure height.
inner_z_max = pcb_top_z + top_clear;

outer_x_min = inner_x_min - wall_t;
outer_x_max = inner_x_max + wall_t;
outer_y_min = inner_y_min - wall_t;
outer_y_max = inner_y_max + wall_t;
outer_z_min = inner_z_min - floor_t;
outer_z_max = inner_z_max;
inner_corner_r = max(0, corner_r - wall_t);
brand_y = (outer_y_min + outer_y_max) / 2;

notch_x1 = -lc_L / 2 + notch_xA;
notch_x2 = -lc_L / 2 + notch_xB;
notch_y1 = -lc_W / 2;
notch_y2 = lc_W / 2;
notch_pin_d = max(0.2, notch_d - notch_pin_clear);
notch_pin_h = 6 + loadcell_lift;
loadcell_protrusion = lc_L / 2 - outer_x_max;

usb_center_z = pcb_center_z - (pcb_T / 2 + usb_h / 2 - usb_inset);
usb_hole_w = usb_w + 2 * usb_clear_x + usb_hole_extra_w;
usb_hole_center_z = usb_center_z + usb_hole_z_offset;
usb_hole_bottom_z = usb_hole_center_z - usb_hole_h / 2;
usb_hole_top_z = usb_hole_center_z + usb_hole_h / 2;
usb_hole_cut_top_z = usb_hole_open_top ? outer_z_max : usb_hole_top_z;

screw_x1 = -lc_L / 2 + notch_xA;
screw_x2 = -lc_L / 2 + notch_xB;
screw_y1 = -lc_W / 2;
screw_y2 = lc_W / 2;
max_thread_depth = max(0, (outer_z_max - outer_z_min) - screw_thread_tip_clear);
thread_depth = min(screw_thread_depth, max_thread_depth);

switch_hole_z = switch_z;
switch_hole_z_min = switch_hole_z - switch_hole_h / 2;
switch_hole_z_max = switch_hole_z + switch_hole_h / 2;
loadcell_y_max = lc_W / 2;
switch_bottom_z = switch_z - switch_h / 2;
switch_top_z = switch_z + switch_h / 2;
switch_actuator_tip_y = switch_y_min - switch_actuator_d;
switch_actuator_proud = outer_y_min - switch_actuator_tip_y;
switch_snap_rail_inner_local_x = switch_w / 2 + switch_fit_clear_x;
// Stop the raised rail section before the battery rear edge. The trimmed
// terminals remain lower than the battery and can extend farther inward.
switch_snap_local_y_min = -switch_d / 2 + switch_terminal_installed_d;
switch_snap_local_y_max = switch_d / 2 + switch_fit_clear_y;
switch_snap_rail_h = switch_h + switch_fit_clear_top + switch_snap_hook_h + internal_feature_embed;
switch_snap_rail_local_z = -switch_h / 2 - internal_feature_embed + switch_snap_rail_h / 2;
switch_rear_stop_local_x = switch_snap_rail_inner_local_x
    - switch_snap_rear_stop_w / 2 + internal_feature_embed / 2;
switch_rear_stop_local_y = -switch_d / 2 - switch_fit_clear_y
    - switch_snap_rear_stop_t / 2 + internal_feature_embed;
switch_front_stop_local_y_min = switch_snap_local_y_max - internal_feature_embed;
switch_wall_local_y = switch_y - inner_y_min;
switch_front_stop_d = switch_wall_local_y - switch_front_stop_local_y_min + internal_feature_embed;
switch_front_stop_local_y = switch_front_stop_local_y_min + switch_front_stop_d / 2;
battery_rear_gap_actual = (battery_y_offset - bat_L / 2) - inner_y_min;
battery_front_gap_actual = inner_y_max - (battery_y_offset + bat_L / 2);
pcb_rear_gap_actual = (pcb_y_offset - pcb_L / 2) - inner_y_min;
pcb_front_gap_actual = inner_y_max - (pcb_y_offset + pcb_L / 2);
connector_wall_gap_actual = inner_y_max - (pcb_y_offset + usb_front_y);
// The 603040 battery is narrower than the PCB. Anchor the drop-in PCB guides
// to the battery guide rails instead of deriving their outer face from the cell.
pcb_guide_riser_outer_x = bat_W / 2 + battery_guide_clear + battery_guide_t;
pcb_guide_riser_w = pcb_guide_riser_outer_x - (pcb_W / 2 + pcb_guide_clear);

assert(switch_terminal_y_max <= -loadcell_y_max,
    str("Trimmed switch terminals overlap the load cell by ",
        switch_terminal_y_max + loadcell_y_max, " mm (Y)."));
assert(switch_x_min >= inner_x_min && switch_x_max <= inner_x_max,
    str("Switch exceeds the compact cavity in X. min=", switch_x_min, " max=", switch_x_max, " mm."));
assert(switch_top_z <= pcb_bottom_z,
    str("Switch overlaps the PCB by ", switch_top_z - pcb_bottom_z, " mm (Z)."));
assert(switch_hole_z_min >= inner_z_min,
    str("Switch opening breaks through the cavity floor by ", inner_z_min - switch_hole_z_min, " mm."));
assert(switch_actuator_proud > 0 && switch_actuator_proud <= 1.0,
    str("Switch actuator must remain accessible but guarded. proud=", switch_actuator_proud, " mm."));
assert(switch_snap_hook_d > 0 && switch_snap_hook_overlap > switch_fit_clear_x,
    "Switch snap hooks must have a positive capture envelope.");
assert(switch_front_stop_d > 0,
    str("Switch front stops do not reach the case wall. depth=", switch_front_stop_d, " mm."));
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
assert(usb_plug_shell_w > 0 && usb_plug_shell_h > 0,
    str("USB plug shell envelope must be positive. w=", usb_plug_shell_w, " h=", usb_plug_shell_h));
assert(usb_plug_shell_corner_r >= 0,
    str("usb_plug_shell_corner_r must be >= 0. Got ", usb_plug_shell_corner_r, " mm."));
assert(screw_post_d > screw_thread_d,
    str("screw_post_d must exceed screw_thread_d. post_d=", screw_post_d, " thread_d=", screw_thread_d));
assert(screw_x1 < screw_x2 && screw_y1 < screw_y2,
    "Load-cell notch screw coordinates must define four distinct centers.");
assert(rear_brand_depth > 0 && rear_brand_depth < wall_t,
    str("rear_brand_depth must be > 0 and < wall_t (", wall_t, " mm)."));
assert(case_inner_x_half >= abs(notch_x2) + notch_pin_d / 2 - notch_pin_clear,
    str("Compact pod does not retain the load-cell notches. inner_half=", case_inner_x_half, " mm."));
assert(case_inner_x_half >= bat_W / 2 + battery_guide_clear + battery_guide_t,
    str("Compact pod is too narrow for the battery guides. inner_half=", case_inner_x_half, " mm."));
assert(loadcell_protrusion > 0,
    str("Load-cell ends must protrude beyond the pod. protrusion=", loadcell_protrusion, " mm."));
assert(loadcell_channel_clear_y > 0 && loadcell_channel_clear_z > 0,
    "Load-cell channel clearances must be positive.");
assert(loadcell_guard_clear >= loadcell_channel_clear_z
    && loadcell_guard_wall_t > 0
    && loadcell_guard_join_x < loadcell_guard_cavity_x_half,
    str("Load-cell end guards need positive wall/clearance and must overlap the pod. clear=",
        loadcell_guard_clear, " wall=", loadcell_guard_wall_t,
        " join_x=", loadcell_guard_join_x, " cavity_x=", loadcell_guard_cavity_x_half));
assert(carabiner_shank_d < carabiner_access_d
    && eye_d < carabiner_access_d
    && carabiner_access_d < eye_tunnel_outer_d,
    str("Eye access must clear both the carabiner and load-cell eye, with an outer tunnel wall. Got shank=",
        carabiner_shank_d, " eye=", eye_d, " access=", carabiner_access_d,
        " tunnel=", eye_tunnel_outer_d, " mm."));
assert(carabiner_side_entry_w > carabiner_access_d
    && carabiner_side_entry_w < 2 * loadcell_guard_cavity_y_half,
    str("Carabiner side entry must exceed the eye access while retaining corner guards. entry=",
        carabiner_side_entry_w, " mm."));
assert(loadcell_eye_center_x - eye_tunnel_outer_d / 2
    >= max(bat_W, pcb_W) / 2 + loadcell_guard_clear,
    str("Wider eye tunnel overlaps the electronics stack by ",
        max(bat_W, pcb_W) / 2 + loadcell_guard_clear
            - (loadcell_eye_center_x - eye_tunnel_outer_d / 2), " mm."));

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

module switch_opening_cut() {
    translate([switch_x, inner_y_min - wall_t / 2, switch_hole_z])
        cube([switch_hole_w, wall_t + 0.3, switch_hole_h], center = true);

    // A shallow outer pocket leaves the short G8 actuator guarded by the
    // surrounding wall while providing enough room for a fingernail.
    translate([
        switch_x,
        outer_y_min + switch_recess_depth / 2 - 0.05,
        switch_hole_z
    ])
        cube([
            switch_recess_w,
            switch_recess_depth + 0.1,
            switch_recess_h
        ], center = true);
}

module switch_local_frame() {
    translate([switch_x, switch_y, switch_z])
        rotate([0, 0, 180])
            children();
}

module switch_snap_hook_local(x_sign) {
    hook_z_min = switch_h / 2 + switch_fit_clear_top;

    hull() {
        translate([
            x_sign * (switch_snap_rail_inner_local_x - switch_snap_hook_overlap / 2),
            0,
            hook_z_min + 0.05
        ])
            cube([
                switch_snap_hook_overlap,
                switch_snap_hook_d,
                0.1
            ], center = true);

        translate([
            x_sign * (switch_snap_rail_inner_local_x + switch_snap_rail_t / 2),
            0,
            hook_z_min + switch_snap_hook_h - 0.15
        ])
            cube([
                switch_snap_rail_t,
                switch_snap_hook_d,
                0.3
            ], center = true);
    }
}

module switch_snap_hooks() {
    switch_local_frame()
        for (x_sign = [-1, 1])
            switch_snap_hook_local(x_sign);
}

module switch_snap_cradle() {
    rail_d = switch_snap_local_y_max - switch_snap_local_y_min;

    switch_local_frame()
        // Flexible side rails capture the floor-mounted switch from above.
        // Insert the actuator into the rear wall slot, then pivot into the hooks.
        for (x_sign = [-1, 1]) {
            translate([
                x_sign * (switch_snap_rail_inner_local_x + switch_snap_rail_t / 2),
                (switch_snap_local_y_min + switch_snap_local_y_max) / 2,
                switch_snap_rail_local_z
            ])
                cube([
                    switch_snap_rail_t,
                    rail_d,
                    switch_snap_rail_h
                ], center = true);

            switch_snap_hook_local(x_sign);

            // Rear corner stops avoid the three trimmed PCB terminals.
            translate([
                x_sign * switch_rear_stop_local_x,
                switch_rear_stop_local_y,
                -switch_h / 2 + switch_snap_rear_stop_h / 2 - internal_feature_embed
            ])
                cube([
                    switch_snap_rear_stop_w,
                    switch_snap_rear_stop_t,
                    switch_snap_rear_stop_h + internal_feature_embed
                ], center = true);

            // Front pads set actuator projection and fuse into the rear wall.
            translate([
                x_sign * (
                    switch_snap_rail_inner_local_x
                    - switch_front_stop_w / 2
                    + internal_feature_embed / 2
                ),
                switch_front_stop_local_y,
                0
            ])
                cube([
                    switch_front_stop_w,
                    switch_front_stop_d,
                    switch_front_stop_h
                ], center = true);
        }
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
        support_x = loadcell_retain_half_x - loadcell_support_corner_inset - support_xy / 2;
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
                        cube([span_x, span_y, support_h], center = true);
    }
}

module battery_support_bed() {
    if (loadcell_to_battery_gap > 0) {
        support_w = battery_support_corner_size;
        support_inner_x = max(
            bat_W / 2 - battery_support_corner_inset - support_w,
            switch_w / 2 + switch_fit_clear_x
        );
        support_outer_x = bat_W / 2 + battery_guide_clear + battery_guide_t;
        support_span_x = support_outer_x - support_inner_x;
        support_x = (support_inner_x + support_outer_x) / 2;
        loadcell_path_y = lc_W / 2 + loadcell_channel_clear_y;
        battery_front_y = battery_y_offset + bat_L / 2;
        battery_rear_y = battery_y_offset - bat_L / 2;
        support_front_outer_y = min(
            inner_y_max,
            battery_front_y + battery_guide_clear + battery_guide_t
        );
        support_rear_outer_y = max(
            inner_y_min,
            battery_rear_y - battery_guide_clear - battery_guide_t
        );
        support_bottom_z = inner_z_min - internal_feature_embed;
        support_h = battery_bottom_z - support_bottom_z;
        support_z = support_bottom_z + support_h / 2;
        guide_h = min(battery_guide_h, bat_T);
        guide_top_z = battery_bottom_z + guide_h;
        guide_h_fused = guide_top_z - (inner_z_min - internal_feature_embed);
        guide_z = inner_z_min - internal_feature_embed + guide_h_fused / 2;

        // Four short edge ledges support and locate the battery while keeping
        // the entire load-cell channel clear for straight-down insertion.
        for (x_sign = [-1, 1])
            for (y_sign = [-1, 1])
                let(
                    support_inner_y = y_sign * loadcell_path_y,
                    support_outer_y = y_sign < 0 ? support_rear_outer_y : support_front_outer_y,
                    support_d = abs(support_outer_y - support_inner_y),
                    support_y = (support_inner_y + support_outer_y) / 2
                ) {
                assert(support_d > 0,
                    str("Battery support ledge collapsed at y_sign=", y_sign,
                        ". depth=", support_d, " mm."));

                translate([x_sign * support_x, support_y, support_z])
                    cube([support_span_x, support_d, support_h], center = true);

                translate([
                    x_sign * (bat_W / 2 + battery_guide_clear + battery_guide_t / 2),
                    support_y,
                    guide_z
                ])
                    cube([battery_guide_t, support_d, guide_h_fused], center = true);

                translate([
                    x_sign * (bat_W / 2 - battery_support_corner_inset - battery_end_guide_w / 2),
                    battery_y_offset + y_sign * (
                        bat_L / 2 + battery_end_guide_clear + battery_end_guide_t / 2
                    ),
                    guide_z
                ])
                    cube([
                        battery_end_guide_w,
                        battery_end_guide_t,
                        guide_h_fused
                    ], center = true);
            }
    }
}

module pcb_horizontal_guides() {
    guide_h = min(pcb_guide_h, pcb_T);
    guide_top_z = pcb_bottom_z + guide_h;
    bat_col_x = bat_W / 2 - battery_support_corner_inset - battery_support_corner_size / 2;
    loadcell_path_y = loadcell_y_max + loadcell_channel_clear_y;
    front_column_y_min = max(
        loadcell_path_y,
        battery_y_offset + bat_L / 2 + battery_guide_clear
    );
    front_column_d = inner_y_max - front_column_y_min;
    front_anchor_y = front_column_y_min + front_column_d / 2;
    // Compact front columns occupy the space beyond both the battery and
    // load-cell path, preserving straight-down insertion for both parts.
    riser_z0 = inner_z_min - internal_feature_embed;
    riser_h = max(0, guide_top_z - riser_z0);
    riser_z = riser_z0 + riser_h / 2;
    pcb_support_h = max(0, pcb_bottom_z - riser_z0);
    pcb_support_z = riser_z0 + pcb_support_h / 2;
    col_inner_x = bat_col_x - battery_support_corner_size / 2;
    col_outer_x = pcb_guide_riser_outer_x;
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
    support_back_y = front_column_y_min;
    tongue_front_y = battery_front_y - pcb_battery_tongue_front_clear;
    tongue_l = max(0, support_back_y - tongue_front_y);
    tongue_y = (support_back_y + tongue_front_y) / 2;
    tongue_top_z = battery_bottom_z - pcb_battery_tongue_top_clear;
    tongue_bottom_z = loadcell_top_z + pcb_battery_tongue_bottom_clear;
    tongue_h = max(0, tongue_top_z - tongue_bottom_z);
    tongue_z = tongue_bottom_z + tongue_h / 2;

    assert(front_column_d > 0,
        str("Front PCB support ledge collapsed. depth=", front_column_d, " mm."));

    for (x_sign = [-1, 1]) {
        if (pcb_support_h > 0 && pcb_support_w > 0.01)
            // Extend the inner strip up to the PCB underside to support the front overhang.
            translate([x_sign * pcb_support_x, front_anchor_y, pcb_support_z])
                cube([pcb_support_w, front_column_d, pcb_support_h], center = true);

        if (riser_h > 0 && riser_w > 0.01) {
            // Use only the outer strip above the PCB to avoid PCB collision, and add
            // a small top lead-in so the PCB edges self-center instead of catching.
            if (riser_body_h > 0.01)
                translate([x_sign * riser_x, front_anchor_y, riser_z0 + riser_body_h / 2])
                    cube([riser_w, front_column_d, riser_body_h], center = true);

            if (riser_lead_in_h > 0.01)
                hull() {
                    translate([x_sign * riser_x, front_anchor_y, riser_z0 + riser_body_h + 0.01])
                        cube([riser_w, front_column_d, 0.02], center = true);
                    translate([x_sign * riser_top_x, front_anchor_y, guide_top_z - 0.01])
                        cube([riser_top_w, front_column_d, 0.02], center = true);
                }
        }

        if (pcb_battery_tongue_enable && tongue_h > 0.01 && tongue_l > 0.01 && pcb_support_w > 0.01)
            // Small tongue from PCB vertical supports to prop the battery front underside.
            translate([x_sign * pcb_support_x, tongue_y, tongue_z])
                cube([pcb_support_w, tongue_l, tongue_h], center = true);
    }
}

module pcb_rear_corner_cradles() {
    pcb_rear_y = pcb_y_offset - pcb_L / 2;
    stop_top_z = pcb_bottom_z + min(pcb_guide_h, pcb_T);
    stop_bottom_z_pcb = pcb_bottom_z + max(0, min(pcb_rear_stop_bottom_gap, pcb_T - 0.2));
    stop_bottom_z_battery = battery_bottom_z + bat_T + pcb_rear_stop_battery_clear;
    stop_bottom_z = min(stop_bottom_z_pcb, stop_bottom_z_battery, stop_top_z - 0.2);
    stop_h = max(0.2, stop_top_z - stop_bottom_z);
    stop_depth = max(0, pcb_rear_stop_depth);
    stop_x = pcb_W / 2 - pcb_rear_stop_w / 2;
    stop_lead_in_h = min(stop_h, pcb_guide_lead_in_h);
    stop_body_h = max(0, stop_h - stop_lead_in_h);
    stop_top_inset = min(max(0, pcb_rear_stop_lead_in), max(0, stop_depth - 0.2));
    stop_top_depth = max(0.2, stop_depth - stop_top_inset);
    stop_y = pcb_rear_y - stop_depth / 2;
    stop_top_y = pcb_rear_y - stop_depth + stop_top_depth / 2;

    // The shorter revision-3 PCB no longer reaches the rear enclosure wall.
    // Support each rear corner from a floor-anchored column outside the battery.
    rest_depth = max(0, pcb_rear_rest_depth);
    rest_top_z = pcb_bottom_z;
    rest_bottom_z = stop_bottom_z_battery;
    rest_h = max(0, rest_top_z - rest_bottom_z);
    rest_z = rest_bottom_z + rest_h / 2;
    rest_inner_x = pcb_W / 2 - pcb_rear_stop_w - pcb_rear_rest_stop_gap - pcb_rear_rest_w;
    // Stop inside the battery edge so the forward-shifted PCB shelves remain
    // clear of the load-cell eye tunnel walls.
    rest_outer_x = bat_W / 2;
    rest_w = rest_outer_x - rest_inner_x;
    rest_x = (rest_inner_x + rest_outer_x) / 2;
    rest_y = pcb_rear_y + rest_depth / 2;
    front_support_back_y = max(
        loadcell_y_max + loadcell_channel_clear_y,
        battery_y_offset + bat_L / 2 + battery_guide_clear
    );
    rest_front_y = pcb_rear_y + rest_depth;
    bridge_overlap = 0.2;
    bridge_y_min = rest_front_y - bridge_overlap;
    bridge_y_max = front_support_back_y + bridge_overlap;
    bridge_l = max(0, bridge_y_max - bridge_y_min);
    bridge_y = (bridge_y_min + bridge_y_max) / 2;
    bridge_x = stop_x;
    bridge_w = pcb_rear_rest_w;

    if (stop_depth > 0.01) {
        for (x_sign = [-1, 1]) {
            if (stop_body_h > 0.01)
                translate([x_sign * stop_x, stop_y, stop_bottom_z + stop_body_h / 2])
                    cube([pcb_rear_stop_w, stop_depth, stop_body_h], center = true);

            if (stop_lead_in_h > 0.01)
                hull() {
                    translate([x_sign * stop_x, stop_y, stop_bottom_z + stop_body_h + 0.01])
                        cube([pcb_rear_stop_w, stop_depth, 0.02], center = true);
                    translate([x_sign * stop_x, stop_top_y, stop_top_z - 0.01])
                        cube([pcb_rear_stop_w, stop_top_depth, 0.02], center = true);
                }

            if (rest_depth > 0.01 && rest_h > 0.01 && rest_w > 0.01)
                translate([x_sign * rest_x, rest_y, rest_z])
                    cube([rest_w, rest_depth, rest_h], center = true);

            // Tie the rear cradle into the floor-anchored front PCB support.
            // This bridge stays in the PCB/battery clearance gap.
            if (bridge_l > 0.01 && rest_h > 0.01)
                translate([x_sign * bridge_x, bridge_y, rest_z])
                    cube([bridge_w, bridge_l, rest_h], center = true);
        }
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

module loadcell_side_channels() {
    channel_y = lc_W + 2 * loadcell_channel_clear_y;
    channel_z_min = loadcell_bottom_z - loadcell_channel_clear_z;
    channel_z_max = outer_z_max + 0.2;
    channel_h = channel_z_max - channel_z_min;
    channel_x = wall_t + 0.4;

    for (x_sign = [-1, 1])
        translate([
            x_sign * (case_inner_x_half + wall_t / 2),
            0,
            channel_z_min + channel_h / 2
        ])
            cube([channel_x, channel_y, channel_h], center = true);
}

module main_loadcell_end_guards() {
    base_h = loadcell_guard_lower_top_z - outer_z_min;
    wall_z_min = loadcell_guard_lower_top_z;
    wall_h = outer_z_max - wall_z_min;
    cavity_x_half = loadcell_guard_cavity_x_half + 0.1;
    cavity_y = 2 * loadcell_guard_cavity_y_half + 0.2;
    electronics_x_half = max(
        bat_W / 2 + battery_guide_clear,
        pcb_W / 2 + pcb_guide_clear
    );
    electronics_y_min = min(
        battery_y_offset - bat_L / 2 - battery_guide_clear,
        pcb_y_offset - pcb_L / 2 - pcb_guide_clear
    );
    electronics_y_max = max(
        battery_y_offset + bat_L / 2 + battery_guide_clear,
        pcb_y_offset + pcb_L / 2 + pcb_guide_clear
    );
    electronics_y = electronics_y_max - electronics_y_min;

    for (x_sign = [-1, 1]) {
        // The solid lower plate supports the load-cell end from below.
        if (base_h > 0)
            translate([0, 0, outer_z_min])
                linear_extrude(height = base_h, center = false)
                    loadcell_end_guard_2d(
                        x_sign,
                        outer_x_max - corner_r,
                        outer_y_min + corner_r,
                        outer_y_max - corner_r,
                        corner_r
                    );

        // Main-owned vertical walls rise to the lid seam. Their open-top
        // rectangular cavity clears the complete load-cell envelope so the
        // cell still drops straight in before the lid is fitted.
        if (wall_h > 0)
            difference() {
                translate([0, 0, wall_z_min])
                    linear_extrude(height = wall_h, center = false)
                        loadcell_end_guard_2d(
                            x_sign,
                            outer_x_max - corner_r,
                            outer_y_min + corner_r,
                            outer_y_max - corner_r,
                            corner_r
                        );

                translate([
                    x_sign * cavity_x_half / 2,
                    0,
                    wall_z_min + wall_h / 2
                ])
                    cube([
                        cavity_x_half,
                        cavity_y,
                        wall_h + 0.2
                    ], center = true);

                // The smooth screw-corner blend reaches farther inboard than
                // the load-cell wall. Clear the full battery/PCB drop-in
                // envelope there so the taller main wall adds no overhang.
                translate([
                    x_sign * electronics_x_half / 2,
                    (electronics_y_min + electronics_y_max) / 2,
                    wall_z_min + wall_h / 2
                ])
                    cube([
                        electronics_x_half,
                        electronics_y,
                        wall_h + 0.2
                    ], center = true);
            }
    }
}

module main_loadcell_eye_tunnel_walls() {
    tunnel_z_min = outer_z_min;
    tunnel_z_max = loadcell_bottom_z - loadcell_channel_clear_z;
    tunnel_h = tunnel_z_max - tunnel_z_min;
    tunnel_z = (tunnel_z_min + tunnel_z_max) / 2;

    if (tunnel_h > 0)
        for (eye_x = [
            -lc_L / 2 + eye_center_offset,
            lc_L / 2 - eye_center_offset
        ])
            intersection() {
                difference() {
                    translate([eye_x, 0, tunnel_z])
                        cylinder(d = eye_tunnel_outer_d, h = tunnel_h, center = true);
                    translate([eye_x, 0, tunnel_z])
                        cylinder(d = carabiner_access_d, h = tunnel_h + 0.2, center = true);
                }
                translate([
                    (outer_x_min + outer_x_max) / 2,
                    (outer_y_min + outer_y_max) / 2,
                    tunnel_z
                ])
                    cube([
                        outer_x_max - outer_x_min,
                        outer_y_max - outer_y_min,
                        tunnel_h + 0.2
                    ], center = true);
            }
}

module main_loadcell_eye_access_paths() {
    access_h = outer_z_max - outer_z_min + 0.4;

    for (x_sign = [-1, 1])
        translate([0, 0, outer_z_min - 0.2])
            linear_extrude(height = access_h, center = false)
                loadcell_eye_access_2d(x_sign);
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

    // Carved above the recessed switch opening on the outer rear wall (-Y).
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
            battery_support_bed();
            pcb_horizontal_guides();
            pcb_rear_corner_cradles();
            notch_pins();
            loadcell_notch_guides();
            switch_snap_cradle();
            // Main-owned end walls shield all four load-cell corners up to the
            // lid seam while preserving open-top component insertion.
            main_loadcell_end_guards();
            // The lower half of each carabiner tunnel closes the electronics
            // cavity below the load-cell eye without touching the metal eye.
            main_loadcell_eye_tunnel_walls();

            // Internal cylindrical bosses for screw engagement.
            corner_screw_posts(screw_post_d, outer_z_min, outer_z_max);
        }

        corner_thread_holes(screw_thread_d, outer_z_max, thread_depth);

        // Open-top channels allow top-down assembly. Matching skirts on the lid
        // close these channels above the load cell in the assembled enclosure.
        loadcell_side_channels();
        // Open each full-size eye toward its load-cell end so a carabiner can
        // clip in laterally instead of threading through a deep vertical bore.
        main_loadcell_eye_access_paths();

        // Recessed actuator slot for the compact slide switch.
        switch_opening_cut();

        // Connector-sized USB opening with rounded corners and an outer lead-in chamfer.
        usb_opening_cut();

        // Brand engraving on outer bottom face.
        brand_engrave_main();
        // Rear wall engraving above the switch opening.
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
