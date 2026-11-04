//
// Crimpdeq assembly: load cell + battery + PCB
// Units: mm
//

use <load_cell.scad>
use <battery.scad>
use <pcb.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

module loadcell_model() {
    color("silver")
        linear_extrude(height = lc_T, center = true)
            loadcell_2d();
    color("white")
        translate([0, 0, lc_T / 2])
            loadcell_gauge_cover();
}

module switch_model() {
    color("red")
        switch_body();
}

module full_assembly(show_pcb = true) {
    translate([0, 0, loadcell_center_z])
        loadcell_model();

    // Battery laying flat on top of the load cell.
    translate([0, battery_y_offset, battery_bottom_z + bat_T / 2])
        battery_model(rounded = true);

    if (show_pcb)
        // PCB laying flat on top of the battery.
        translate([0, pcb_y_offset, pcb_board_bottom_z])
            pcb_model();

    switch_model();
}

full_assembly();
