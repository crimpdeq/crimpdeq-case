//
// Fit coupon: the front bands of the main body and lid, in print layout.
// Print them before the full case to check the printer's tolerances on the
// switch grip, USB-C opening and cable pocket, PCB column, front notch pins,
// screw pilots and countersinks, LED windows and the lid lip, then screw the
// two together.
// Units: mm
//

use <case_main.scad>
use <case_lid.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

part = "main"; // "main" or "lid"

// Behind the switch and in front of the lid's battery hold-downs.
coupon_rear_y = battery_hold_down_y[0] - 1;
assert(coupon_rear_y > switch_rear_y + switch_clear,
    "The coupon must hold the whole switch cavity.");

module front_band() {
    box([-outer_end_x - 1, outer_end_x + 1], [outer_front_y - 1, coupon_rear_y], [-1, lid_top_z + 1]);
}

if (part == "main") {
    intersection() { main_part(); front_band(); }
} else if (part == "lid") {
    translate([0, 0, lid_top_z])
        rotate([180, 0, 0])
            intersection() { lid_part(); front_band(); }
} else {
    assert(false, str("Unknown part: ", part));
}
