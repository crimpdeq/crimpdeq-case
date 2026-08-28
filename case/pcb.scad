//
// Revision 3 PCB model with USB-C connector and both visible LEDs
// Units: mm
//

include <dimensions.scad>

render_fn = is_undef(render_fn) ? 64 : render_fn;
$fn = render_fn;

module pcb_solder_keepout_model() {
    translate([
        -pcb_W / 2 + pcb_solder_keepout_w / 2,
        0,
        -pcb_T / 2 - pcb_solder_keepout_h / 2
    ])
        cube([
            pcb_solder_keepout_w,
            pcb_solder_keepout_l,
            pcb_solder_keepout_h
        ], center = true);
}

module pcb_wire_exit_keepout_model() {
    translate([
        -pcb_W / 2 + pcb_wire_exit_l / 2,
        0,
        -pcb_T / 2 - pcb_wire_race_d / 2
    ])
        cube([
            pcb_wire_exit_l,
            pcb_solder_keepout_l,
            pcb_wire_race_d
        ], center = true);
}

module pcb_service_keepouts() {
    pcb_solder_keepout_model();
    pcb_wire_exit_keepout_model();
}

module pcb_model(show_usb=true) {
    assert(usb_inset >= 0 && usb_inset <= pcb_T, "usb_inset must be between 0 and pcb_T");
    assert(status_led_h <= pcb_T, "Status LED must fit within the PCB assembly envelope");
    assert(rgb_led_h <= pcb_T, "RGB LED must fit within the PCB assembly envelope");

    // The PCB is bottom-side up: the LEDs face +Z (the lid) and the top-side
    // USB connector sits toward -Z.
    usb_z = -pcb_T / 2 - usb_h / 2 + usb_inset;

    pcb_usb_pocket_z = -pcb_T / 2 + usb_inset / 2;
    status_led_z = pcb_T / 2 - status_led_h / 2;
    rgb_led_z = pcb_T / 2 - rgb_led_h / 2;

    union() {

        // PCB body (centered)
        color("green")
            difference() {
                cube([pcb_W, pcb_L, pcb_T], center=true);

                if (show_usb && usb_inset > 0) {
                    translate([usb_x, usb_y, pcb_usb_pocket_z])
                        cube([usb_w, usb_d, usb_inset + 0.02], center=true);
                }
            }

        // USB-C connector block
        if (show_usb) {
            translate([
                usb_x,
                usb_y,
                usb_z
            ])
            color("silver")
                cube([usb_w, usb_d, usb_h], center=true);
        }

        // Bottom-side LEDs face the lid after installation.
        translate([status_led_x, status_led_y, status_led_z])
            color("yellow")
                cube([status_led_w, status_led_l, status_led_h], center = true);

        translate([rgb_led_x, rgb_led_y, rgb_led_z])
            color("white")
                cube([rgb_led_w, rgb_led_l, rgb_led_h], center = true);
    }
}

// Render PCB
pcb_model();
