include <MCAD/units/metric.scad>
use <MCAD/shapes/polyhole.scad>
use <MCAD/shapes/boxes.scad>

support_extrusion_length = 1900;
support_extrusion_width = 40;
support_extrusion_depth = 20;
support_tslot_positions = [10, 30];

cut_extrusion_length = 1900;
cut_extrusion_width = 40;
cut_extrusion_depth = 20;
cut_tslot_position = 10;

wall_thickness = 5;

jig_length = 50;

elevation = 11;
clearance = 0.2;

saw_thickness = 1.1;
saw_depth = 4;

$fs = 0.4;
$fa = 1;

mode = "preview";               // plate / preview / cutting / end

module tslot_screw ()
{
    // screw hole
    mirror (Z)
    translate ([0, 0, -epsilon])
    mcad_polyhole (d = 5.3, h = 100);

    // cap screw head
    mcad_polyhole (d = 8.6, h = 100);
}

module support_extrusion ()
{
    cube ([
            support_extrusion_length,
            support_extrusion_width,
            support_extrusion_depth
        ]);
}

module cut_extrusion ()
{
    cube ([
            cut_extrusion_length,
            cut_extrusion_width,
            cut_extrusion_depth
        ]);
}

module jig_screwholes ()
{
    for (tslot_pos = support_tslot_positions + [1, 1] * wall_thickness)
    for (l = [0.25, 0.75] * jig_length)
    translate ([l, tslot_pos, 5])
    tslot_screw ();

    for (i = [0.25, 0.75])
    translate ([i * jig_length, -epsilon, elevation + cut_tslot_position])
    rotate (90, X)
    tslot_screw ();
}

module mirror_if (condition, axis)
{
    if (condition)
    mirror (axis)
    children ();

    else
    children ();
}

module sideways_rounded_box (size, radius)
{
    mirror (Z)
    rotate (90, Y)
    mcad_rounded_box (size = [size[2], size[1], size[0]], radius = radius, sidesonly = true);
}

module end_jig ()
{
    jig_width = (max (support_extrusion_width, cut_extrusion_width) +
        clearance + wall_thickness * 2);
    jig_depth = elevation + cut_extrusion_depth;

    difference () {
        cube ([jig_length, jig_width, jig_depth]);

        translate ([wall_thickness, wall_thickness + clearance / 2, elevation])
        sideways_rounded_box (
            size = [
                jig_length,
                cut_extrusion_width + clearance,
                jig_depth
            ],
            radius = 2
        );

        jig_screwholes ();
    }
}

module cutting_jig ()
{
    jig_base_width = (max (support_extrusion_width, cut_extrusion_width) +
        clearance + wall_thickness * 2);
    jig_depth = elevation + cut_extrusion_depth + 10;

    jig_cross_arm_length = jig_base_width + 20;

    difference () {
        // base shape
        union () {
            cube ([jig_length, jig_base_width, jig_depth]);

            for (i = [1, -1])
            translate ([0, i < 0 ? jig_base_width : 0, 0])
            mirror_if (i < 0, Y)
            translate ([0, epsilon, 0])
            rotate (90, X)
            mirror (X)
            rotate (-90, Y)
            linear_extrude (height = jig_length)
            difference () {
                fillet_r = wall_thickness;

                square ([fillet_r, fillet_r + elevation]);

                translate ([fillet_r, fillet_r + elevation])
                circle (r = fillet_r);
            }
        }

        // cross arm
        translate ([-epsilon * 2, wall_thickness + clearance / 2, elevation])
        sideways_rounded_box (
            size = [
                jig_length + wall_thickness * 2,
                cut_extrusion_width + clearance,
                jig_depth
            ],
            radius = 2
        );

        jig_screwholes ();

        // saw cutout
        translate ([
                jig_length / 2 - (saw_thickness + clearance) / 2,
                -cut_extrusion_width * 2,
                elevation - saw_depth
            ])
        cube ([
                saw_thickness + clearance,
                cut_extrusion_width * 4,
                jig_depth
            ]);
    }
}

if (mode == "preview") {
    %support_extrusion ();
    %translate ([wall_thickness, 0, elevation + support_extrusion_depth])
    cut_extrusion ();

    translate ([0, -wall_thickness, support_extrusion_depth])
    end_jig ();

    translate ([250, -wall_thickness, support_extrusion_depth])
    cutting_jig ();

} else if (mode == "plate") {
    cutting_jig ();

    translate ([jig_length + 5, 0, 0])
    end_jig ();
} else if (mode == "cutting") {
    cutting_jig ();

} else {
    end_jig ();
}
