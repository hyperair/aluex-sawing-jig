include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/array/along_curve.scad>

slot_size = 5;
length = 20;
wall_thickness = 5;

screwhole_size = slot_size + 0.3;

profile_width = 20;
clearance = 1;

profile_width_multiplier = 2;
profile_depth_multiplier = 1;

aluex_width = profile_width * profile_width_multiplier;
aluex_depth = profile_width * profile_depth_multiplier - clearance;

slot_depth = 1;

module slot ()
{
    linear_extrude (height = slot_depth)
    square ([slot_size, length], center = true);
}

module screwhole (center = true)
{
    translate ([0, 0, center ? -500 : 0])
    mcad_polyhole (d = screwhole_size, h = 1000);
}

module place_horizontal_slot ()
{
    total_width = (profile_width_multiplier - 1) * profile_width;

    mcad_linear_multiply (no = profile_width_multiplier,
        separation = profile_width, axis = X)
    translate ([-total_width / 2, 0, 0])
    children ();
}

module place_vertical_slot ()
{
    mcad_linear_multiply (no = profile_depth_multiplier,
        separation = profile_width, axis = Z)
    translate ([0, 0, wall_thickness + profile_width / 2])
    children ();
}

module sawing_jig ()
{
    difference () {
        union () {
            difference () {
                linear_extrude (height = aluex_depth + wall_thickness)
                square ([aluex_width + wall_thickness * 2, length], center = true);

                translate ([0, 0, wall_thickness])
                linear_extrude (height = aluex_depth + epsilon)
                square ([aluex_width, length + epsilon * 2], center = true);
            }

            place_horizontal_slot ()
            translate ([0, 0, wall_thickness - epsilon])
            slot ();
        }

        place_horizontal_slot ()
        translate ([0, 0, -epsilon])
        screwhole ();

        place_vertical_slot ()
        rotate (90, Y)
        translate ([0, 0, -5000])
        mcad_polyhole (d = 5.3, h = 10000);
    }
}


sawing_jig ();
