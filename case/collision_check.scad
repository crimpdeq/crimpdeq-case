// Collision/overlap checks for enclosure and assembly parts.
// Use with: openscad -D 'mode="main_lid"' -o /tmp/out.stl case/collision_check.scad

use <case_main.scad>
use <case_lid.scad>
use <load_cell.scad>
use <battery.scad>
use <pcb.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 24 : render_fn;
$fn = render_fn;

// Override from CLI with -D 'mode="..."'
mode = "main_lid";

module asm_loadcell() {
    translate([0, 0, loadcell_center_z])
        linear_extrude(height = lc_T, center = true)
            loadcell_2d();
    translate([0, 0, loadcell_top_z])
        loadcell_gauge_cover();
}

module asm_loadcell_arm(x_sign) {
    arm_w = lc_L / 2 - case_inner_x_half + 0.2;
    arm_x = x_sign * (case_inner_x_half + arm_w / 2 - 0.1);

    intersection() {
        asm_loadcell();
        translate([arm_x, 0, loadcell_center_z])
            cube([arm_w, lc_W + 1, lc_T + 1], center = true);
    }
}

// Shank poses through the case height: centered in the eye, bearing on the
// outer side of the eye ring, and tilted outward around that contact.
carabiner_probe_z_min = loadcell_center_z - 6.5; // just below the floor
carabiner_probe_z_max = loadcell_center_z + 24; // just above the lid
carabiner_probe_tilt = 15;

module carabiner_eye_probe(x_sign) {
    module shank(x_bottom, x_top) {
        hull() {
            translate([x_sign * x_bottom, 0, carabiner_probe_z_min])
                cylinder(d = carabiner_shank_d, h = 0.01, center = true);
            translate([x_sign * x_top, 0, carabiner_probe_z_max])
                cylinder(d = carabiner_shank_d, h = 0.01, center = true);
        }
    }

    tilt = tan(carabiner_probe_tilt);
    shank(eye_x, eye_x);
    shank(carabiner_loaded_x, carabiner_loaded_x);
    shank(
        carabiner_loaded_x + tilt * (carabiner_probe_z_min - loadcell_center_z),
        carabiner_loaded_x + tilt * (carabiner_probe_z_max - loadcell_center_z)
    );
}

// Rods leaving one load-cell corner outward along X and upward along Z.
module corner_end_probe(x_sign, y_sign) {
    translate([x_sign * (lc_L / 2 + 5), y_sign * (lc_W / 2 - 1), loadcell_center_z])
        cube([10, 1, 1], center = true);
}

// A sheet along the gap round one lid slot-wall end, from the slot into the
// bay. Only the main-body fin can block it.
module slot_seal_probe(x_sign, y_sign) {
    y0 = carabiner_slot_d / 2 - 1;
    y1 = slot_seal_fin_y + loadcell_slot_wall_t + 1;
    translate([0, 0, loadcell_top_z + 1])
        linear_extrude(height = 14)
            intersection() {
                difference() {
                    case_outline_2d(wall_t + slot_wall_fit / 2 - 0.05);
                    case_outline_2d(wall_t + slot_wall_fit / 2 + 0.05);
                }
                translate([x_sign > 0 ? 0 : -case_tip_x, y_sign > 0 ? y0 : -y1])
                    square([case_tip_x, y1 - y0]);
            }
}

module corner_roof_probe(x_sign, y_sign) {
    translate([x_sign * (lc_L / 2 - 1), y_sign * (lc_W / 2 - 1), loadcell_top_z + 15])
        cube([1, 1, 30], center = true);
}

// Core of each M2.5x10 screw, from its seated head to its tip.
module screw_core_probe() {
    head_seat_z = pcb_top_z + top_clear + lid_t - screw_head_recess;
    each_corner(head_seat_z - screw_len)
        cylinder(d = 1.0, h = screw_len);
}

// Strips beside each side of the switch opening at its inner end. Only the
// collar is there, so they find material only if the opening grips the bezel
// over the whole switch_grip_len.
module switch_grip_probe() {
    for (x_sign = [-1, 1])
        translate([x_sign * (switch_w / 2 + 0.06), switch_grip_y + 0.06, switch_z])
            cube([0.1, 0.1, switch_h - 1], center = true);
}

module asm_battery() {
    translate([0, battery_y_offset, loadcell_top_z + loadcell_to_battery_gap + bat_T / 2])
        battery_model(rounded = true);
}

module asm_pcb() {
    translate([0, pcb_y_offset, pcb_board_bottom_z])
        pcb_model();
}

module asm_switch(inset = 0) {
    translate([switch_x, switch_y, switch_z])
        rotate([0, switch_rot_y, 0])
            cube([switch_w - 2 * inset, switch_d, switch_h - 2 * inset], center = true);
}

// Vertical drop-in paths from each seat to above the case. The board path
// leaves out the USB-C connector, which is tilted into the front wall.
module loadcell_drop_in_probe() {
    translate([0, 0, loadcell_bottom_z + 0.05])
        linear_extrude(height = 30)
            loadcell_2d();
}

module battery_drop_in_probe() {
    hull() {
        asm_battery();
        translate([0, 0, 30]) asm_battery();
    }
}

module pcb_board_drop_in_probe() {
    translate([0, pcb_y_offset, pcb_board_bottom_z + 0.05])
        linear_extrude(height = 30)
            square([pcb_W, pcb_L], center = true);
}

// The board under each lid clamp, which the clamps press by their preload.
module pcb_clamp_contact() {
    intersection() {
        pcb_top_clamps();
        translate([-50, -50, pcb_board_bottom_z])
            cube([100, 100, pcb_board_t]);
    }
}

// The lid may touch the board only through the clamps.
module lid_pcb_outside_clamps(dy) {
    intersection() {
        lid_part();
        difference() {
            translate([0, dy, 0]) asm_pcb();
            pcb_clamp_contact();
        }
    }
}

// Wire routes, wire_d thick. Each cable pad needs room below for its solder
// joint and the wire bend.
module cable_pad_wire_probe() {
    for (p = pcb_cable_pads)
        translate([p[0], pcb_y_offset + p[1], pcb_board_bottom_z - 4])
            cylinder(d = wire_d, h = 4);
}

// A wire bundle swept through points; each cube is its envelope.
module wire_path(points, size) {
    for (i = [0 : len(points) - 2])
        hull() {
            translate(points[i]) cube(size, center = true);
            translate(points[i + 1]) cube(size, center = true);
        }
}

wire_env = wire_d + 0.1;
wire_pair = [2, 2, 2] * wire_env; // two wires in any orientation
wire_pair_stacked = [1, 1, 2] * wire_env; // two wires stacked in Z

function pad_point(i, z) = [pcb_cable_pads[i][0], pcb_y_offset + pcb_cable_pads[i][1], z];

// Switch wires turn up behind the joints, in the bend zone in front of the
// battery and load cell, run right over the battery-front rib and forward
// beside the right PCB column, then split to the SW+ and SW- pads.
module switch_wire_probe() {
    bend_y = switch_y - switch_d / 2 - switch_wire_bend / 2;
    run_z = switch_z + switch_h / 2 + switch_clear + wire_pair[2] / 2 + 0.05;
    lane_x = pcb_cable_pads[2][0] + 1;
    split = [lane_x, pcb_y_offset + pcb_cable_pads[2][1], run_z];
    pad_z = pcb_board_bottom_z - wire_env / 2 - 0.05;
    wire_path([
        [0, bend_y, switch_z],
        [0, bend_y, run_z],
        [lane_x, bend_y, run_z],
        split
    ], wire_pair);
    for (i = [2, 3])
        wire_path([split, pad_point(i, pad_z)], [1, 1, 1] * wire_env);
}

// Battery leads leave its rear end, rise behind it and run forward over its
// right edge, beside the board, then drop in front of it and split to the
// B- and B+ pads.
module battery_wire_probe() {
    rear_y = battery_y_offset - bat_L / 2 - 0.25 - wire_pair[1] / 2;
    over_z = battery_top_z + 0.05 + wire_pair_stacked[2] / 2;
    lane_x = pcb_W / 2 + 0.3 + wire_env / 2;
    split = [lane_x, pcb_y_offset + pcb_cable_pads[0][1], battery_top_z];
    pad_z = pcb_board_bottom_z - wire_env / 2 - 0.05;
    wire_path([
        [0, rear_y, battery_bottom_z + wire_pair[2] / 2],
        [0, rear_y, over_z]
    ], wire_pair);
    wire_path([
        [0, rear_y, over_z],
        [lane_x, rear_y, over_z],
        [lane_x, battery_front_y + wire_env, over_z],
        split
    ], wire_pair_stacked);
    for (i = [0, 1])
        wire_path([split, pad_point(i, pad_z)], [1, 1, 1] * wire_env);
}

// Load-cell wires leave the gauge cover toward the front, run left under the
// battery, rise beyond its side, run forward outside the left PCB column and
// cross under the board to the front-edge pads.
module loadcell_wire_probe() {
    w = loadcell_wire_bundle[0];
    h = loadcell_wire_bundle[1];
    exit_y = gauge_cover_y + gauge_cover_l / 2;
    lane_y = [exit_y, exit_y + w];
    side_x = -(bat_W / 2 + 2.5);
    run_x = [side_x - w / 2, side_x + w / 2];
    pad_y = pcb_y_offset + pcb_cable_pads[4][1];
    cross_y = [pad_y - w / 2, pad_y + w / 2];
    cross_z = pcb_board_bottom_z - 4;
    under_z = [loadcell_top_z + 0.05, loadcell_top_z + 0.05 + h];
    box([run_x[0], w / 2], lane_y, under_z);
    box(run_x, lane_y, [under_z[0], battery_bottom_z + h]);
    box(run_x, [exit_y, pad_y + w / 2], [battery_bottom_z, battery_bottom_z + h]);
    box(run_x, cross_y, [battery_bottom_z, cross_z + h]);
    box([run_x[0], pcb_cable_pads[7][0] + w / 2], cross_y, [cross_z, cross_z + h]);
}

module led_sightline_probe(led_x, led_y, d, led_h) {
    translate([led_x, pcb_y_offset + led_y, pcb_board_top_z + led_h])
        cylinder(d = d, h = 10, center = false);
}

module asm_all() {
    union() {
        asm_loadcell();
        asm_battery();
        asm_pcb();
        asm_switch();
    }
}

if (mode == "main_lid") {
    intersection() { main_part(); lid_part(); }
} else if (mode == "main_lid_eps_up") {
    intersection() { main_part(); translate([0, 0, 0.01]) lid_part(); }
} else if (mode == "main_lid_shifted") {
    // The lid must seat anywhere within the 0.25 mm play of the screws in their
    // lid holes, plus 0.2 mm for printed walls off size.
    lid_shift = 0.45;
    for (d = [[1, 0], [-1, 0], [0, 1], [0, -1]])
        intersection() { main_part(); translate([d[0] * lid_shift, d[1] * lid_shift, 0.01]) lid_part(); }
} else if (mode == "main_lid_eps_down") {
    intersection() { main_part(); translate([0, 0, -0.05]) lid_part(); }
} else if (mode == "main_components") {
    intersection() { main_part(); asm_all(); }
} else if (mode == "main_loadcell") {
    intersection() { main_part(); asm_loadcell(); }
} else if (mode == "main_loadcell_arm_x_neg") {
    intersection() { main_part(); asm_loadcell_arm(-1); }
} else if (mode == "main_loadcell_arm_x_pos") {
    intersection() { main_part(); asm_loadcell_arm(1); }
} else if (mode == "main_eye_access_x_neg") {
    intersection() { main_part(); carabiner_eye_probe(-1); }
} else if (mode == "main_eye_access_x_pos") {
    intersection() { main_part(); carabiner_eye_probe(1); }
} else if (mode == "main_notch_retention_y_neg") {
    intersection() { notch_pins(); translate([0, -0.15, 0]) asm_loadcell(); }
} else if (mode == "main_notch_retention_y_pos") {
    intersection() { notch_pins(); translate([0, 0.15, 0]) asm_loadcell(); }
} else if (mode == "main_loadcell_eps_z_plus") {
    intersection() { main_part(); translate([0, 0, 0.05]) asm_loadcell(); }
} else if (mode == "main_battery") {
    intersection() { main_part(); asm_battery(); }
} else if (mode == "main_pcb_eps_z_minus") {
    intersection() { main_part(); translate([0, 0, -0.05]) asm_pcb(); }
} else if (mode == "main_loadcell_drop_in") {
    intersection() { main_part(); loadcell_drop_in_probe(); }
} else if (mode == "main_battery_drop_in") {
    intersection() { main_part(); battery_drop_in_probe(); }
} else if (mode == "main_pcb_drop_in") {
    intersection() { main_part(); pcb_board_drop_in_probe(); }
} else if (mode == "main_pcb_eps_x_neg") {
    intersection() { main_part(); translate([-0.2, 0, 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_eps_x_pos") {
    intersection() { main_part(); translate([0.2, 0, 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_guide_x_neg") {
    intersection() { main_part(); translate([-0.3, 0, 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_usb_side_stop") {
    intersection() { main_part(); translate([0.5, 0, 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_eps_yz_plus") {
    intersection() { main_part(); translate([0, 0.05, 0.05]) asm_pcb(); }
} else if (mode == "main_cable_pad_wires") {
    intersection() { main_part(); cable_pad_wire_probe(); }
} else if (mode == "main_switch_wires") {
    intersection() { main_part(); switch_wire_probe(); }
} else if (mode == "main_battery_wires") {
    intersection() { main_part(); battery_wire_probe(); }
} else if (mode == "main_loadcell_wires") {
    intersection() { main_part(); loadcell_wire_probe(); }
} else if (mode == "main_switch_grip") {
    intersection() { main_part(); switch_grip_probe(); }
} else if (mode == "main_switch") {
    // The bezel is a press fit in the opening, so it may touch its sides.
    intersection() { main_part(); asm_switch(inset = 0.01); }
} else if (mode == "main_screw_pilot_fit") {
    intersection() { main_part(); screw_core_probe(); }
} else if (mode == "main_usb_cable") {
    intersection() { main_part(); usb_cable_fit_probe(); }
} else if (mode == "main_usb_overmold_stop") {
    intersection() { main_part(); translate([0, -0.05, 0]) usb_cable_fit_probe(); }
} else if (mode == "lid_components") {
    intersection() { lid_part(); asm_all(); }
} else if (mode == "lid_loadcell") {
    intersection() { lid_part(); asm_loadcell(); }
} else if (mode == "lid_loadcell_lift") {
    // A load cell resting 0.5 mm high, on a print slightly off size, must not
    // hold the lid open.
    intersection() { lid_part(); translate([0, 0, 0.5]) asm_loadcell(); }
} else if (mode == "lid_eye_access_x_neg") {
    intersection() { lid_part(); carabiner_eye_probe(-1); }
} else if (mode == "lid_eye_access_x_pos") {
    intersection() { lid_part(); carabiner_eye_probe(1); }
} else if (mode == "main_corner_end_xn_yn") {
    intersection() { main_part(); corner_end_probe(-1, -1); }
} else if (mode == "main_corner_end_xn_yp") {
    intersection() { main_part(); corner_end_probe(-1, 1); }
} else if (mode == "main_corner_end_xp_yn") {
    intersection() { main_part(); corner_end_probe(1, -1); }
} else if (mode == "main_corner_end_xp_yp") {
    intersection() { main_part(); corner_end_probe(1, 1); }
} else if (mode == "main_slot_seal_xn_yn") {
    intersection() { main_part(); slot_seal_probe(-1, -1); }
} else if (mode == "main_slot_seal_xn_yp") {
    intersection() { main_part(); slot_seal_probe(-1, 1); }
} else if (mode == "main_slot_seal_xp_yn") {
    intersection() { main_part(); slot_seal_probe(1, -1); }
} else if (mode == "main_slot_seal_xp_yp") {
    intersection() { main_part(); slot_seal_probe(1, 1); }
} else if (mode == "lid_corner_roof_xn_yn") {
    intersection() { lid_part(); corner_roof_probe(-1, -1); }
} else if (mode == "lid_corner_roof_xn_yp") {
    intersection() { lid_part(); corner_roof_probe(-1, 1); }
} else if (mode == "lid_corner_roof_xp_yn") {
    intersection() { lid_part(); corner_roof_probe(1, -1); }
} else if (mode == "lid_corner_roof_xp_yp") {
    intersection() { lid_part(); corner_roof_probe(1, 1); }
} else if (mode == "lid_battery_clamped") {
    intersection() { lid_part(); asm_battery(); }
} else if (mode == "lid_battery_outside_hold_downs") {
    // The lid may touch the battery only through the hold-downs.
    intersection() { lid_part(); difference() { asm_battery(); battery_hold_downs(); } }
} else if (mode == "lid_battery_hold_down_preload") {
    intersection() { battery_hold_downs(); translate([0, 0, -battery_hold_down_preload - 0.05]) asm_battery(); }
} else if (mode == "lid_pcb_clamped") {
    intersection() { lid_part(); asm_pcb(); }
} else if (mode == "lid_pcb_outside_clamps") {
    lid_pcb_outside_clamps(0);
} else if (mode == "lid_pcb_rear_travel") {
    lid_pcb_outside_clamps(-0.24);
} else if (mode == "lid_pcb_rear_stop") {
    intersection() { pcb_rear_stops(); translate([0, -0.3, 0]) asm_pcb(); }
} else if (mode == "lid_switch_wires") {
    intersection() { lid_part(); switch_wire_probe(); }
} else if (mode == "lid_battery_wires") {
    intersection() { lid_part(); battery_wire_probe(); }
} else if (mode == "lid_loadcell_wires") {
    intersection() { lid_part(); loadcell_wire_probe(); }
} else if (mode == "lid_switch") {
    intersection() { lid_part(); asm_switch(); }
} else if (mode == "lid_screw_shank_fit") {
    intersection() { lid_part(); lid_screw_shank_fit_probe(); }
} else if (mode == "lid_screw_head_fit") {
    intersection() { lid_part(); lid_screw_head_fit_probe(); }
} else if (mode == "lid_status_led_sightline") {
    intersection() {
        lid_part();
        led_sightline_probe(status_led_x, status_led_y, max(status_led_w, status_led_l), status_led_h);
    }
} else if (mode == "lid_rgb_led_sightline") {
    intersection() {
        lid_part();
        led_sightline_probe(rgb_led_x, rgb_led_y, max(rgb_led_w, rgb_led_l), rgb_led_h);
    }
} else if (mode == "loadcell_battery") {
    intersection() { asm_loadcell(); asm_battery(); }
} else if (mode == "loadcell_pcb") {
    intersection() { asm_loadcell(); asm_pcb(); }
} else if (mode == "loadcell_switch") {
    intersection() { asm_loadcell(); asm_switch(); }
} else if (mode == "battery_pcb") {
    intersection() { asm_battery(); asm_pcb(); }
} else if (mode == "battery_pcb_eps_z_plus") {
    intersection() { asm_battery(); translate([0, 0, 0.05]) asm_pcb(); }
} else if (mode == "battery_wires") {
    intersection() { asm_battery(); union() { loadcell_wire_probe(); switch_wire_probe(); battery_wire_probe(); } }
} else if (mode == "battery_switch") {
    intersection() { asm_battery(); asm_switch(); }
} else if (mode == "pcb_switch") {
    intersection() { asm_pcb(); asm_switch(); }
} else {
    echo(str("Unknown mode: ", mode));
}
