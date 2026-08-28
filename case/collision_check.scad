// Collision/overlap checks for enclosure and assembly parts.
// Use with: openscad -D 'mode="main_lid"' -o /tmp/out.stl case/collision_check.scad

use <case_main.scad>
use <case_lid.scad>
use <load_cell.scad>
use <battery.scad>
use <pcb.scad>
use <assembly.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 24 : render_fn;
$fn = render_fn;

// Override from CLI with -D 'mode="..."'
mode = "main_lid";

module asm_loadcell() {
    translate([0, 0, loadcell_center_z])
        linear_extrude(height = lc_T, center = true)
            loadcell_2d();
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

module carabiner_eye_probe(x_sign) {
    // Keep the fit probe just inside the nominal cutter profile. Exact,
    // coincident OpenSCAD boundaries otherwise produce zero-volume contacts.
    translate([0, 0, loadcell_center_z - 50])
        linear_extrude(height = 100, center = false)
            offset(delta = -0.05)
                loadcell_eye_access_2d(x_sign);
}

module side_channel_closure_probe(x_sign) {
    probe_x = x_sign * (case_inner_x_half + 1.5);
    translate([probe_x, 15, loadcell_top_z + 4])
        cube([1, 2, 2], center = true);
}

module lid_eye_wall_tip_probe(x_sign, y_sign) {
    probe_x = x_sign * (lc_L / 2 - 0.2);
    probe_y = y_sign * (
        carabiner_side_entry_w / 2 + eye_tunnel_wall_t / 2
    );
    probe_z = loadcell_top_z + loadcell_channel_clear_z + 0.6;

    translate([probe_x, probe_y, probe_z])
        cube([0.4, 0.4, 0.4], center = true);
}

module loadcell_corner_guard_probe(x_sign, y_sign) {
    translate([
        x_sign * (lc_L / 2 + loadcell_guard_wall_t / 2),
        y_sign * (lc_W / 2 + loadcell_guard_wall_t / 2),
        loadcell_center_z
    ])
        cube([0.6, 0.6, 0.6], center = true);
}

module asm_battery() {
    translate([0, battery_y_offset, loadcell_top_z + loadcell_to_battery_gap + bat_T / 2])
        battery_model(rounded = true);
}

module asm_pcb() {
    translate([0, pcb_y_offset, loadcell_top_z + loadcell_to_battery_gap + bat_T + battery_to_pcb_gap + pcb_T / 2])
        pcb_model(show_usb = true);
}

module asm_switch() {
    translate([switch_x, switch_y, switch_z])
        switch_model(show_travel = true);
}

module asm_switch_body() {
    translate([switch_x, switch_y, switch_z])
        cube([switch_w, switch_d, switch_h], center = true);
}

module led_sightline_probe(led_x, led_y, d = 1.0) {
    translate([led_x, pcb_y_offset + led_y, pcb_top_z - 0.1])
        cylinder(d = d, h = top_clear + 3.4, center = false);
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
    // Move beyond coincident CSG boundaries so a zero-area contact is not
    // misreported as a solid intersection by OpenSCAD.
    intersection() { main_part(); translate([0, 0, 0.02]) lid_part(); }
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
} else if (mode == "guard_corner_x_neg_y_neg") {
    intersection() {
        main_part();
        loadcell_corner_guard_probe(-1, -1);
    }
} else if (mode == "guard_corner_x_neg_y_pos") {
    intersection() {
        main_part();
        loadcell_corner_guard_probe(-1, 1);
    }
} else if (mode == "guard_corner_x_pos_y_neg") {
    intersection() {
        main_part();
        loadcell_corner_guard_probe(1, -1);
    }
} else if (mode == "guard_corner_x_pos_y_pos") {
    intersection() {
        main_part();
        loadcell_corner_guard_probe(1, 1);
    }
} else if (mode == "main_notch_retention_y_neg") {
    intersection() { notch_pins(); translate([0, -0.15, 0]) asm_loadcell(); }
} else if (mode == "main_notch_retention_y_pos") {
    intersection() { notch_pins(); translate([0, 0.15, 0]) asm_loadcell(); }
} else if (mode == "main_loadcell_eps_z_plus") {
    intersection() { main_part(); translate([0, 0, 0.05]) asm_loadcell(); }
} else if (mode == "main_battery") {
    intersection() { main_part(); asm_battery(); }
} else if (mode == "main_pcb") {
    intersection() { main_part(); asm_pcb(); }
} else if (mode == "main_pcb_eps_y_plus") {
    intersection() { main_part(); translate([0, 0.05, 0]) asm_pcb(); }
} else if (mode == "main_pcb_eps_yz_plus") {
    intersection() { main_part(); translate([0, 0.05, 0.05]) asm_pcb(); }
} else if (mode == "main_switch") {
    intersection() { main_part(); asm_switch(); }
} else if (mode == "main_switch_snap_retention") {
    intersection() {
        switch_snap_hooks();
        translate([0, 0, switch_fit_clear_top + 0.05])
            asm_switch_body();
    }
} else if (mode == "main_usb_cable") {
    intersection() { main_part(); usb_cable_fit_probe(); }
} else if (mode == "lid_components") {
    intersection() { lid_part(); asm_all(); }
} else if (mode == "lid_loadcell") {
    intersection() { lid_part(); asm_loadcell(); }
} else if (mode == "lid_eye_access_x_neg") {
    intersection() { lid_part(); carabiner_eye_probe(-1); }
} else if (mode == "lid_eye_access_x_pos") {
    intersection() { lid_part(); carabiner_eye_probe(1); }
} else if (mode == "lid_eye_wall_tip_x_neg_y_neg") {
    intersection() { lid_part(); lid_eye_wall_tip_probe(-1, -1); }
} else if (mode == "lid_eye_wall_tip_x_neg_y_pos") {
    intersection() { lid_part(); lid_eye_wall_tip_probe(-1, 1); }
} else if (mode == "lid_eye_wall_tip_x_pos_y_neg") {
    intersection() { lid_part(); lid_eye_wall_tip_probe(1, -1); }
} else if (mode == "lid_eye_wall_tip_x_pos_y_pos") {
    intersection() { lid_part(); lid_eye_wall_tip_probe(1, 1); }
} else if (mode == "lid_channel_closure_x_neg") {
    intersection() { lid_part(); side_channel_closure_probe(-1); }
} else if (mode == "lid_channel_closure_x_pos") {
    intersection() { lid_part(); side_channel_closure_probe(1); }
} else if (mode == "lid_battery") {
    intersection() { lid_part(); asm_battery(); }
} else if (mode == "lid_pcb") {
    intersection() { lid_part(); asm_pcb(); }
} else if (mode == "lid_pcb_eps_z_plus") {
    intersection() { lid_part(); translate([0, 0, 0.15]) asm_pcb(); }
} else if (mode == "lid_switch") {
    intersection() { lid_part(); asm_switch(); }
} else if (mode == "lid_screw_shank_fit") {
    intersection() { lid_part(); lid_screw_shank_fit_probe(); }
} else if (mode == "lid_screw_head_fit") {
    intersection() { lid_part(); lid_screw_head_fit_probe(); }
} else if (mode == "lid_status_led_sightline") {
    intersection() {
        lid_part();
        led_sightline_probe(status_led_x, status_led_y, max(status_led_w, status_led_l));
    }
} else if (mode == "lid_rgb_led_sightline") {
    intersection() {
        lid_part();
        led_sightline_probe(rgb_led_x, rgb_led_y, max(rgb_led_w, rgb_led_l));
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
} else if (mode == "battery_switch") {
    intersection() { asm_battery(); asm_switch(); }
} else if (mode == "pcb_switch") {
    intersection() { asm_pcb(); asm_switch(); }
} else {
    echo(str("Unknown mode: ", mode));
}
