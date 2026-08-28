//
// Lid enclosure part
// - corner screw holes aligned with case_main.scad
// - central load-cell hold-down features
//

include <placement.scad>
use <case_common.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
loadcell_hold_down_clear = 0.6;
loadcell_hold_down_d = 8;
loadcell_hold_down_wall_clear = 0.4;
loadcell_hold_down_y_offset = 10;
loadcell_channel_closure_fit = 0.2;
eye_tunnel_inboard_fit = 0.2;

screw_clear_d = 3.0; // slightly looser clearance so the lid seats more easily on the posts
screw_hole_lead_in_d = 3.8; // underside funnel for easier post entry during assembly
screw_hole_lead_in_depth = 1.0;
screw_head_d = 5.2; // typical M2.5 button/pan head clearance
screw_head_recess = 1.8; // recess depth so heads do not protrude
screw_fit_shank_d = 2.6; // fit-check envelope for an M2.5 screw shank through the lid
screw_fit_head_d = 5.0; // fit-check envelope for a typical M2.5 pan/button head
screw_fit_head_h = 1.6;

// Minimal lid-mounted PCB cradle: three roof pads, one fixed side hook, one
// accessible flexible rear clip, and short X/rear axial datums.
pcb_cradle_fixed_y = 4.5;
pcb_cradle_opposite_y = 11.0;
pcb_cradle_opposite_w = 3.0;

status_led_view_d = 2.6;
rgb_led_view_d = 5.8;
led_view_chamfer_depth = 0.8;
led_view_chamfer_delta = 0.6;

brand_x = 0;
print_layout = false; // true: flip lid for support-free printing (outer top face on bed)

/*** Derived placement ***/
hold_down_target_z = loadcell_top_z + loadcell_hold_down_clear;
hold_down_h = lid_z_min - hold_down_target_z;
hold_down_inner_x = bat_W / 2 + fdm_soft_clear;
hold_down_outer_x = inner_x_max - loadcell_hold_down_wall_clear;
hold_down_w = hold_down_outer_x - hold_down_inner_x;
hold_down_x = (hold_down_inner_x + hold_down_outer_x) / 2;

head_recess_depth = max(0, min(screw_head_recess, case_lid_t - 0.6));
status_led_view_x = status_led_x;
status_led_view_y = pcb_y_offset + status_led_y;
rgb_led_view_x = rgb_led_x;
rgb_led_view_y = pcb_y_offset + rgb_led_y;

pcb_cradle_pad_bottom_z = pcb_top_z + pcb_cradle_top_clear;
pcb_cradle_pad_h = lid_z_min - pcb_cradle_pad_bottom_z + internal_feature_embed;
pcb_cradle_fixed_x = pcb_W / 2 + pcb_cradle_xy_clear + pcb_cradle_rail_t / 2;
pcb_cradle_rear_y = pcb_y_offset - pcb_L / 2
    - pcb_cradle_xy_clear - pcb_cradle_rail_t / 2;
pcb_cradle_hook_top_z = pcb_bottom_z - pcb_cradle_top_clear;
pcb_cradle_hook_bottom_z = pcb_cradle_hook_top_z - pcb_cradle_hook_h;
pcb_cradle_rail_h = lid_z_min - pcb_cradle_hook_bottom_z + internal_feature_embed;
pcb_cradle_rail_z = pcb_cradle_hook_bottom_z + pcb_cradle_rail_h / 2;

assert(loadcell_hold_down_d > 0,
    "loadcell_hold_down_d must be > 0.");
assert(loadcell_hold_down_y_offset + loadcell_hold_down_d / 2 <= lc_W / 2,
    "Load-cell anti-lift stops must stay over the cell body.");
assert(loadcell_hold_down_wall_clear >= 0,
    str("loadcell_hold_down_wall_clear must be >= 0. Got ", loadcell_hold_down_wall_clear, " mm."));
assert(loadcell_channel_closure_fit >= 0
    && 2 * loadcell_channel_closure_fit < case_wall_t,
    str("loadcell_channel_closure_fit must leave a positive closure wall. fit=",
        loadcell_channel_closure_fit, " wall_t=", case_wall_t, " mm."));
assert(loadcell_guard_clear >= loadcell_channel_clear_z
    && loadcell_guard_wall_t > 0
    && loadcell_guard_join_x < loadcell_guard_cavity_x_half,
    str("Load-cell end guards need positive wall/clearance and must overlap the lid. clear=",
        loadcell_guard_clear, " wall=", loadcell_guard_wall_t,
        " join_x=", loadcell_guard_join_x, " cavity_x=", loadcell_guard_cavity_x_half));
assert(eye_d < carabiner_access_d
    && carabiner_access_d < eye_tunnel_outer_d,
    str("Eye opening/tunnel diameters must satisfy eye < access < tunnel. Got ",
        eye_d, ", ", carabiner_access_d, ", ", eye_tunnel_outer_d, " mm."));
assert(eye_tunnel_inboard_fit >= 0
    && eye_tunnel_inboard_fit < eye_tunnel_wall_t,
    str("eye_tunnel_inboard_fit must be within the tunnel wall thickness. fit=",
        eye_tunnel_inboard_fit, " wall=", eye_tunnel_wall_t, " mm."));
assert(carabiner_side_entry_w > carabiner_access_d
    && carabiner_side_entry_w < 2 * loadcell_guard_cavity_y_half,
    str("Carabiner side entry must exceed the eye access while retaining corner guards. entry=",
        carabiner_side_entry_w, " mm."));
assert(screw_hole_lead_in_d >= screw_clear_d,
    str("screw_hole_lead_in_d must be >= screw_clear_d. lead_in_d=", screw_hole_lead_in_d,
        " clear_d=", screw_clear_d));
assert(screw_hole_lead_in_depth >= 0 && screw_hole_lead_in_depth <= case_lid_t,
    str("screw_hole_lead_in_depth must be within [0, lid_t]. depth=", screw_hole_lead_in_depth,
        " lid_t=", case_lid_t));
assert(screw_fit_shank_d > 0 && screw_fit_shank_d < screw_clear_d,
    str("screw_fit_shank_d must be > 0 and < screw_clear_d. fit=", screw_fit_shank_d,
        " clear=", screw_clear_d));
assert(screw_fit_head_d > 0 && screw_fit_head_d < screw_head_d,
    str("screw_fit_head_d must be > 0 and < screw_head_d. fit=", screw_fit_head_d,
        " recess=", screw_head_d));
assert(screw_fit_head_h > 0 && screw_fit_head_h < head_recess_depth,
    str("screw_fit_head_h must be > 0 and < head_recess_depth. fit=", screw_fit_head_h,
        " recess=", head_recess_depth));
assert(hold_down_w > 0,
    str("Load-cell hold-down width collapsed. inner_x=", hold_down_inner_x, " outer_x=", hold_down_outer_x, "."));
assert(hold_down_x + hold_down_w / 2 <= inner_x_max + 0.001,
    str("Load-cell hold-downs overlap main side wall by ",
        hold_down_x + hold_down_w / 2 - inner_x_max, " mm (X)."));
assert(hold_down_x - hold_down_w / 2 >= bat_W / 2 - 0.001,
    str("Load-cell hold-downs overlap battery by ",
        bat_W / 2 - (hold_down_x - hold_down_w / 2), " mm (X)."));
assert(pcb_cradle_pad_h > 0 && pcb_cradle_rail_h > 0,
    "PCB cradle must reach the PCB from the lid roof.");
assert(pcb_cradle_hook_overlap > pcb_cradle_xy_clear,
    "PCB cradle hook must overlap beyond the XY fit clearance.");
assert(pcb_cradle_fixed_x + pcb_cradle_rail_t / 2 <= inner_x_max + 0.001,
    "PCB fixed rail exceeds the lid cavity.");
assert(pcb_cradle_rear_y - pcb_cradle_rail_t / 2 >= inner_y_min - 0.001,
    "PCB rear clip exceeds the lid cavity.");
assert(status_led_view_d > 0 && rgb_led_view_d > 0,
    str("LED view diameters must be > 0. status=", status_led_view_d,
        " rgb=", rgb_led_view_d, " mm."));
assert(led_view_chamfer_depth >= 0 && led_view_chamfer_depth <= case_lid_t,
    str("led_view_chamfer_depth must be within [0, lid_t]. depth=", led_view_chamfer_depth,
        " lid_t=", case_lid_t));
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

module each_corner(z_pos) {
    each_case_corner(screw_x1, screw_x2, screw_y1, screw_y2, z_pos)
        children();
}

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
    corner_holes(screw_fit_shank_d, lid_z_min - 0.2, lid_z_max + 0.2);
}

module lid_screw_head_fit_probe() {
    head_z = lid_z_max - screw_fit_head_h / 2;
    each_corner(head_z)
        cylinder(d = screw_fit_head_d, h = screw_fit_head_h, center = true);
}

module led_view_hole(x, y, d) {
    translate([x, y, lid_z_min - 0.1])
        cylinder(d = d, h = case_lid_t + 0.3, center = false);

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

module lid_loadcell_eye_access_paths() {
    // Cut through the upper eye-tunnel isolation and the roof cap.
    access_z_min = loadcell_guard_lower_top_z - 0.2;
    access_z_max = lid_z_max + 0.2;
    access_h = access_z_max - access_z_min;

    for (x_sign = [-1, 1])
        translate([0, 0, access_z_min])
            linear_extrude(height = access_h, center = false)
                loadcell_eye_access_2d(x_sign);
}

module loadcell_channel_closures() {
    closure_z_min = loadcell_top_z + loadcell_channel_clear_z;
    closure_z_max = lid_z_min + internal_feature_embed;
    closure_h = closure_z_max - closure_z_min;
    closure_z = (closure_z_min + closure_z_max) / 2;
    closure_x_t = case_wall_t - 2 * loadcell_channel_closure_fit;
    closure_y = lc_W + 2 * loadcell_channel_clear_y
        - 2 * loadcell_channel_closure_fit;

    if (closure_h > 0 && closure_x_t > 0 && closure_y > 0)
        for (x_sign = [-1, 1])
            translate([
                x_sign * (case_inner_x_half + case_wall_t / 2),
                0,
                closure_z
            ])
                cube([closure_x_t, closure_y, closure_h], center = true);
}

module lid_loadcell_end_guards() {
    roof_guard_h = lid_z_max - lid_z_min;

    for (x_sign = [-1, 1])
        // The main body now owns the vertical corner walls. The lid contributes
        // only a smooth roof cap that seats on those walls at the seam.
        translate([0, 0, lid_z_min])
            linear_extrude(height = roof_guard_h, center = false)
                loadcell_end_guard_2d(
                    x_sign,
                    outer_x_max - case_corner_r,
                    outer_y_min + case_corner_r,
                    outer_y_max - case_corner_r,
                    case_corner_r
                );
}

module lid_loadcell_eye_tunnel_walls() {
    tunnel_z_min = loadcell_top_z + loadcell_channel_clear_z;
    tunnel_z_max = lid_z_max;
    tunnel_h = tunnel_z_max - tunnel_z_min;
    wall_x_inner = loadcell_eye_center_x
        - eye_tunnel_outer_d / 2
        + eye_tunnel_inboard_fit;
    wall_x_span = lc_L / 2 - wall_x_inner;

    if (tunnel_h > 0)
        for (x_sign = [-1, 1])
            translate([0, 0, tunnel_z_min])
                linear_extrude(height = tunnel_h, center = false)
                    intersection() {
                        // Continue the upper isolation wall along both sides
                        // of the flared carabiner path to the load-cell tip.
                        difference() {
                            offset(delta = eye_tunnel_wall_t)
                                loadcell_eye_access_2d(x_sign);
                            loadcell_eye_access_2d(x_sign);
                        }

                        // End the vertical wall at the physical 80 mm cell
                        // envelope; the roof cap continues over the end guard.
                        translate([
                            x_sign < 0 ? -lc_L / 2 : wall_x_inner,
                            -loadcell_guard_y_half
                        ])
                            square([
                                wall_x_span,
                                2 * loadcell_guard_y_half
                            ], center = false);
                    }
}

module loadcell_hold_downs() {
    hold_down_h_eff = hold_down_h + internal_feature_embed;
    hold_down_z = hold_down_target_z + hold_down_h_eff / 2;

    for (x_sign = [-1, 1])
        // Two diagonal, clearance-based anti-lift stops resist twist without
        // clamping the cell or blocking the case-local -X wire service race.
        translate([
            x_sign * hold_down_x,
            x_sign * loadcell_hold_down_y_offset,
            hold_down_z
        ])
            cube([hold_down_w, loadcell_hold_down_d, hold_down_h_eff], center = true);
}

module pcb_cradle_roof_pads() {
    pad_z = pcb_cradle_pad_bottom_z + pcb_cradle_pad_h / 2;

    for (pad = [
        [-10, pcb_y_offset + 9],
        [10, pcb_y_offset + 9],
        [0, pcb_y_offset - 8]
    ])
        translate([pad[0], pad[1], pad_z])
            cylinder(d = pcb_cradle_pad_d, h = pcb_cradle_pad_h, center = true);
}

module pcb_cradle_x_hook() {
    hook_x_outer = pcb_cradle_fixed_x + pcb_cradle_rail_t / 2;
    hook_x_inner = pcb_W / 2 - pcb_cradle_hook_overlap;

    // The 45-degree underside grows inward as the flipped lid prints upward.
    hull() {
        translate([
            hook_x_outer - pcb_cradle_rail_t / 2,
            pcb_y_offset + pcb_cradle_fixed_y,
            pcb_cradle_hook_top_z - 0.05
        ])
            cube([pcb_cradle_rail_t, pcb_cradle_feature_w, 0.1], center = true);
        translate([
            (hook_x_outer + hook_x_inner) / 2,
            pcb_y_offset + pcb_cradle_fixed_y,
            pcb_cradle_hook_bottom_z + 0.05
        ])
            cube([
                hook_x_outer - hook_x_inner,
                pcb_cradle_feature_w,
                0.1
            ], center = true);
    }
}

module pcb_cradle_fixed_side() {
    translate([
        pcb_cradle_fixed_x,
        pcb_y_offset + pcb_cradle_fixed_y,
        pcb_cradle_rail_z
    ])
        cube([
            pcb_cradle_rail_t,
            pcb_cradle_feature_w,
            pcb_cradle_rail_h
        ], center = true);

    pcb_cradle_x_hook();
}

module pcb_cradle_rear_clip() {
    clip_y = pcb_cradle_rear_y;
    hook_y_outer = clip_y - pcb_cradle_rail_t / 2;
    hook_y_inner = pcb_y_offset - pcb_L / 2 + pcb_cradle_hook_overlap;

    translate([pcb_axial_right_x, clip_y, pcb_cradle_rail_z])
        cube([
            pcb_cradle_feature_w,
            pcb_cradle_rail_t,
            pcb_cradle_rail_h
        ], center = true);

    hull() {
        translate([
            pcb_axial_right_x,
            hook_y_outer + pcb_cradle_rail_t / 2,
            pcb_cradle_hook_top_z - 0.05
        ])
            cube([pcb_cradle_feature_w, pcb_cradle_rail_t, 0.1], center = true);
        translate([
            pcb_axial_right_x,
            (hook_y_outer + hook_y_inner) / 2,
            pcb_cradle_hook_bottom_z + 0.05
        ])
            cube([
                pcb_cradle_feature_w,
                hook_y_inner - hook_y_outer,
                0.1
            ], center = true);
    }
}

module pcb_cradle_rear_axial_datum() {
    // A second rear reaction point brackets the USB connector with the snap
    // clip, preventing insertion force from twisting the PCB in the cradle.
    translate([
        pcb_axial_left_x,
        pcb_cradle_rear_y,
        pcb_cradle_rail_z
    ])
        cube([
            pcb_axial_stop_w,
            pcb_cradle_rail_t,
            pcb_cradle_rail_h
        ], center = true);
}

module pcb_cradle_rear_reaction_stops() {
    pcb_cradle_rear_clip();
    pcb_cradle_rear_axial_datum();
}

module pcb_cradle_opposite_datum() {
    datum_h = lid_z_min - pcb_bottom_z + internal_feature_embed;
    datum_z = pcb_bottom_z + datum_h / 2;

    // Short datum sits beyond the solder/wire corridor near the PCB front
    // corner, preventing the board from sliding out of the fixed +X hook.
    translate([
        -pcb_cradle_fixed_x,
        pcb_y_offset + pcb_cradle_opposite_y,
        datum_z
    ])
        cube([
            pcb_cradle_rail_t,
            pcb_cradle_opposite_w,
            datum_h
        ], center = true);
}

module pcb_lid_cradle() {
    pcb_cradle_roof_pads();
    pcb_cradle_fixed_side();
    pcb_cradle_rear_reaction_stops();
    pcb_cradle_opposite_datum();
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
            rounded_block_xy(
                [outer_x_min, outer_y_min, lid_z_min],
                [outer_x_max, outer_y_max, lid_z_max],
                case_corner_r
            );
            pcb_lid_cradle();
            // Close the main body's top-loading side channels around the
            // load cell, leaving only a tolerance-sized horizontal slot.
            loadcell_channel_closures();
            // Smooth roof caps close the main-owned load-cell corner walls.
            lid_loadcell_end_guards();
            // Isolate the inboard side of both carabiner paths from the bay.
            lid_loadcell_eye_tunnel_walls();
            if (hold_down_h > 0) {
                loadcell_hold_downs();
            }
        }
        corner_holes(screw_clear_d, lid_z_min, lid_z_max);
        corner_hole_lead_ins(screw_hole_lead_in_d, screw_clear_d, screw_hole_lead_in_depth);
        corner_head_recesses(screw_head_d, head_recess_depth);
        led_view_holes();
        lid_loadcell_eye_access_paths();
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
