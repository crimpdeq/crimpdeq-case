//
// Screw test piece: one corner of the main body and of the lid, cut from the
// real parts round a screw, to check that M2.5x10 screws drive, seat and hold
// before printing the whole case. Print it with the case settings.
//

use <case_main.scad>
use <case_lid.scad>
include <placement.scad>

render_fn = is_undef(render_fn) ? 96 : render_fn;
$fn = render_fn;

part = "both"; // "main", "lid" or "both"

test_half = 7; // round the screw center
test_gap = 5; // between the two pieces on the bed
test_screw = screw_centers[0]; // rear left, clear of the switch and USB-C

module test_column(c) {
    box(span(c[0], test_half), span(c[1], test_half), [-1, 100]);
}

// Both print layouts keep X; the lid's flip about X mirrors Y, so its piece
// is cut at the mirrored corner and moved back beside the main one.
module main_test_piece() {
    intersection() {
        main_part_print_layout();
        test_column(test_screw);
    }
}

module lid_test_piece() {
    translate([2 * test_half + test_gap, 2 * test_screw[1], 0])
        intersection() {
            lid_part_print_layout();
            test_column([test_screw[0], -test_screw[1]]);
        }
}

if (part == "main" || part == "both") main_test_piece();
if (part == "lid" || part == "both") lid_test_piece();
