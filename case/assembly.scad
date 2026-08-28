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

loadcell_y_max = lc_W / 2;
switch_top_z = switch_z + switch_h / 2;

assert(switch_terminal_y_max <= -loadcell_y_max,
    str("Switch terminals overlap the load cell by ",
        switch_terminal_y_max + loadcell_y_max, " mm (Y)."));
assert(switch_top_z <= pcb_bottom_z,
    str("Switch overlaps PCB by ", switch_top_z - pcb_bottom_z, " mm (Z)."));

module loadcell_model() {
    color("silver")
        linear_extrude(height = lc_T, center = true)
            loadcell_2d();
}

module switch_model(show_travel = false) {
    // Switch-local +Y points through the actuator. Rotate it toward case -Y
    // while keeping the snap-in model and raw component dimensions.
    rotate([0, 0, 180]) {
        color("silver")
            cube([switch_w, switch_d, switch_h], center = true);

        color("black")
            translate([
                show_travel ? 0 : -switch_travel / 2,
                switch_d / 2 + switch_actuator_d / 2,
                0
            ])
                cube([
                    switch_actuator_w + (show_travel ? switch_travel : 0),
                    switch_actuator_d,
                    switch_actuator_h
                ], center = true);

        color("silver")
            for (pin_x = [-switch_terminal_pitch, 0, switch_terminal_pitch])
                translate([
                    pin_x,
                    -switch_d / 2 - switch_terminal_installed_d / 2,
                    0
                ])
                    cube([
                        switch_terminal_w,
                        switch_terminal_installed_d,
                        switch_terminal_h
                    ], center = true);
    }
}

module full_assembly(show_pcb = true, show_service_keepouts = false) {
    translate([0, 0, loadcell_center_z])
        loadcell_model();

    // Battery laying flat on top of the load cell.
    translate([0, battery_y_offset, battery_center_z])
        battery_model(rounded = true);

    if (show_pcb)
        // PCB laying flat on top of the battery.
        translate([0, pcb_y_offset, pcb_center_z])
            pcb_model(show_usb = true);

    if (show_pcb && show_service_keepouts)
        translate([0, pcb_y_offset, pcb_center_z])
            color([1, 0.4, 0, 0.35])
                pcb_service_keepouts();

    // Compact slide switch inside the enclosure.
    translate([switch_x, switch_y, switch_z])
        switch_model();
}

full_assembly();
