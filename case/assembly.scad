//
// Crimpdeq assembly: load cell, battery, PCB and switch in case coordinates
// Units: mm
//

use <load_cell.scad>
use <battery.scad>
use <pcb.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

module asm_loadcell() {
    translate([0, 0, loadcell_bottom_z]) {
        linear_extrude(height = lc_T)
            loadcell_2d();
        loadcell_gauge_cover();
    }
}

module asm_battery() {
    translate([0, battery_y, battery_bottom_z + bat_T / 2])
        battery_model();
}

module asm_pcb() {
    translate([0, pcb_y, pcb_board_bottom_z])
        pcb_model();
}

// From the outer front face to the end of the solder joints.
module asm_switch(inset = 0) {
    box([switch_x - switch_w / 2 + inset, switch_x + switch_w / 2 - inset],
        [outer_front_y, switch_rear_y],
        [switch_z - switch_h / 2 + inset, switch_z + switch_h / 2 - inset]);
}

// Bezel and rocker in front of the outer face, up to the rocker's raised
// end, stopping gap short of the face.
module asm_switch_front(gap = 0) {
    box(span(switch_x, switch_bezel_half_w), [outer_front_y - switch_rocker_h, outer_front_y - gap],
        span(switch_z, switch_h / 2 + switch_flange));
}

module full_assembly(show_pcb = true) {
    color("silver") asm_loadcell();
    asm_battery();
    if (show_pcb)
        asm_pcb();
    color("red") {
        asm_switch();
        asm_switch_front();
    }
}

full_assembly();
