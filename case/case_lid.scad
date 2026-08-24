//
// Lid enclosure part
// - corner screw holes aligned with case_main.scad
// - central load-cell hold-down features
//

include <placement.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

/*** Enclosure parameters ***/
wall_t = 2.4;
lid_t = 2.4;
corner_r = 6;

loadcell_hold_down_clear = 0.6;
loadcell_hold_down_d = 8;
loadcell_hold_down_wall_clear = 0.4;
loadcell_hold_down_y_offset = 8;
loadcell_channel_closure_fit = 0.2;

screw_clear_d = 3.0; // slightly looser clearance so the lid seats more easily on the posts
screw_hole_lead_in_d = 3.8; // underside funnel for easier post entry during assembly
screw_hole_lead_in_depth = 1.0;
screw_head_d = 5.2; // typical M2.5 button/pan head clearance
screw_head_recess = 1.8; // recess depth so heads do not protrude
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

// Battery anti-slip tabs on lid underside (engage battery front corners when assembled).
// Placed outside PCB width so they can extend down without colliding with the PCB.
battery_front_stop_enable = true;
battery_front_stop_t = 1.2;
battery_front_stop_w = 1.0;
battery_front_stop_x_inset = 0.3;
battery_front_stop_y_clear = 0.3;
battery_front_stop_z_overlap = bat_T / 2; // reach about mid battery thickness

// Battery side walls (lid underside), running parallel to battery length.
battery_side_wall_enable = true;
battery_side_wall_t = 1.2;
battery_side_wall_clear = 0.7;

// PCB top clamps near the USB side. They keep the PCB seated in its cradle while
// leaving the connector, center routing area, and right-side battery/switch wire pads clear.
pcb_top_clamp_enable = true;
pcb_top_clamp_clear = 0.10;
pcb_top_clamp_w = 3.2;
pcb_top_clamp_d = 4.0;
pcb_top_clamp_x_inset = 1.2;
pcb_top_clamp_front_setback = 4.0;
pcb_top_clamp_rear_setback = 10.0;

internal_feature_embed = 0.15; // overlap underside features into the roof for a fused STL

status_led_view_d = 2.6;
rgb_led_view_d = 5.8;
led_view_chamfer_depth = 0.8;
led_view_chamfer_delta = 0.6;

brand_text = "Crimpdeq";
brand_font = "Inter:style=Bold";
brand_size = 9.5;
brand_depth = 0.8;
brand_x = 0;
print_layout = false; // true: flip lid for support-free printing (outer top face on bed)

/*** Derived placement ***/
inner_x_min = -case_inner_x_half;
inner_x_max = case_inner_x_half;

inner_y_min = case_inner_y_min;
inner_y_max = case_inner_y_max;
usb_front_y = usb_y + usb_d / 2;

inner_z_max = pcb_top_z + top_clear;

outer_x_min = inner_x_min - wall_t;
outer_x_max = inner_x_max + wall_t;
outer_y_min = inner_y_min - wall_t;
outer_y_max = inner_y_max + wall_t;
outer_z_max = inner_z_max;

lid_z_min = outer_z_max;
lid_z_max = lid_z_min + lid_t;
brand_y = 0;

hold_down_target_z = loadcell_top_z + loadcell_hold_down_clear;
hold_down_h = lid_z_min - hold_down_target_z;
hold_down_inner_x = bat_W / 2 + battery_side_wall_clear + battery_side_wall_t;
hold_down_outer_x = inner_x_max - loadcell_hold_down_wall_clear;
hold_down_w = hold_down_outer_x - hold_down_inner_x;
hold_down_x = (hold_down_inner_x + hold_down_outer_x) / 2;

screw_x1 = outer_x_min + screw_corner_inset;
screw_x2 = outer_x_max - screw_corner_inset;
screw_y1 = outer_y_min + screw_corner_inset;
screw_y2 = outer_y_max - screw_corner_inset;
head_recess_depth = max(0, min(screw_head_recess, lid_t - 0.6));
align_lip_h_eff = align_lip_enable ? max(0, min(align_lip_h, top_clear - 0.4)) : 0;
battery_front_stop_x = bat_W / 2 - battery_front_stop_x_inset - battery_front_stop_w / 2;
battery_front_stop_y = battery_front_y + battery_front_stop_y_clear + battery_front_stop_t / 2;
battery_front_stop_h = battery_front_stop_enable
    ? max(0, lid_z_min - (battery_top_z - battery_front_stop_z_overlap))
    : 0;
battery_side_wall_x = bat_W / 2 + battery_side_wall_clear + battery_side_wall_t / 2;
// Keep wall span within the hold-down column envelope.
battery_side_wall_l = 2 * loadcell_hold_down_y_offset + loadcell_hold_down_d;
// Extend through the lid thickness so the walls fuse into the roof.
battery_side_wall_h = lid_z_max - hold_down_target_z;
status_led_view_x = status_led_x;
status_led_view_y = pcb_y_offset + status_led_y;
rgb_led_view_x = rgb_led_x;
rgb_led_view_y = pcb_y_offset + rgb_led_y;
pcb_top_clamp_h = pcb_top_clamp_enable ? max(0, lid_z_min - (pcb_top_z + pcb_top_clamp_clear)) : 0;
// Positive case X maps to the KiCad left side, away from the right-side B+/SW+/B- wire pads.
pcb_top_clamp_x = pcb_W / 2 - pcb_top_clamp_x_inset - pcb_top_clamp_w / 2;
pcb_top_clamp_front_y = pcb_y_offset + pcb_L / 2 - pcb_top_clamp_front_setback;
pcb_top_clamp_rear_y = pcb_y_offset + pcb_L / 2 - pcb_top_clamp_rear_setback;

assert(!battery_front_stop_enable || battery_front_stop_w > 0,
    "battery_front_stop_w must be > 0.");
assert(!battery_side_wall_enable || battery_side_wall_t > 0,
    "battery_side_wall_t must be > 0.");
assert(loadcell_hold_down_d > 0,
    "loadcell_hold_down_d must be > 0.");
assert(loadcell_hold_down_y_offset >= 0,
    "loadcell_hold_down_y_offset must be >= 0.");
assert(loadcell_hold_down_wall_clear >= 0,
    str("loadcell_hold_down_wall_clear must be >= 0. Got ", loadcell_hold_down_wall_clear, " mm."));
assert(loadcell_channel_closure_fit >= 0
    && 2 * loadcell_channel_closure_fit < wall_t,
    str("loadcell_channel_closure_fit must leave a positive closure wall. fit=",
        loadcell_channel_closure_fit, " wall_t=", wall_t, " mm."));
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
assert(hold_down_w > 0,
    str("Load-cell hold-down width collapsed. inner_x=", hold_down_inner_x, " outer_x=", hold_down_outer_x, "."));
assert(hold_down_x + hold_down_w / 2 <= inner_x_max + 0.001,
    str("Load-cell hold-downs overlap main side wall by ",
        hold_down_x + hold_down_w / 2 - inner_x_max, " mm (X)."));
assert(hold_down_x - hold_down_w / 2 >= bat_W / 2 - 0.001,
    str("Load-cell hold-downs overlap battery by ",
        bat_W / 2 - (hold_down_x - hold_down_w / 2), " mm (X)."));
assert(!battery_front_stop_enable || battery_front_stop_h <= 0
    || battery_front_stop_x - battery_front_stop_w / 2 >= pcb_W / 2 + 0.2,
    "Battery front stop tabs must stay outside PCB width.");
assert(!battery_side_wall_enable || battery_side_wall_x + battery_side_wall_t / 2 <= inner_x_max + 0.001,
    str("Battery side walls overlap main side wall by ",
        battery_side_wall_x + battery_side_wall_t / 2 - inner_x_max, " mm (X)."));
assert(!battery_side_wall_enable || battery_side_wall_l <= (inner_y_max - inner_y_min) + 0.001,
    str("Battery side wall length exceeds inner cavity span by ",
        battery_side_wall_l - (inner_y_max - inner_y_min), " mm (Y)."));
assert(!pcb_top_clamp_enable || pcb_top_clamp_clear >= 0,
    str("pcb_top_clamp_clear must be >= 0. Got ", pcb_top_clamp_clear, " mm."));
assert(!pcb_top_clamp_enable || (pcb_top_clamp_w > 0 && pcb_top_clamp_d > 0),
    str("PCB top clamp footprint must be positive. w=", pcb_top_clamp_w, " d=", pcb_top_clamp_d));
assert(!pcb_top_clamp_enable || abs(pcb_top_clamp_x) + pcb_top_clamp_w / 2 <= pcb_W / 2 + 0.001,
    "PCB top clamps must stay inside PCB width.");
assert(!pcb_top_clamp_enable || pcb_top_clamp_front_y + pcb_top_clamp_d / 2 <= pcb_y_offset + pcb_L / 2 + 0.001,
    "Front PCB top clamp must stay behind the PCB front edge.");
assert(!pcb_top_clamp_enable || pcb_top_clamp_rear_y - pcb_top_clamp_d / 2 >= pcb_y_offset - pcb_L / 2 - 0.001,
    "Rear PCB top clamp must stay inside the PCB rear edge.");
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

module each_corner(z_pos) {
    for (x = [screw_x1, screw_x2])
        for (y = [screw_y1, screw_y2])
            translate([x, y, z_pos])
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

module lid_loadcell_eye_access_paths() {
    access_z_min = loadcell_top_z - 0.1;
    access_z_max = lid_z_max + 0.2;
    access_h = access_z_max - access_z_min;
    access_z = (access_z_min + access_z_max) / 2;

    for (eye_x = [
        -lc_L / 2 + eye_center_offset,
        lc_L / 2 - eye_center_offset
    ])
        translate([eye_x, 0, access_z])
            cylinder(d = carabiner_access_d, h = access_h, center = true);
}

module loadcell_channel_closures() {
    closure_z_min = loadcell_top_z + loadcell_channel_clear_z;
    closure_z_max = lid_z_min + internal_feature_embed;
    closure_h = closure_z_max - closure_z_min;
    closure_z = (closure_z_min + closure_z_max) / 2;
    closure_x_t = wall_t - 2 * loadcell_channel_closure_fit;
    closure_y = lc_W + 2 * loadcell_channel_clear_y
        - 2 * loadcell_channel_closure_fit;

    if (closure_h > 0 && closure_x_t > 0 && closure_y > 0)
        for (x_sign = [-1, 1])
            translate([
                x_sign * (case_inner_x_half + wall_t / 2),
                0,
                closure_z
            ])
                cube([closure_x_t, closure_y, closure_h], center = true);
}

module lid_loadcell_eye_tunnel_walls() {
    tunnel_z_min = loadcell_top_z + loadcell_channel_clear_z;
    tunnel_z_max = lid_z_max;
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

module loadcell_hold_downs() {
    hold_down_h_eff = hold_down_h + internal_feature_embed;
    hold_down_z = hold_down_target_z + hold_down_h_eff / 2;

    for (x_sign = [-1, 1])
        // Keep the center open for the battery and PCB stack.
        for (y_off = [-loadcell_hold_down_y_offset, loadcell_hold_down_y_offset])
            translate([x_sign * hold_down_x, y_off, hold_down_z])
                cube([hold_down_w, loadcell_hold_down_d, hold_down_h_eff], center = true);
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

module battery_front_stops() {
    if (battery_front_stop_h > 0 && battery_front_stop_t > 0 && battery_front_stop_w > 0) {
        stop_h_eff = battery_front_stop_h + internal_feature_embed;
        stop_z = lid_z_min - battery_front_stop_h / 2 + internal_feature_embed / 2;

        for (x_sign = [-1, 1])
            translate([x_sign * battery_front_stop_x, battery_front_stop_y, stop_z])
                cube([battery_front_stop_w, battery_front_stop_t, stop_h_eff], center = true);
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
    if (pcb_top_clamp_enable && pcb_top_clamp_h > 0) {
        clamp_h_eff = pcb_top_clamp_h + internal_feature_embed;
        clamp_z = pcb_top_z + pcb_top_clamp_clear + clamp_h_eff / 2;

        for (clamp_y = [pcb_top_clamp_front_y, pcb_top_clamp_rear_y])
            // Press on the side opposite the B+/SW+/B- wiring.
            translate([pcb_top_clamp_x, clamp_y, clamp_z])
                cube([pcb_top_clamp_w, pcb_top_clamp_d, clamp_h_eff], center = true);
    }
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
                corner_r
            );
            lid_alignment_lips();
            battery_front_stops();
            battery_side_wall_features();
            pcb_top_clamps();
            // Close the main body's top-loading side channels around the
            // load cell, leaving only a tolerance-sized horizontal slot.
            loadcell_channel_closures();
            // Isolate both vertical carabiner paths from the electronics bay.
            lid_loadcell_eye_tunnel_walls();
            if (hold_down_h > 0) {
                loadcell_hold_downs();
            }
        }
        corner_holes(screw_clear_d, lid_z_min - align_lip_h_eff, lid_z_max);
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
