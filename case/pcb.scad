//
// PCB model with USB-C connector
// Units: mm
//

include <dimensions.scad>

render_fn = is_undef(render_fn) ? 64 : render_fn;
$fn = render_fn;

// LED envelopes (visual only; PCB thickness already includes components)
status_led_w = 1.6;
status_led_l = 0.8;
status_led_h = 0.8;
status_led_rot_z = 90;

rgb_led_w = 5.0;
rgb_led_l = 5.0;
rgb_led_h = 1.6;
rgb_led_rot_z = 0;

module pcb_model(show_usb=true) {
    assert(usb_inset >= 0 && usb_inset <= pcb_T, "usb_inset must be between 0 and pcb_T");
    assert(status_led_h <= pcb_T && rgb_led_h <= pcb_T,
        "LED heights must fit within pcb_T (PCB thickness already includes LEDs)");

    usb_x = 0;
    usb_y = pcb_L/2 - usb_d/2;               // flush to PCB edge (no overhang)
    usb_z = pcb_T/2 + usb_h/2 - usb_inset;   // recessed into PCB by usb_inset

    pcb_usb_pocket_z = pcb_T/2 - usb_inset/2;
    // LEDs are embedded in the PCB thickness (must not protrude above the PCB top face).
    status_led_z = pcb_T/2 - status_led_h/2;
    rgb_led_z = pcb_T/2 - rgb_led_h/2;

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

        // Status LED envelope embedded within the PCB thickness.
        translate([status_led_x, status_led_y, status_led_z])
            color("yellow")
                rotate([0, 0, status_led_rot_z])
                    cube([status_led_w, status_led_l, status_led_h], center = true);

        // WS2812B RGB LED envelope embedded within the PCB thickness.
        translate([rgb_led_x, rgb_led_y, rgb_led_z])
            color("white")
                rotate([0, 0, rgb_led_rot_z])
                    cube([rgb_led_w, rgb_led_l, rgb_led_h], center = true);
    }
}

// Render PCB
pcb_model();
