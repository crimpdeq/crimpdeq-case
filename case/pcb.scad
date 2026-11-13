//
// crimpdeq-tscircuit PCB with its component envelopes
// Units: mm
//

include <dimensions.scad>

render_fn = is_undef(render_fn) ? 64 : render_fn;
$fn = render_fn;

module pcb_rect_2d(r) {
    translate([r[0], r[2]])
        square([r[1] - r[0], r[3] - r[2]]);
}

module pcb_outline_2d() {
    offset(r = pcb_corner_r)
        square([pcb_W - 2 * pcb_corner_r, pcb_L - 2 * pcb_corner_r], center = true);
}

// Origin: board center on its underside.
module pcb_model() {
    color("green")
        linear_extrude(height = pcb_board_t)
            pcb_outline_2d();

    // Bottom parts; only the support windows are bare.
    color("darkgreen")
        translate([0, 0, -pcb_bottom_parts_h])
            linear_extrude(height = pcb_bottom_parts_h)
                difference() {
                    pcb_outline_2d();
                    for (w = pcb_support_windows)
                        pcb_rect_2d(w);
                }

    translate([0, 0, pcb_board_t]) {
        color("darkgreen")
            linear_extrude(height = pcb_top_parts_h)
                pcb_outline_2d();

        color("lightgray")
            linear_extrude(height = pcb_module_h)
                pcb_rect_2d(pcb_module_rect);

        // Overhangs the front edge.
        color("silver")
            linear_extrude(height = usb_h)
                pcb_rect_2d(usb_rect);

        translate([status_led_x, status_led_y, status_led_h / 2])
            color("yellow")
                cube([status_led_w, status_led_l, status_led_h], center = true);

        translate([rgb_led_x, rgb_led_y, rgb_led_h / 2])
            color("white")
                cube([rgb_led_w, rgb_led_l, rgb_led_h], center = true);
    }
}

pcb_model();
