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
        rotate([0, switch_rot_y, 0])
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
    intersection() { main_part(); translate([0, 0, 0.01]) lid_part(); }
} else if (mode == "main_lid_eps_down") {
    intersection() { main_part(); translate([0, 0, -0.05]) lid_part(); }
} else if (mode == "main_components") {
    intersection() { main_part(); asm_all(); }
} else if (mode == "main_loadcell") {
    intersection() { main_part(); asm_loadcell(); }
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
} else if (mode == "main_usb_cable") {
    intersection() { main_part(); usb_cable_fit_probe(); }
} else if (mode == "lid_components") {
    intersection() { lid_part(); asm_all(); }
} else if (mode == "lid_loadcell") {
    intersection() { lid_part(); asm_loadcell(); }
} else if (mode == "lid_battery") {
    intersection() { lid_part(); asm_battery(); }
} else if (mode == "lid_pcb") {
    intersection() { lid_part(); asm_pcb(); }
} else if (mode == "lid_switch") {
    intersection() { lid_part(); asm_switch(); }
} else if (mode == "lid_screw_shank_fit") {
    intersection() { lid_part(); lid_screw_shank_fit_probe(); }
} else if (mode == "lid_screw_head_fit") {
    intersection() { lid_part(); lid_screw_head_fit_probe(); }
} else if (mode == "lid_status_led_sightline") {
    intersection() { lid_part(); led_sightline_probe(status_led_x, status_led_y); }
} else if (mode == "lid_rgb_led_sightline") {
    intersection() { lid_part(); led_sightline_probe(rgb_led_x, rgb_led_y); }
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
