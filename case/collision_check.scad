// Collision/overlap checks for enclosure and assembly parts.
// Use with: openscad -D 'mode="main_battery"' -o /tmp/out.stl case/collision_check.scad

use <case_main.scad>
use <case_lid.scad>
use <load_cell.scad>
use <pcb.scad>
use <assembly.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 24 : render_fn;
$fn = render_fn;

// Override from CLI with -D 'mode="..."'
mode = "main_battery";

lid_seat_shifts = [[1, 0], [-1, 0], [0, 1], [0, -1]] * lid_seat_play;

// The load cell beyond the battery bay, where the main body may not touch it.
module asm_loadcell_arm(x_sign) {
    intersection() {
        asm_loadcell();
        box(x_sign * [carabiner_slot_inner_x - loadcell_slot_wall_t, lc_L], [-lc_W, lc_W], [0, lid_top_z]);
    }
}

// Shank poses through the case height: centered in the eye, bearing on the
// outer side of the eye ring, and tilted outward around that contact.
carabiner_probe_z_min = -1; // just below the floor
carabiner_probe_z_max = lid_top_z + 1; // just above the lid
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

module corner_roof_probe(x_sign, y_sign) {
    translate([x_sign * (lc_L / 2 - 1), y_sign * (lc_W / 2 - 1), loadcell_top_z + 15])
        cube([1, 1, 30], center = true);
}

// A sheet across the gap between one lid slot-wall end and the bottom of its
// end-wall groove, from the slot into the bay. Only the groove's bay-side
// wall can block it.
module slot_seal_probe(x_sign, y_sign) {
    box(x_sign * span(end_groove_x - slot_wall_fit / 2, 0.05),
        y_sign * [carabiner_slot_d / 2 - 1, slot_wall_outer_y + slot_wall_fit + 1],
        [loadcell_top_z + 1, seam_z - 1]);
}

// Core of each M2.5x10 screw, from its seated head to its tip.
module screw_core_probe() {
    each_screw(lid_top_z - screw_head_recess - screw_len)
        cylinder(d = 1.0, h = screw_len);
}

// Strips beside each side of the switch opening at its inner end. Only the
// collar is there, so they find material only if the opening grips the bezel
// over the whole switch_grip_len.
module switch_grip_probe() {
    for (x_sign = [-1, 1])
        translate([switch_x + x_sign * (switch_w / 2 + 0.06), switch_grip_y - 0.06, switch_z])
            cube([0.1, 0.1, switch_h - 1], center = true);
}

// Vertical drop-in paths from each seat to above the case.
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

// The board and its USB-C receptacle, which drops into the open-topped
// front-wall opening.
module pcb_drop_in_probe() {
    translate([0, pcb_y, pcb_board_bottom_z + 0.05])
        linear_extrude(height = 30)
            pcb_outline_2d();
    translate([0, pcb_y, pcb_board_top_z + 0.05])
        linear_extrude(height = 30)
            pcb_rect_2d(usb_rect);
}

// The receptacle under the clamp, which the clamp presses by its preload.
module usb_clamp_contact() {
    intersection() {
        usb_clamp();
        box([-50, 50], [-50, 50], [0, usb_top_z]);
    }
}

// The lid may touch the board only through the USB-C clamp. The clamp is
// grown by 0.01 mm, so faces it shares with the board leave no sliver.
module lid_pcb_outside_clamp(dy) {
    intersection() {
        difference() {
            lid_part();
            minkowski() {
                usb_clamp();
                cube(0.02, center = true);
            }
        }
        translate([0, dy, 0]) asm_pcb();
    }
}

// Wherever the lid seats and the board sits within its guides, the clamp
// stays on the flat shell top. A shifted clamp edge may land exactly on the
// shell's edge, so widen the shell by 0.01 mm.
module usb_clamp_off_shell() {
    for (d = lid_seat_shifts)
        difference() {
            translate([d[0], d[1], 0]) usb_clamp_contact();
            translate([0, pcb_y, 0])
                linear_extrude(height = lid_top_z)
                    offset(delta = -pcb_guide_clear + 0.01)
                        pcb_rect_2d(usb_shell_top_rect);
        }
}

// A fully mated cable: the plug shell inside the receptacle and the largest
// recommended overmold stopped usb_overmold_stop_gap in front of it.
module usb_cable_fit_probe() {
    usb_prism(usb_pocket_floor_y, usb_face_y + 6.5, usb_plug_shell_w,
        usb_center_z - usb_plug_shell_h / 2, usb_center_z + usb_plug_shell_h / 2, usb_plug_shell_corner_r);
    usb_prism(outer_front_y - 15, usb_pocket_floor_y - 0.01, usb_overmold_w,
        usb_center_z - usb_overmold_h / 2, usb_center_z + usb_overmold_h / 2, usb_overmold_corner_r);
}

// From the LED top to the inner face of its lid window.
module led_sightline_probe(led_x, led_y, d, led_h) {
    translate([led_x, pcb_y + led_y, pcb_board_top_z + led_h])
        cylinder(d = d, h = lid_top_z - led_window_t - pcb_board_top_z - led_h);
}

// The window layer over each LED, which the lid must fill.
module led_window_probe() {
    for (led = [[status_led_x, status_led_y, max(status_led_w, status_led_l)],
                [rgb_led_x, rgb_led_y, max(rgb_led_w, rgb_led_l)]])
        translate([led[0], pcb_y + led[1], lid_top_z - led_window_t + 0.05])
            cylinder(d = led[2], h = led_window_t - 0.1);
}

// Wire routes. Each cable pad needs room below for its solder joint and the
// wire bend.
pad_probe_h = 4;
pad_probe_z = pcb_board_bottom_z - pad_probe_h;

module cable_pad_wire_probe() {
    for (p = pcb_cable_pads)
        translate([p[0], pcb_y + p[1], pad_probe_z])
            cylinder(d = wire_d, h = pad_probe_h);
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
wire_single = [1, 1, 1] * wire_env;
wire_pair_stacked = [1, 1, 2] * wire_env; // two wires stacked in Z
wire_pair_flat = [2, 2, 1] * wire_env; // two wires side by side

function pad_point(i, z) = [pcb_cable_pads[i][0], pcb_y + pcb_cable_pads[i][1], z];

// Lane between the PCB column and the right front post, below the J4 pads.
j4_lane_x = (pcb_support_windows[1][1] + pcb_W / 2 + pcb_guide_clear) / 2;
pad_run_z = pad_probe_z - wire_pair_stacked[2] / 2;

// The load-cell wires leave the gauge cover toward the front under the plate,
// come out at its front edge below the J3 pads, rise in front of the battery
// and run forward under the pads.
module loadcell_wire_probe() {
    w = loadcell_wire_bundle[0];
    h = loadcell_wire_bundle[1];
    size = [w, w, h];
    lane_x = -j4_lane_x;
    under_z = loadcell_bottom_z - 0.05 - h / 2;
    rise_y = battery_front_y - 0.4 - w / 2;
    run_z = pad_probe_z - h / 2;
    wire_path([
        [0, -gauge_cover_y - gauge_cover_l / 2 - w / 2, under_z],
        [lane_x, battery_front_y + 1.5, under_z],
        [lane_x, rise_y, under_z],
        [lane_x, rise_y, run_z],
        [lane_x, pcb_y + pcb_cable_pads[3][1], run_z]
    ], size);
}

// Battery leads leave the right corner of the front end sideways, turn
// forward beside it, run left along its front to the lane and forward below
// the B+ and B- pads.
module battery_wire_probe() {
    z = battery_bottom_z + bat_T / 2;
    bend_x = bat_W / 2 + battery_lead_bend / 2;
    run_y = battery_front_y - 0.05 - wire_pair_stacked[1] / 2;
    split = [j4_lane_x, pcb_y + pcb_cable_pads[6][1], pad_run_z];
    wire_path([
        [bend_x, battery_front_y + battery_lead_y, z],
        [bend_x, run_y, z],
        [j4_lane_x, run_y, z],
        [j4_lane_x, run_y, pad_run_z],
        split
    ], wire_pair_stacked);
    for (i = [6, 7])
        wire_path([split, pad_point(i, pad_probe_z)], wire_single);
}

// Switch wires turn up behind the joints, run left over the battery beside
// the board, forward in front of the battery, drop beside the right front
// post and split to the SW- and SW+ pads.
module switch_wire_probe() {
    bend_y = switch_rear_y + switch_wire_bend / 2;
    over_z = battery_top_z + 0.05 + wire_pair_flat[2] / 2;
    over_x = pcb_W / 2 + 0.3 + wire_pair_flat[0] / 2;
    drop_y = battery_front_y - 0.3 - wire_pair_flat[1] / 2;
    split = [j4_lane_x, drop_y, pad_run_z];
    wire_path([
        [switch_x, switch_rear_y + 0.05 + wire_pair_flat[1] / 2, switch_z],
        [switch_x, bend_y, over_z],
        [over_x, bend_y, over_z],
        [over_x, drop_y, over_z],
        [over_x, drop_y, pad_run_z]
    ], wire_pair_flat);
    wire_path([[over_x, drop_y, pad_run_z], split], wire_pair_stacked);
    for (i = [4, 5])
        wire_path([split, pad_point(i, pad_probe_z)], wire_single);
}

module all_wire_probes() {
    cable_pad_wire_probe();
    loadcell_wire_probe();
    battery_wire_probe();
    switch_wire_probe();
}

module asm_all() {
    asm_loadcell();
    asm_battery();
    asm_pcb();
    asm_switch();
}

// Seated lid, nudged up by eps, at nominal and every seat shift.
module lid_seated(eps, d = [0, 0]) {
    translate([d[0], d[1], eps]) lid_part();
}

if (mode == "main_lid_eps_up") {
    intersection() { main_part(); lid_seated(0.01); }
} else if (mode == "main_lid_shifted") {
    for (d = lid_seat_shifts)
        intersection() { main_part(); lid_seated(0.01, d); }
} else if (mode == "main_lid_eps_down") {
    intersection() { main_part(); lid_seated(-0.05); }
} else if (mode == "main_loadcell_eps_z_minus") {
    intersection() { main_part(); translate([0, 0, -0.05]) asm_loadcell(); }
} else if (mode == "main_loadcell_eps_z_plus") {
    intersection() { main_part(); translate([0, 0, 0.05]) asm_loadcell(); }
} else if (mode == "main_loadcell_arm_x_neg") {
    intersection() { main_part(); asm_loadcell_arm(-1); }
} else if (mode == "main_loadcell_arm_x_pos") {
    intersection() { main_part(); asm_loadcell_arm(1); }
} else if (mode == "main_loadcell_play") {
    // Within its play the plate touches nothing but its pads.
    for (d = [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]] * (notch_pin_clear - 0.05))
        intersection() { main_part(); translate([d[0], d[1], 0.05]) asm_loadcell(); }
} else if (mode == "main_loadcell_stop_x_neg") {
    intersection() { main_part(); translate([-notch_pin_clear - 0.05, 0, 0.05]) asm_loadcell(); }
} else if (mode == "main_loadcell_stop_x_pos") {
    intersection() { main_part(); translate([notch_pin_clear + 0.05, 0, 0.05]) asm_loadcell(); }
} else if (mode == "main_loadcell_stop_y_pos") {
    intersection() { main_part(); translate([0, notch_pin_clear + 0.05, 0.05]) asm_loadcell(); }
} else if (mode == "main_loadcell_stop_y_neg") {
    intersection() { main_part(); translate([0, -notch_pin_clear - 0.05, 0.05]) asm_loadcell(); }
} else if (mode == "main_eye_access_x_neg") {
    intersection() { main_part(); carabiner_eye_probe(-1); }
} else if (mode == "main_eye_access_x_pos") {
    intersection() { main_part(); carabiner_eye_probe(1); }
} else if (mode == "main_battery") {
    intersection() { main_part(); asm_battery(); }
} else if (mode == "main_battery_stop_y_neg") {
    intersection() { main_part(); translate([0, -battery_stop_clear - 0.05, 0]) asm_battery(); }
} else if (mode == "main_battery_stop_y_pos") {
    intersection() { main_part(); translate([0, battery_stop_clear + 0.05, 0]) asm_battery(); }
} else if (mode == "main_loadcell_drop_in") {
    intersection() { main_part(); loadcell_drop_in_probe(); }
} else if (mode == "main_battery_drop_in") {
    intersection() { main_part(); battery_drop_in_probe(); }
} else if (mode == "main_pcb_drop_in") {
    intersection() { main_part(); pcb_drop_in_probe(); }
} else if (mode == "main_pcb_eps_z_minus") {
    intersection() { main_part(); translate([0, 0, -0.05]) asm_pcb(); }
} else if (mode == "main_pcb_play") {
    // Within its play the board touches nothing but its fingers.
    for (d = [[0, 0], [pcb_guide_clear - 0.05, 0], [0.05 - pcb_guide_clear, 0],
              [0, 0.05 - pcb_front_gap], [0, pcb_rear_travel]])
        intersection() { main_part(); translate([d[0], d[1], 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_guide_x_neg") {
    intersection() { main_part(); translate([-pcb_guide_clear - 0.05, 0, 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_guide_x_pos") {
    intersection() { main_part(); translate([pcb_guide_clear + 0.05, 0, 0.05]) asm_pcb(); }
} else if (mode == "main_pcb_front_stop") {
    intersection() { main_part(); translate([0, -pcb_front_gap - 0.05, 0.05]) asm_pcb(); }
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
    intersection() { main_part(); translate([0, 0.05, 0]) usb_cable_fit_probe(); }
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
} else if (mode == "lid_corner_roof_xn_yn") {
    intersection() { lid_part(); corner_roof_probe(-1, -1); }
} else if (mode == "lid_corner_roof_xn_yp") {
    intersection() { lid_part(); corner_roof_probe(-1, 1); }
} else if (mode == "lid_corner_roof_xp_yn") {
    intersection() { lid_part(); corner_roof_probe(1, -1); }
} else if (mode == "lid_corner_roof_xp_yp") {
    intersection() { lid_part(); corner_roof_probe(1, 1); }
} else if (mode == "lid_battery") {
    intersection() { lid_part(); asm_battery(); }
} else if (mode == "lid_battery_lift") {
    intersection() { lid_part(); translate([0, 0, battery_hold_down_clear + 0.05]) asm_battery(); }
} else if (mode == "lid_pcb_clamped") {
    intersection() { lid_part(); asm_pcb(); }
} else if (mode == "lid_pcb_outside_clamp") {
    lid_pcb_outside_clamp(0);
} else if (mode == "lid_pcb_rear_travel") {
    // Just inside the rear stop clearance.
    lid_pcb_outside_clamp(pcb_rear_stop_clear - 0.01);
} else if (mode == "lid_pcb_rear_stop") {
    intersection() { pcb_rear_stops(); translate([0, pcb_rear_stop_clear + 0.05, 0]) asm_pcb(); }
} else if (mode == "lid_usb_clamp_off_shell") {
    usb_clamp_off_shell();
} else if (mode == "lid_usb_cable") {
    intersection() { lid_part(); usb_cable_fit_probe(); }
} else if (mode == "lid_usb_cable_shifted") {
    for (d = lid_seat_shifts)
        intersection() { translate([d[0], d[1], 0]) lid_part(); usb_cable_fit_probe(); }
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
} else if (mode == "lid_led_windows_closed") {
    difference() { led_window_probe(); lid_part(); }
} else if (mode == "battery_on_loadcell") {
    intersection() { asm_loadcell(); translate([0, 0, -0.05]) asm_battery(); }
} else if (mode == "loadcell_pcb") {
    intersection() { asm_loadcell(); asm_pcb(); }
} else if (mode == "loadcell_switch") {
    intersection() { asm_loadcell(); asm_switch(); }
} else if (mode == "battery_pcb") {
    intersection() { asm_battery(); asm_pcb(); }
} else if (mode == "battery_lift_pcb") {
    // Lifted against the hold-downs, the battery stays off the bottom parts.
    intersection() { translate([0, 0, battery_hold_down_clear + 0.05]) asm_battery(); asm_pcb(); }
} else if (mode == "battery_wires") {
    intersection() { asm_battery(); all_wire_probes(); }
} else if (mode == "switch_wires") {
    // The switch's own wires start at its rear face.
    intersection() { asm_switch(); union() { loadcell_wire_probe(); battery_wire_probe(); } }
} else if (mode == "pcb_wires") {
    // The routes end below the pads' own probes.
    intersection() { asm_pcb(); union() { loadcell_wire_probe(); battery_wire_probe(); switch_wire_probe(); } }
} else if (mode == "battery_switch") {
    intersection() { asm_battery(); asm_switch(); }
} else if (mode == "pcb_switch") {
    intersection() { asm_pcb(); asm_switch(); }
} else {
    assert(false, str("Unknown mode: ", mode));
}
