//
// Battery model (simple envelope)
// Units: mm
//

include <dimensions.scad>

render_fn = is_undef(render_fn) ? 64 : render_fn;
$fn = render_fn;

module battery_lead_keepout() {
    translate([0, bat_L / 2 + bat_lead_exit_l / 2, 0])
        cube([bat_lead_pair_w, bat_lead_exit_l, bat_lead_d], center = true);
}

module battery_keepout_model(include_leads = true) {
    color("gray")
        cube([bat_W, bat_L, bat_T], center = true);

    if (include_leads)
        color("orange")
            battery_lead_keepout();
}

module battery_model(rounded = true, show_leads = true) {
    if (!rounded || bat_corner_r <= 0) {
        battery_keepout_model(include_leads = show_leads);
    } else {
        // Visual pouch plus the less-rounded protection-board end. Collision
        // checks use battery_keepout_model() so rounding cannot hide a clash.
        color("gray")
            translate([0, -bat_pcm_L / 2, 0])
                minkowski() {
                    cube([
                        bat_W - 2 * bat_corner_r,
                        bat_pouch_L - 2 * bat_corner_r,
                        bat_T - 2 * bat_corner_r
                    ], center = true);
                    sphere(r = bat_corner_r);
                }

        color("darkslategray")
            translate([0, bat_pouch_L / 2, 0])
                cube([bat_pcm_W, bat_pcm_L, bat_pcm_T], center = true);

        if (show_leads)
            color("orange")
                battery_lead_keepout();
    }
}

// Render battery
battery_model(rounded=true);
