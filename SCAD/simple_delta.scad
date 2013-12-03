include <fasteners.scad>
include <bearings.scad>
include <NEMA17.scad>
include <cog.scad>
include <Triangles.scad>
include <hotends.scad>
include <cog.scad>

// [w, l, t] = [y, x, z]
$fn = 48;

render_part(8);

magnet_mounts = 1;

module render_part(part_to_render) {
	if (part_to_render == 1) end_motor();

	if (part_to_render == 2) end_idler();

	if (part_to_render == 3) carriage(dogged = 0, magnet_mounts = magnet_mounts);

	if (part_to_render == 4) effector(dalekify = 0, magnet_mounts = magnet_mounts);

	if (part_to_render == 5) hook();

	if (part_to_render == 6) power_entry();

	if (part_to_render == 7) intermediate();

	if (part_to_render == 8) stage_effector(magnet_mounts = 1);

	if (part_to_render == 9) linking_board_template();

	if (part_to_render == 10) assembly();

	if (part_to_render == 11) camera_carriage();

}

// printer dims
r_printer = 175; // radius of the printer

// belt, pulley and idler dims
od_idler = od_608; // idler OD
id_idler = id_608; // idler id
h_idler = h_608; // thickness of idler
h_idler_washer = h_M8_washer; // idelr bearing washer
w_belt = 6; // width of the belt (not used)
d_pulley = 16.9; // diameter of the pulley (used to center idler)

// guide rod and clamp dims
cc_guides = 60; // center-to-center of the guide rods
d_guides = 8.5; // diameter of the guide rods
pad_clamp = 8; // additional material around guide rods
gap_clamp = 2; // opening for clamp

// following for tabs on either side of clamp to which linking boards are attached
// the radius of the delta measured from the center of the guide rods to the center of the triangle
// as drawn here, the tangent is parallel to the x-axis and the guide rod centers lie on y=0
cc_mount = 75; // tangential distance from center of guide rods to side mount pivot point
w_mount = 12; // thickness of the tabs the boards making up the triangle sides will attach to
l_mount = 40; // length of said tabs
cc_mount_holes = 16;
l_base_mount = l_mount;
w_base_mount = 14.1;
t_base_mount = 8.0;
r_base_mount = 3;
l_mount_slot = 2; // length of the slot for mounting screw holes

// various radii and chord lengths
a_arc_guides = asin(cc_guides / 2 / r_printer); // angle of arc between guide rods at r_printer 
a_sep_guides = 120 - 2 * a_arc_guides; // angle of arc between nearest rods on neighboring towers
l_chord_guides = 2 * r_printer * sin(a_sep_guides / 2); // length of chord between nearest rods on neighboring towers
r_tower_center = pow(pow(r_printer, 2) - pow(cc_guides / 2, 2), 0.5); // radius to centerline of tower
r_mount_pivot = pow(pow(r_tower_center, 2) + pow(cc_mount / 2, 2), 0.5); // radius to pivot point of apex mounts
a_arc_mount = asin(cc_mount / 2 / r_mount_pivot);// angle subtended by arc struck between tower centerline and mount pivot point
a_sep_mounts = 120 - 2 * a_arc_mount; // angle subtended by arc struck between mount pivot points between adjacent towers
l_chord_pivots = 2 * r_mount_pivot * sin(a_sep_mounts / 2); // chord length between adjacent moint pivot points

// remove enough material from mount so that a logical length board can be cut to ensure adjacent mount pivot point chord lengths will yield a printer having r_printer
l_brd = floor(l_chord_pivots / 10) * 10 - l_mount / 2; // length of the board that will be mounted between the apexs to yield r_printer
l_pad_mount = (l_chord_pivots - l_brd) / 2;
l_boss_mount = l_mount - l_pad_mount;

l_idler_relief = cc_guides - d_guides - pad_clamp;
w_idler_relief = 2 * (h_idler + h_idler_washer) + 1;
r_idler_relief = 2; // radius of the relief inside the apex
l_clamp = cc_guides + d_guides + pad_clamp;
w_clamp = w_idler_relief + pad_clamp + 8;
t_clamp = l_NEMA17;//od_idler + 6;

// ball joint mount dimensions
l_ball_joint = 7 + h_M3_washer;
d_ball_joint = 6;
d_ball_socket = 10; // diameter of the ball joint socket
d_mount_ball_joint = d_ball_joint + 4;
l_mount_ball_joint = l_ball_joint + 6;
offset_mount = 3;

// effector dims
l_effector = 60; // this needs to be played with to keep the fan from hitting the tie rods
H_effector = equilateral_height_from_base(l_effector);
r_effector = l_effector * tan(30) / 2 + (magnet_mounts == 1) ? d_mount_ball_joint : 29;
t_effector = 6;
h_triangle_inner = H_effector + 12;
r_triangle_middle = equilateral_base_from_height(h_triangle_inner) * tan(30) / 2;
d_175_sheath = 4.8;
175_bowden = [d_M4_nut, h_M4_nut, d_175_sheath];

// carriage dims:
w_carriage_web = 4;
t_carriage = l_lm8uu + 4;
carriage_offset = 18; // distance from center of guide rods to center of ball mount pivot
y_offset_endstop = -od_lm8uu / 2 - 8;
l_limit_switch = 24;
w_limit_switch = 6;
t_limit_switch = 14;

l_guide_rods = 300; // length of the guide rods - only used for assembly

// magnetic ball joint dims
d_ball_bearing = 3 * 25.4 / 8;
id_magnet = 15 * 25.4 / 64;
od_magnet = 3 * 25.4 / 8;
h_magnet = 25.4 / 8;
r_bearing_seated = pow(pow(d_ball_bearing / 2, 2) - pow(id_magnet / 2, 2), 0.5); // depth ball bearing sinks into magnet id
h_carriage_magnet_mount = 9;
h_effector_magnet_mount = 10;
r_pad_carriage_magnet_mount = 2;
r_pad_effector_magnet_mount = 1.5;

// center-to-center of tie rod pivots
tie_rod_length = 250;
tie_rod_angle = acos((r_printer - r_effector - carriage_offset) / tie_rod_length);

echo(str("Distance between nearest neighbor guide rods = ", l_chord_guides, "mm"));
echo(str("Radius to centerline of tower = ", r_tower_center, "mm"));
echo(str("Radius to mount tab pivot = ", r_mount_pivot, "mm"));
echo(str("Distance between adjacent mount pivot points = ", l_chord_pivots, "mm"));
echo(str("Effector offset = ", r_effector, "mm"));
echo(str("Carriage offset = ", carriage_offset, "mm"));
echo(str("Length of linking board to yield printer radius of ", r_printer, "mm  = ", l_brd, "mm"));
echo(str("Linking board tab thickness = ", t_clamp, "mm"));
echo(str("Linking board hole c-c = ", cc_mount_holes, "mm"));
echo(str("Linking board hole offset from end = ", floor(l_pad_mount / 2), "mm"));
echo(str("Linking board-tab overlap = ", l_boss_mount, "mm"));
echo(str("Radius of base plate = ", ceil(r_printer - d_guides / 2 - 1), "mm"));
echo(str("Tie rod angle at (0, 0, 0) = ", tie_rod_angle));
echo(str("Effector tie rod c-c = ", l_effector, " mm"));

module mount_body(
	l_base_mount,
	w_base_mount,
	t_base_mount,
	r_base_mount,
	l_slot = 0) {

	difference() {
		hull() {
			cylinder(r = w_mount / 2, h = t_clamp, center = true);

			translate([0, -l_mount + w_mount / 2, 0])
				cube([w_mount, w_mount, t_clamp], center = true);
		}

		// relief for board between apexs
		translate([w_mount - 3, -l_mount / 2 - l_pad_mount, 0])
			cube([w_mount, l_mount, t_clamp + 2], center = true);

		// screw holes to mount linking board
		translate([0, -l_mount / 2 - l_pad_mount + floor(l_pad_mount / 2), 0])
			for (i = [-1, 1])
				for (j = [-1, 1])
					translate([0, j * cc_mount_holes / 2, i * cc_mount_holes / 2])
						rotate([0, 90, 0])
								if (l_slot > 0)
									hull()
										for (k = [-1, 1])
											translate([0, k * l_slot / 2, 0])
												cylinder(r = d_M3_screw / 2, h = w_mount + 2, center = true);
								else
									cylinder(r = d_M3_screw / 2, h = w_mount + 2, center = true);
	}
}

module mount(
	l_linking_board_slot) {
	union() {
		mount_body(
			l_base_mount = l_base_mount,
			w_base_mount = w_base_mount,
			t_base_mount = t_base_mount,
			r_base_mount = r_base_mount,
			l_slot = l_linking_board_slot);

			// boss for mounting base plate
			translate([-w_mount / 2 - w_base_mount / 2 + r_base_mount, -l_base_mount / 2, (t_base_mount - t_clamp) / 2])
				difference() {
					round_box(
						w_base_mount,
						l_base_mount,
						t_base_mount,
						radius = r_base_mount);

					translate([-w_base_mount / 2 + 4, -l_base_mount / 2 + 4, 0])
						cylinder(r = d_M3_screw / 2, h = t_base_mount + 1, center = true);

					translate([-w_base_mount / 2 + 4, 0, 0])
						cylinder(r = d_M3_screw / 2, h = t_base_mount + 1, center = true);
				}
echo(str("x_base_holes = ",-w_mount / 2 - w_base_mount / 2 + r_base_mount + (-w_base_mount / 2 + 4)));
echo(str("y_base_hole1 = ",-l_base_mount / 2 + (-l_base_mount / 2 + 4)));
echo(str("y_base_hole2 = ",-l_base_mount / 2));
	}
}


module apex(
	l_linking_board_slot) {
	hull() {
		for (i=[-1,1])
			translate([i * (cc_mount - w_mount) / 2, 0, 0])
				cylinder(r = w_mount / 2, h = t_clamp, center = true);
	}

	for (i = [-1, 1])
		translate([i * cc_mount / 2, 0, 0])
			rotate([0, 0, i * 30])
				mirror([(i < 0) ? i : 0, 0, 0])
					mount(l_linking_board_slot);
}

module round_box(
	length,
	width,
	thickness,
	radius = 4) {
	hull() {
		for (i = [-1, 1]) {
			translate([i * (length / 2 - radius), width / 2 - radius, 0])
				cylinder(r = radius, h = thickness, center = true);

			translate([i * (length / 2 - radius), -(width / 2 - radius), 0])
				cylinder(r = radius, h = thickness, center = true);
		}
	}
}

module rod_clamp_relief(thickness, z_offset_guides) {
	union() {
		// clamp screws
		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([0, (w_idler_relief + d_M3_nut) / 2 - 1, i * t_clamp / 4 - (thickness - t_clamp) / 2])
					rotate([0, 90, 0]) {
						translate([0, 0, j * (l_clamp / 2 + 4.5)])
							cylinder(r = d_M3_washer / 2 + 1, h = 10, center = true);

						cylinder(r = d_M3_screw / 2, h = l_clamp + 1, center = true);
					}

		// guide rod holes and slots for clamp
		for (i = [-1, 1])
			translate([i * cc_guides / 2, 0, 0]) {
				translate([0, 0, z_offset_guides])
					cylinder(r = d_guides / 2, h = thickness, center = true);

				translate([0, w_clamp / 2, 0])
					cube([gap_clamp, w_clamp, thickness + 2], center = true);
			}
	}
}

module stiffening_board_relief() {
		// holes to mount stiffening boards
		for (i = [-1, 1])
			translate([i * (cc_guides / 2 - pad_clamp + d_M3_screw / 2), 0, 0])
				rotate([90, 0, 0])
					cylinder(r = d_M3_screw / 2, h = w_clamp + 1, center = true);
}

module intermediate() {
	difference() {
		union() {
			round_box(
				l_clamp,
				w_clamp,
				t_clamp);

			apex(l_linking_board_slot = l_mount_slot);
		}

		rod_clamp_relief(thickness = t_clamp + 2, z_offset_guides = 0);

		stiffening_board_relief();

		difference() {
			union() {
				round_box(
					length = l_idler_relief,
					width = w_idler_relief,
					thickness = t_clamp + 2,
					radius = r_idler_relief);

				rotate([90, 0, 0])
					round_box(
						length = l_idler_relief,
						width = 3 * w_clamp / 4,
						thickness = t_clamp + 2,
						radius = r_idler_relief);
			}

			for (i = [-1, 1])
				translate([i * (cc_guides / 2 - pad_clamp + d_M3_screw / 2), 0, 0])
					rotate([90, 0, 0])
						cylinder(r = d_M3_screw, h = w_clamp + 1, center = true);

		}
	}
}

module end_idler() {
	difference() {
		union() {
			round_box(
				l_clamp,
				w_clamp,
				t_clamp);

			apex(l_linking_board_slot = l_mount_slot);
		}

		// place the idler shaft such that the belt is parallel with the pulley - the belt dog will be on the right looking down the vertical axis
		translate([(d_pulley - od_idler) / 2, 0, 0])
			rotate([90, 0, 0])
				union() {
					cylinder(r = id_idler / 2, h = w_clamp + 2, center = true);

					translate([0, 0, -w_clamp / 2])
						cylinder(r = d_M8_nut / 2, h = 2 * h_M8_nut, center = true, $fn = 6);
				}

		// idler will be two bearing thick plus two washers
		round_box(
			length = l_idler_relief,
			width = w_idler_relief,
			thickness = t_clamp + 2,
			radius = r_idler_relief);

		rod_clamp_relief(thickness = t_clamp, z_offset_guides = 5);

		// limit switch mount
		translate([l_clamp / 2 - 12, -w_clamp / 2, t_clamp / 2 - 6]) {
			cube([l_limit_switch, w_limit_switch, t_limit_switch], center = true);

			rotate([90, 0, 0])
				for (i = [-1, 1])
					translate([i * 9.5 / 2, 0, -8])
							cylinder(r = 1, h = 12, center = true);
		}

		stiffening_board_relief();
	}
}

module end_motor() {
	union() {
		difference() {
			union() {
				apex(l_linking_board_slot = l_mount_slot);

				translate([0, 0, (l_NEMA17 - t_clamp) / 2])
					round_box(
							l_clamp,
							w_clamp,
							l_NEMA17);
			}

			translate([0, 0, (l_NEMA17 - t_clamp) / 2]) {
				round_box(
					length = l_idler_relief,
					width = w_idler_relief,
					thickness = l_NEMA17 + 2,
					radius = r_idler_relief);

				rod_clamp_relief(thickness = l_NEMA17, z_offset_guides = -5);
			}

			// motor mount
			translate([0, 0, (l_NEMA17 - t_clamp) / 2])
				rotate([90, 0, 0])
					NEMA17_parallel_holes(
						w_clamp - w_idler_relief + 2,
						l_slot = 0);

			// Holes to access motor mount screws and pulley
			translate([0, w_idler_relief, (l_NEMA17 - t_clamp) / 2])
				rotate([90, 0, 0])
					NEMA17_parallel_holes(
						height = w_clamp - w_idler_relief + 2,
						l_slot = 0,
						d_collar = d_pulley);

			// set screw access - access from bottom of printer
			translate([-2.5, -w_clamp / 2 - 1, d_NEMA17_collar / 2 + 0.25])
				cube([5, w_clamp / 2, (t_clamp - d_NEMA17_collar) / 2]);

			stiffening_board_relief();
		}

		// floors for rod openings
		for (i = [-1, 1])
		translate([i * cc_guides / 2, 0, t_clamp / 2 - 5])
			cylinder(r = d_guides / 2, h = 0.25);
	}
}

module carriage(
	dogged = 0,
	magnet_mounts = 1,
	stage_mounts = 1) {
	y_web = - od_lm8uu / 2 - (3 - w_carriage_web / 2);
	limit_x_offset = 11;
	
	stage_mount_pad = 2.2;
	difference() {
		union() {
			// bearing saddles
			for (i = [-1, 1])
				translate([i * cc_guides / 2, 0, 0]) {
					cylinder(r = od_lm8uu / 2 + 3, h = t_carriage, center = true);
				}

			if (magnet_mounts == 1) {
				// magnet mounts
				for (i = [-1, 1])
					translate([i * l_effector / 2, -carriage_offset, (stage_mounts == 1) ? stage_mount_pad + h_carriage_magnet_mount / sin(tie_rod_angle) : -4])
						rotate([90 - tie_rod_angle, 0, 0])
							magnet_mount(r_pad = r_pad_carriage_magnet_mount, h_pad = h_carriage_magnet_mount);
							
				if (stage_mounts == 1)
					mirror([0, 0, 1])
						for (i = [-1, 1])
							translate([i * l_effector / 2, -carriage_offset, stage_mount_pad + h_carriage_magnet_mount / sin(tie_rod_angle)])
								rotate([90 - tie_rod_angle, 0, 0])
									magnet_mount(r_pad = r_pad_carriage_magnet_mount, h_pad = h_carriage_magnet_mount);


				// need a boss for the end stop screw
				translate([l_effector / 2 - limit_x_offset, -carriage_offset + d_M3_screw, -t_carriage / 2 + 3.5])
					hull()
						for (i = [0, 1])
							translate([0, i * 3, 0])
								cylinder(r1 = d_M3_screw / 2 + 3, r2 = d_M3_screw / 2 + 2, h = 7, center = true);
			}
			else {
				// ball joint mounts
				translate([0, 0, (d_ball_socket - 1 - t_carriage) / 2])
					hull() {
						rotate([0, 90, 0])
							translate([0, -carriage_offset, 0])
								cylinder(r = (d_ball_socket - 1) / 2, h = l_effector, center = true);

						translate([0, y_web - 0.1, 0])
							cube([l_effector, 0.1, d_ball_socket - 1], center = true);
					}
			}

			// web
			translate([0, y_web, 0])
				cube([cc_guides, w_carriage_web, t_carriage], center = true);

			if (dogged == 1)
				translate([d_pulley / 2, y_web, -t_carriage + 26.7225 + t_carriage / 2])
					rotate([0, 0, 90])
						rotate([0, 90, 0])
							dog_linear(T5, 5, 13, 5);

		}

		for (i = [-1, 1])
			translate([i * cc_guides / 2, 0, 0]) {
				for (j = [0, 1])
					translate([0, j * (od_lm8uu / 2 - 1), 0])
						cylinder(r = od_lm8uu / 2, h = l_lm8uu, center = true);

				hull() {
					cylinder(r = d_guides / 2, h = t_carriage + 2, center = true);

					translate([0, od_lm8uu / 2 + 3, 0])
						cylinder(r = d_guides / 2, h = t_carriage + 2, center = true);
				}

				translate([0, 10, 0])
					cube([od_lm8uu + 8, od_lm8uu / 2 + 5, t_carriage + 4], center = true);

				// slot for wire tie
				translate([0, 0, 4])
					difference() {
						hull() {
							cylinder(r = od_lm8uu / 2 + 2.2, h = 4.5, center = true);

							translate([0, -20, 0])
								cylinder(r = od_lm8uu / 2 + 2.2, h = 4.5, center = true);
						}

						hull() {
							cylinder(r = od_lm8uu / 2 + 1, h = 6, center = true);

							translate([0, -20, 0])
								cylinder(r = od_lm8uu / 2 + 1, h = 6, center = true);
						}
					}
			}

		// end stop screw
		translate([l_effector / 2 - limit_x_offset, -carriage_offset + d_M3_screw, 0]) {
			translate([0, 0, -t_carriage / 2 + h_M3_cap + 0.25])
				cylinder(r = d_M3_screw / 2 - 0.4, h = d_ball_socket);

			translate([0, 0, -t_carriage / 2])
				cylinder(r = d_M3_cap / 2, h = 2 * h_M3_cap, center = true);
		}

		// mount for belt terminator
		if (dogged != 1)
			translate([d_pulley / 2, y_web, t_carriage / 2 - d_M3_screw / 2 - 5])
				rotate([90, 0, 0])
					cylinder(r = d_M3_screw / 2, h = w_carriage_web + 2, center = true);

		if (magnet_mounts != 1)
			// ball joint mounting screw
			translate([0, -carriage_offset, (d_ball_socket - 1 - t_carriage) / 2]) {
				rotate([0, 90, 0])
					cylinder(r = d_M3_screw / 2, h = cc_guides, center = true);

			// cutout for tensioner hook
			translate([0, 3, 0])
			hull()
				for (i = [0, 1])
					translate([0, i * -10, 0])
						cylinder(r = l_ball_joint / 2 + 0.01, h = d_ball_socket, center = true);
		}

		// need to flatten bottom if magnet mounts
		if (magnet_mounts == 1)
			translate([0, 0, -t_carriage])
				cube([2 * cc_guides, 4 * (od_lm8uu + 6), t_carriage], center = true);
	}

	// floor for rod opening - ignored by slicer when printed horizontally
	for (i = [-1, 1])
		translate([i * cc_guides / 2, -0.35, (l_lm8uu + 0.25) / 2])
			cube([od_lm8uu, id_lm8uu, 0.25], center = true);
			
	// floor for web - ignored by slicer when printed vertically
	translate([0, y_web + (w_carriage_web - 0.25) / 2, 0])
		cube([cc_guides - 8, 0.25, t_carriage], center = true);

	// support for stage magnet mounts
	if (stage_mounts == 1)
		for (i = [-1, 1])
			scale([1, 0.92, 1])
			translate([i * l_effector / 2, -carriage_offset + 1, (h_carriage_magnet_mount - t_carriage) / 2])
				difference() {
					cylinder(r = r_pad_carriage_magnet_mount + od_magnet / 2, h = h_carriage_magnet_mount, center = true);
					
					cylinder(r = r_pad_carriage_magnet_mount + od_magnet / 2 - 0.8, h = h_carriage_magnet_mount, center = true);

					translate([0, 0, h_carriage_magnet_mount - 3.85])
						rotate([92.1 + tie_rod_angle, 0, 0])
							cylinder(r = r_pad_carriage_magnet_mount + od_magnet, h = h_carriage_magnet_mount, center = true);
				}

}

module effector_ball_mount(offset_mount) {
	difference() {
		translate([0, -offset_mount, 0])
			cube([l_effector, d_mount_ball_joint + offset_mount, t_effector], center = true);

				hull() {
					translate([0, -offset_mount / 2, 0])
						cylinder(r = l_ball_joint / 2 + 0.01, h = t_effector + 1, center = true);

					translate([0, l_ball_joint + 1, 0])
						cylinder(r = l_ball_joint / 2 + 0.01, h = t_effector + 1, center = true);
				}

		rotate([0, 90, 0])
			cylinder(r = d_M3_screw / 2, h = l_effector + 1, center = true);
	}
}

module magnet_mount(r_pad, h_pad) {
	// this places the pivot point at the origin
	translate([0, 0, -r_bearing_seated - h_magnet / 2]) {
		difference() {
			translate([0, 0,  - h_pad / 2])
				cylinder(r = od_magnet / 2 + r_pad, h = h_magnet + h_pad, center = true);

			cylinder(r1 = od_magnet / 2 + 0.5, r2 = od_magnet / 2, h = h_magnet, center = true);
		}

/*
		// magnet and ball bearing
		color([0.7, 0.7, 0.7])
			union() {
				difference() {
					cylinder(r = od_magnet / 2, h = h_magnet, center = true);

					cylinder(r = id_magnet / 2, h = h_magnet + 1, center = true);
				}

				translate([0, 0, h_magnet / 2 + r_bearing_seated])
					sphere(r = d_ball_bearing / 2);
			}
*/
	}
}


// split this out to facilitate creation of various effector mods
module effector_base(
	magnet_mounts = 1) {

	difference() {
		union() {
			if (magnet_mounts != 1)
				for (i = [0:2])
					rotate([0, 0, i * 120])
						translate([0, r_effector, 0])
							effector_ball_mount(offset_mount = offset_mount);
			else
					translate([0, 0, h_effector_magnet_mount])
						for (i = [0:2])
							rotate([0, 0, i * 120])
								translate([0, r_effector, 0])
										rotate([tie_rod_angle - 90, 0, 0])
											for (j = [-1, 1])
												translate([j * (l_effector) / 2, 0, 0])
													magnet_mount(r_pad = r_pad_effector_magnet_mount, h_pad = h_effector_magnet_mount);

			// inner portion of effector
			difference() {
				translate([0, r_triangle_middle - h_triangle_inner, 0])
					linear_extrude(height = t_effector, center = true)
						equilateral(h_triangle_inner);

				// round the triangle apexes
				for(i = [0:2])
					rotate([0, 0, i * 120])
						translate([0, r_triangle_middle - h_triangle_inner, 0])
							cylinder(r = (magnet_mounts == 1) ? 2.5 : r_apex, h = t_effector + 1, center = true);
			}
		}

		// need to flatten base if there are magnet mounts
		if (magnet_mounts == 1)
			translate([0, 0, -t_effector * 2.5])
				cylinder(r = r_effector * 2, h = t_effector * 4, center = true);
	}
}

module stage_effector(
	magnet_mounts = 1) {

	difference() {
		effector_base(magnet_mounts = 1);

		for (i = [0:2])
			rotate([0, 0, i * 120])
				translate([0, -r_effector, 0])
					rotate([0, 0, 30]) {
						translate([0, 0, -t_effector / 2 - 0.25])
							cylinder(r = d_M3_nut / 2, h = t_effector / 2, $fn = 6);

						cylinder(r = d_M3_screw / 2, h = t_effector);

					}
					
		hull()
			for (i = [0:2])
				rotate([0, 0, i * 120])
					translate([0, -r_effector + 12, 0])
						cylinder(r = 3, h = t_effector + 1, center = true);
	}
}

module effector(
	dalekify = 0,
	magnet_mounts = 1) {

	r_apex = 7;
	t_hotend_cage = t_heat_x_jhead - h_groove_jhead - h_groove_offset_jhead;
	d_hotend_side = d_large_jhead + 8;
	z_offset_retainer = t_hotend_cage - t_effector / 2 - 3;  // need an additional 3mm to clear the interior of the cage
	a_fan_mount = 15;
	l_fan = 39.5;
	r_flare = 6;
	h_retainer_body = h_groove_jhead + h_groove_offset_jhead + 4;
	r1_retainer_body = d_hotend_side / 2 + r_flare * 3 / t_hotend_cage;
	r2_retainer_body = r1_retainer_body - r_flare * h_retainer_body / t_hotend_cage;
	r2_opening = (d_hotend_side - 5 ) / 2 + r_flare * (t_hotend_cage - 6 - t_effector + 3.0) / (t_hotend_cage - 6);//r1_opening - r_flare * (t_effector + 1.5) / t_hotend_cage;
	r1_opening = r2_opening - 1.5;
	d_retainer_screw = d_M2_screw;

difference() {
	union() {
		effector_base(magnet_mounts = 1);

		// hot end cage
		translate([0, 0, (t_hotend_cage - t_effector) / 2])
			hotend_cage(
				thickness = t_hotend_cage,
				a_fan_mount = a_fan_mount,
				l_fan = l_fan,
				d_fan_mount_hole = 3.4,
				cc_mount_holes = 32,
				d_fan = 38,
				d_hotend_side = d_hotend_side,
				r_flare = r_flare,
				dalekify = dalekify);

		// hot end retainer body
		translate([0, 0, z_offset_retainer]) {
			cylinder(r1 = r1_retainer_body, r2 = r2_retainer_body, h = h_retainer_body);

			// cool looking top
			translate([0, 0, h_retainer_body]) {
				scale([1, 1, 1.2])
					sphere(r = r2_retainer_body);

				if (dalekify == 1) {
					translate([0, 0, 0])
						for (i = [-1, 1])
							translate([])
								rotate([0, i * 45, 0])
									cylinder(r = 1.5, h = r2_retainer_body + 4);
				}
			}
		}
	}

	// opening for hot end
	translate([0, 0, -t_effector / 2 - 1])
		cylinder(r1 = r1_opening, r2 = r2_opening, h = t_effector + 1.5);

	// hot end mounting parts
	translate([0, 0, z_offset_retainer]) {
		// bowden sheath retainer
		translate([0, 0, 0.5]) // leave a floor
			hull()
				for (i = [0, 1])
					translate([0, i * d_hotend_side, 0])
						cylinder(r = d_small_jhead / 2, h = h_groove_jhead + 2);

		translate([0, 0, h_groove_jhead]) {
			hull()
				for (i = [0, 1])
					translate([0, i * d_large_jhead / 2, 0])
						cylinder(r = d_large_jhead / 2, h = h_groove_offset_jhead);

			hull() {
				translate([0, d_large_jhead / 3, h_groove_offset_jhead / 2])
					cube([d_large_jhead, 0.1, h_groove_offset_jhead], center = true);

				translate([0, d_large_jhead, h_groove_offset_jhead / 2 - 1.5])
					cube([d_large_jhead, 0.1, h_groove_offset_jhead + 3], center = true);
			}

			translate([0, 0, h_groove_offset_jhead + 0.25]) {
				cylinder(r = 175_bowden[0] / 2, h = 175_bowden[1], $fn = 6);

				// bowden sheath
				translate([0, 0, 175_bowden[1] + 0.25])
					cylinder(r = 175_bowden[2] / 2, h = 30);

				// retainer retainer
				translate([0, (d_large_jhead + d_retainer_screw) / 2, 0])
					cylinder(r = d_M2_screw / 2 - 0.15, h = 20);

				translate([0, (d_large_jhead + d_retainer_screw) / 2, 6])
					cylinder(r = d_M2_screw_head / 2, h = 20);
			}
		}

			if (dalekify == 1) {
				for (i = [-1,1])
					translate([i * (d_hotend_side / 2 - 3), 0, 3])
						rotate([80, 0, 0])
							cylinder(r = 2.2 / 2, h = 20);

				translate([0, -r2_retainer_body + 7, h_retainer_body + r2_retainer_body - 5])
					rotate([70, 0, 0])
						cylinder(r = 2.2 / 2, h = 20);
		}

	}

		// wire passage
		rotate([22, 0, 0])
			cylinder(r = 3, h = 40);

		// access for pushing hot end out
		translate([0, 0, z_offset_retainer + h_groove_jhead + h_groove_offset_jhead / 2])
			rotate([90, 0, 0])
				cylinder(r = 1.5, h = 30, center = true);
	}

	translate([0, 0, z_offset_retainer]) {
		// floor for retainer body
		hull() {
			cylinder(r = r1_retainer_body - 1, h = 0.5);

			translate([0, r1_retainer_body, 0.25])
				cube([37, 0.1, 0.5], center = true);
			}

		// floor for top of retainer body
		translate([0, d_hotend_side / 2 - 2, h_groove_jhead + h_groove_offset_jhead + 0.25])
			cube([l_fan - 5, 7, 0.5], center = true);
	}
}

module hotend_cage(
	thickness,
	a_fan_mount,
	l_fan,
	d_fan_mount_hole,
	cc_mount_holes,
	d_fan,
	d_hotend_side,
	r_flare,
	dalekify) {

	y_offset_fan = d_hotend_side / 2 + t_heat_x_jhead / 2 * sin(a_fan_mount);
	z_offset_fan = t_effector;
	h_thickness = thickness / cos(a_fan_mount); // length of hypoteneus based upon thickness of cage
	t_fan_mount = 3;
	h_fan_mount = t_fan_mount / 2 / cos(a_fan_mount);
	r_mount_holes = pow(pow(cc_mount_holes / 2, 2) * 2, 0.5);
	
	difference() {
		union() {
			difference() {
				hotend_cage_shape(
					thickness = thickness,
					d_hotend_side = d_hotend_side,
					l_fan = l_fan,
					y_offset_fan = y_offset_fan,
					z_offset_fan = z_offset_fan,
					a_fan_mount = a_fan_mount,
					r_flare = r_flare,
					dalekify = dalekify);

				hotend_cage_shape(
					thickness = thickness - 6,
					d_hotend_side = d_hotend_side - 5,
					l_fan = l_fan - 6,
					y_offset_fan = y_offset_fan + 0.5,
					z_offset_fan = z_offset_fan,
					a_fan_mount = a_fan_mount,
					r_flare = r_flare);
			}


			translate([0, y_offset_fan, (l_fan > h_thickness) ? z_offset_fan + (l_fan - h_thickness) / 2: z_offset_fan])
				rotate([90 + a_fan_mount, 0, 0]){
					for (i = [-1, 1])
						translate([i * cc_mount_holes / 2, cc_mount_holes / 2, 0])
							rotate([0, 0, i * 20])
								hull() {
									cylinder(r = 3, h = t_fan_mount, center = true);

									translate([0, -4, 0])
										cylinder(r = 1, h = t_fan_mount, center = true);
								}

					for (i = [-1, 1])
						translate([i * cc_mount_holes / 2, -cc_mount_holes / 2, 0])
							cylinder(r = 3, h = t_fan_mount, center = true);
				}
		}				

		translate([0, y_offset_fan, (l_fan > h_thickness) ? z_offset_fan + (l_fan - h_thickness) / 2: z_offset_fan])
			rotate([90 + a_fan_mount, 0, 0])
				for (i = [0:3])
					rotate([0, 0, i * 90 + 45])
						translate([0, r_mount_holes, 0])
							cylinder(r = 2.5 / 2, h = t_fan_mount + 6, center = true);
	}
}

module hotend_cage_shape(
	thickness,
	d_hotend_side,
	l_fan,
	y_offset_fan,
	z_offset_fan,
	a_fan_mount,
	r_flare,
	dalekify = 0) {

	h_thickness = thickness / cos(a_fan_mount); // length of hypoteneus based upon thickness of cage
	r_dalek_spheres = 2;
	a_dalek_spheres = 30;

	union() {
		hull() {
			cylinder(r1 = d_hotend_side / 2 + r_flare, r2 = d_hotend_side / 2, h = thickness, center = true, $fn = (dalekify == 1) ? 12 : 48);

			translate([0, y_offset_fan, (l_fan > h_thickness) ? z_offset_fan + (l_fan - h_thickness) / 2 : z_offset_fan])
				rotate([90 + a_fan_mount, 0, 0])
					round_box(
						l_fan,
						l_fan,
						3,
						radius = 3);
		}

		if (dalekify == 1) {
			translate([0, 0, -thickness / 2])
				for (i = [0:3])
					translate([0, 0, i * (thickness - t_effector - r_dalek_spheres) / 4 + t_effector + r_dalek_spheres])
						rotate([0, 0, a_dalek_spheres / 2])
						for (j = [-3:2])
							rotate([0, 0, j * a_dalek_spheres])
								translate([0, -(d_hotend_side / 2 + r_flare * (thickness - (i * (thickness - t_effector) / 4 + t_effector)) / thickness), 0])
									sphere(r = r_dalek_spheres);
		}
	}
}

module hook() {
	h_hook = 10;
	w_hook = 15;
	d_cord = 3.2;

	difference() {
		rotate([0, 90, 0])
			hull()
				for (i = [0, 1])
					translate([0, i * w_hook, 0])
						cylinder(r = l_ball_joint / 2 - 0.25, h = h_hook, center = true);

		// hook
		translate([0, 1, 0])
		rotate([0, 0, 60])
			hull()
				for (i = [0, 1])
					translate([0, i * h_hook, 0])
						cylinder(r = d_M3_screw / 2 + 0.1, h = l_ball_joint + 1, center = true);

		// opening for cord
		rotate([270, 0, 0]) {
			cylinder(r = d_cord / 2, h = h_hook + l_ball_joint * 2);

			translate([-1, 0, 1.5])
			cylinder(r = d_cord, h = w_hook / 2);
		}
	}
}

// templates:

module linking_board_template() {
	// linking boards will be the same height as the tabs
	// the template is a mount with a stop at the bottom
	// it will print in the same orientation so as to assure the spacing remains correct

	difference() {
		union() {

			translate([0, 0, -t_clamp / 2 - 1.5])
				hull() {
					cylinder(r = w_mount / 2, h = 3, center = true);

					translate([0, -l_mount + w_mount / 2, 0])
						cube([w_mount, w_mount, 3], center = true);
				}
		
			mount_body(
				l_base_mount = l_base_mount,
				w_base_mount = w_base_mount,
				t_base_mount = t_base_mount,
				r_base_mount = r_base_mount);
		}

		for (i = [-1, 0, 1])
		translate([0, 5 - l_pad_mount, i * t_clamp / 3])
			rotate([0, 90, 0])
				cylinder(r = d_M3_screw / 2, h = w_mount + 1, center = true);
	}
}

module power_entry() {
	// designed for http://www.amazon.com/gp/product/B00511QVVK/ref=oh_details_o00_s00_i00?ie=UTF8&psc=1

	l_power_entry = 48.5;
	w_power_entry = 27;
	w2_power_entry = 16;
	h_power_entry = 17;
	t_snap_in = 1;
	h_face_power_entry = 3;

	pad_power_entry = 4;
	pad_screw_face = 3 * 25.4 / 8 - pad_power_entry + 3; // using #6 x 3/4 screws - don't want them going through the 1/2 plywood

	h_trap = (w_power_entry - w2_power_entry) / 2;
	a_knockoff = atan(h_power_entry / w_power_entry);
	w_knockoff = pow(pow(h_power_entry + 2 * pad_power_entry, 2) + pow(w_power_entry + 2 * pad_power_entry, 2), 0.5) + 6;

	difference() {
		translate([0, pad_screw_face / 2, 0])
			cube([l_power_entry + 2 * pad_power_entry, w_power_entry + 2 * pad_power_entry + pad_screw_face, h_power_entry + 2 * pad_power_entry], center = true);

		// face plate - only thickness of snap in
		translate([0, 0, -(h_power_entry + 2 * pad_power_entry) / 2])
			union() {
				translate([h_trap / 2, 0, 0])
					cube([l_power_entry - h_trap, w_power_entry, t_snap_in + 1], center = true);

				translate([-(l_power_entry - h_trap) / 2 + h_trap / 2, 0, 0])
					hull() {
						translate([-h_trap, 0, 0])
							cube([0.1, w2_power_entry, t_snap_in + 1], center = true);

						cube([0.1, w_power_entry, t_snap_in + 1], center = true);
					}
			}

		translate([0, 0, 1])
			scale([1.05, 1.05, 1])
			union() {
				translate([h_trap / 2, 0, 0])
					cube([l_power_entry - h_trap, w_power_entry, h_power_entry + 2 * pad_power_entry], center = true);

				translate([-(l_power_entry - h_trap) / 2 + h_trap / 2, 0, 0])
					hull() {
						translate([-h_trap, 0, 0])
							cube([0.1, w2_power_entry, h_power_entry + 2 * pad_power_entry], center = true);

						cube([0.1, w_power_entry, h_power_entry + 2 * pad_power_entry], center = true);
					}
			}

//		rotate([a_knockoff, 0, 0])
//			translate([0, 0, (h_power_entry + 2 * pad_power_entry) / 2])
//				cube([l_power_entry + 2 * pad_power_entry + 1, w_knockoff, h_power_entry + 2 * pad_power_entry], center = true);

		translate([0, pad_screw_face, (h_power_entry + 2 * pad_power_entry) / 2 + d_M3_cap])
			cube([l_power_entry * 1.05, w_power_entry * 1.05, h_power_entry + 2 * pad_power_entry], center = true);

		for (i = [-1, 1])
			translate([i * 12, 0, 0])
				rotate([90, 0, 0]) {
					cylinder(r = d_M3_screw / 2, h = w_power_entry + 2 * pad_power_entry + 2 * pad_screw_face + 1, center = true);

					translate([0, 0, 10])
					cylinder(r = d_M3_cap / 2 + 1, h = w_power_entry + 2 * pad_power_entry - 2 + 20, center = true);
				}
	}
}

module camera_carriage() {
	y_web = - od_lm8uu / 2 - (3 - w_carriage_web / 2);
	limit_x_offset = 11;
	difference() {
		union() {
			// bearing saddles
			for (i = [-1, 1])
				translate([i * cc_guides / 2, 0, 0]) {
					cylinder(r = od_lm8uu / 2 + 3, h = t_carriage, center = true);
				}

			// camera base
			translate([0, y_web - 55 / 2, -t_carriage / 2 + 5.5])
				cube([cc_guides, 55, 11], center = true);

			// web
			translate([0, y_web, 0])
				cube([cc_guides, w_carriage_web, t_carriage], center = true);
		}

		for (i = [-1, 1])
			translate([i * cc_guides / 2, 0, 0]) {
				for (j = [0, 1])
					translate([0, j * (od_lm8uu / 2 - 1), 0])
						cylinder(r = od_lm8uu / 2, h = l_lm8uu, center = true);

				hull() {
					cylinder(r = d_guides / 2, h = t_carriage + 2, center = true);

					translate([0, od_lm8uu / 2 + 3, 0])
						cylinder(r = d_guides / 2, h = t_carriage + 2, center = true);
				}

				translate([0, 10, 0])
					cube([od_lm8uu + 8, od_lm8uu / 2 + 5, t_carriage + 4], center = true);

				// slot for wire tie
				translate([0, 0, 4])
					difference() {
						hull() {
							cylinder(r = od_lm8uu / 2 + 2.2, h = 4.5, center = true);

							translate([0, -20, 0])
								cylinder(r = od_lm8uu / 2 + 2.2, h = 4.5, center = true);
						}

						hull() {
							cylinder(r = od_lm8uu / 2 + 1, h = 6, center = true);

							translate([0, -20, 0])
								cylinder(r = od_lm8uu / 2 + 1, h = 6, center = true);
						}
					}
			}

		// end stop screw

		translate([l_effector / 2 - limit_x_offset, -carriage_offset + d_M3_screw, 0]) {
			translate([0, 0, -t_carriage / 2 + h_M3_cap + 0.25])
				cylinder(r = d_M3_screw / 2 - 0.4, h = d_ball_socket);

			translate([0, 0, -t_carriage / 2])
				cylinder(r = d_M3_cap / 2, h = 2 * h_M3_cap, center = true);
		}

		// mount for belt terminator
		translate([d_pulley / 2, y_web, t_carriage / 2 - d_M3_screw / 2 - 5])
			rotate([90, 0, 0])
				cylinder(r = d_M3_screw / 2, h = w_carriage_web + 2, center = true);

		// slide for mount
		translate([0, y_web - 55 / 2, -t_carriage / 2 + 8])
		mirror([0, 0, 1])
		hull() {
			translate([0, -15, 0]) {
				cube([32, 62, 2], center = true);

				translate([0, 0, 8])
					cube([25, 55, 0.1], center = true);
			}
		}

	}

	// floor for rod opening
	for (i = [-1, 1])
		translate([i * cc_guides / 2, -0.35, (l_lm8uu + 0.25) / 2])
			cube([od_lm8uu, id_lm8uu, 0.25], center = true);
}


