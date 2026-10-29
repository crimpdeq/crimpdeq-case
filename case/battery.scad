//
// Battery model (envelope of the cell and its protection board)
// Units: mm
//

include <dimensions.scad>

module battery_model() {
    color("gray")
        cube([bat_W, bat_L, bat_T], center = true);
}

battery_model();
