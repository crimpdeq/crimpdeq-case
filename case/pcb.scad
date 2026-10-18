//
// Revision 3 PCB with its component envelopes
// Units: mm
//

include <dimensions.scad>

render_fn = is_undef(render_fn) ? 64 : render_fn;
$fn = render_fn;

module pcb_rect_2d(r) {
    translate([r[0], r[2]])
        square([r[1] - r[0], r[3] - r[2]]);
}

// Board footprint minus the bare areas the case is allowed to touch.
module pcb_parts_2d(windows) {
    difference() {
        square([pcb_W, pcb_L], center = true);
        for (w = windows)
            pcb_rect_2d(w);
    }
}

// Origin: board center on its underside (KiCad F.Cu, toward the battery).
module pcb_model() {
    color("green")
        translate([0, 0, pcb_board_t / 2])
            cube([pcb_W, pcb_L, pcb_board_t], center = true);

    // F.Cu parts below the board; only the support windows are bare.
    color("darkgreen")
        translate([0, 0, -pcb_bottom_parts_h])
            linear_extrude(height = pcb_bottom_parts_h)
                pcb_parts_2d(pcb_support_windows);

    color("silver")
        translate([usb_x, usb_y, -usb_h / 2])
            cube([usb_w, usb_d, usb_h], center = true);

    // B.Cu parts face the lid; only the clamp windows are bare.
    translate([0, 0, pcb_board_t]) {
        color("darkgreen")
            linear_extrude(height = pcb_top_parts_h)
                pcb_parts_2d(pcb_clamp_windows);

        color("lightgray")
            linear_extrude(height = pcb_module_h)
                pcb_rect_2d(pcb_module_rect);

        translate([status_led_x, status_led_y, status_led_h / 2])
            color("yellow")
                cube([status_led_w, status_led_l, status_led_h], center = true);

        translate([rgb_led_x, rgb_led_y, rgb_led_h / 2])
            color("white")
                cube([rgb_led_w, rgb_led_l, rgb_led_h], center = true);
    }
}

pcb_model();
