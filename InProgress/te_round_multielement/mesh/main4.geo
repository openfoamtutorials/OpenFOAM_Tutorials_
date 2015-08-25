
Function calculate_quarter_chord
	/*
	Gives dx and dy such that the quarter chord position is at 0,0.
	Assumes we are starting with a 0-AOA chord line. 
	Inputs:
		target_aoa: the AOA of the chord line of the airfoil.
		target_chord: chord length. 
	Outputs:
		dx, dy: LE displacement to get the desired quarter-chord placement. 
	*/
	dx = -0.25*target_chord*Cos(target_aoa);
	dy = 0.25*target_chord*Sin(target_aoa);
Return





chord = 0.2;
le_radius = 0.25*0.0254;
attachment_length = 0.1;//multiple of chord.
chord_thickness = 0.1;//multiple of chord.
aoas[] = {5*Pi/180, 10*Pi/180, 15*Pi/180, 20*Pi/180, 25*Pi/180};
// aoa = 10*Pi/180;
// target_aoa = aoa; target_chord = chord;
// Call calculate_quarter_chord;
le_dx = 0.0*chord;
le_dy = -0.4*chord;
// le_x = dx;
// le_y = dy;
blheight = 0.05;//multiple of chord.
tip_lc = 0.001;
bl_lc = 0.0015;//multiple of chord.
blheight_lc_adjust = 2;

domain_size = 10;
domain_lc = domain_size/10;
celldepth = 0.02;	




//compute quarter chord
elements = #aoas[];
te_x = 0;
te_y = 0;
For k In {0:elements-1}
	te_x += Cos(aoas[k])*chord;
	te_y -= Sin(aoas[k])*chord;
EndFor
te_x += le_dx*(elements-1);
te_y += le_dy*(elements-1);

total_chord = Sqrt(te_x*te_x + te_y*te_y);
total_aoa = Atan(Fabs(te_y) / Fabs(te_x));
Printf("Total chord, aoa: %f %f", total_chord, total_aoa / Pi * 180);
target_aoa = total_aoa; target_chord = total_chord;
Call calculate_quarter_chord;

le_x = dx;
le_y = dy;
aoa = aoas[0];







ce = 0;

all_volumes[] = {};

Function make_wing_element
	//geometrical quantities.
	h = chord_thickness*chord;
	l = attachment_length*chord;
	beta = Atan(chord / 2 / h);
	alpha = 2*Pi - 4*beta;
	R = chord / 2 / Sin(alpha / 2);
	gamma = 2*Asin(l / 2 / R);
	phi = Acos( le_radius / l );

	all_points[] = {};

	//LE points
	Point(ce++) = {le_x + chord / 2, le_y - (R - h), 0};chord_radius_center = ce;all_points[]+=ce;
	Point(ce++) = {le_x, le_y, 0};le_center = ce;
	le_pts[] = {};
	Point(ce++) = {le_x-le_radius, le_y, 0,tip_lc};le_pts[]+=ce;all_points[]+=ce;
	Point(ce++) = {le_x + Cos(phi)*le_radius, le_y + Sin(phi)*le_radius, 0,tip_lc};le_pts[]+=ce;all_points[]+=ce;
	Point(ce++) = {le_x + Cos(phi)*le_radius, le_y - Sin(phi)*le_radius, 0,tip_lc};le_pts[]+=ce;all_points[]+=ce;
	tmp[] = Point{chord_radius_center};
	Rotate {{0,0,1},{tmp[0],tmp[1],0}, -gamma} { Duplicata{ Point{le_center}; } }
	new_le_center = ce+1;
	ce++;all_points[]+=ce;
	Characteristic Length{ce} = bl_lc;
	tmp3[] = Point{new_le_center};
	tmp2[] = Point{le_center};
	dx = tmp3[0] - tmp2[0];
	dy = tmp3[1] - tmp2[1];
	del = Atan(dy / dx);
	Rotate {{0,0,1},{tmp2[0],tmp2[1],0}, del} { Point{le_pts[]}; }
	

	//TE points
	Point(ce++) = {le_x + chord, le_y, 0};all_points[]+=ce;
	te_center = ce;
	mid[] = { le_x + chord / 2, le_y };
	te_pts[] = {};
	tmp[] = Point{le_pts[0]};
	Point(ce++) = {mid[0] + mid[0] - tmp[0], tmp[1],0,tip_lc};te_pts[]+= ce;all_points[]+=ce;
	tmp[] = Point{le_pts[1]};
	Point(ce++) = {mid[0] + mid[0] - tmp[0], tmp[1],0,tip_lc};te_pts[]+= ce;all_points[]+=ce;
	tmp[] = Point{le_pts[2]};
	Point(ce++) = {mid[0] + mid[0] - tmp[0], tmp[1],0,tip_lc};te_pts[]+= ce;all_points[]+=ce;
	tmp[] = Point{new_le_center};
	Point(ce++) = {mid[0] + mid[0] - tmp[0], tmp[1],0,bl_lc};all_points[]+=ce;
	new_te_center = ce;

	//BL points
	tmp1[] = Point{chord_radius_center};
	tmp2[] = Point{new_le_center};
	dx = tmp2[0] - tmp1[0];
	dy = tmp2[1] - tmp1[1];
	mag = Sqrt(dx*dx + dy*dy);
	dir[] = {dx / mag, dy / mag};
	blr = blheight*chord + R;
	Point(ce++) = {tmp1[0] + blr*dir[0] , tmp1[1] + blr*dir[1], 0};all_points[]+=ce;
	bl_left = ce;
	tmp[] = Point{bl_left};
	Point(ce++) = {mid[0] + mid[0] - tmp[0], tmp[1],0};all_points[]+=ce;
	bl_right = ce;

	//Apply rotation
	c = Cos(aoa);
	s = Sin(aoa);
	Rotate {{0,0,1},{le_x,le_y,0}, -aoa} { Point{all_points[]}; }

	//Lines
	Circle(ce++) = { new_le_center, chord_radius_center, new_te_center };
	main_arc = ce;

	le_lns[] = {};
	Line(ce++) = { new_le_center, le_pts[2] };le_lns[] += ce;
	Circle(ce++) = { le_pts[2], le_center, le_pts[0] };le_lns[] += ce;
	Circle(ce++) = { le_pts[0], le_center, le_pts[1] };le_lns[] += ce;
	Line(ce++) = { le_pts[1], new_le_center };le_lns[] += ce;
	
	te_lns[] = {};
	Line(ce++) = { new_te_center, te_pts[1] };te_lns[] += ce;
	Circle(ce++) = { te_pts[1], te_center, te_pts[0] };te_lns[] += ce;
	Circle(ce++) = { te_pts[0], te_center, te_pts[2] };te_lns[] += ce;
	Line(ce++) = { te_pts[2], new_te_center };te_lns[] += ce;

	bl_lns[] = {};
	Line(ce++) = {new_le_center, bl_left};bl_lns[] += ce;
	Circle(ce++) = { bl_left, chord_radius_center, bl_right };bl_lns[] += ce;
	Line(ce++) = {new_te_center, bl_right};bl_lns[] += ce;

	//Loops
	Line Loop(ce++) = {main_arc, bl_lns[2], -bl_lns[1], -bl_lns[0] };
	bl_loop = ce;
	Line Loop(ce++) = le_lns[];
	le_loop = ce;
	Line Loop(ce++) = te_lns[];
	te_loop = ce;

	//grid spacings
	Transfinite Line{bl_lns[1], main_arc} = R*alpha/bl_lc;
	Transfinite Line{bl_lns[{0,2}]} = blheight*chord/bl_lc*blheight_lc_adjust;
	// tmp1[] = Point{ new_le_center };
	// tmp2[] = Point{ le_pts[1] };
	// dx = tmp2[0] - tmp1[0];
	// dy = tmp2[1] - tmp1[1];
	// mag = Sqrt(dx*dx + dy*dy);
	// Printf("%f %f",mag,lc);
	// Transfinite Line{te_lns[{0,3}], le_lns[{0,3}]} = mag/lc;

	//Surface
	Plane Surface(ce++) = {bl_loop};
	Transfinite Surface{ce};
	Recombine Surface{ce};
	bl_surf = ce;
Return

bl_frontAndBack[] = {};
baffle_surf[] = {};
bl_loops[] = {};
te_loops[] = {};
le_loops[] = {};

Call make_wing_element;
le_x += Cos(aoas[0])*chord;
le_y -= Sin(aoas[0])*chord;

le_loops[] += le_loop;
te_loops[] += te_loop;
bl_loops[] += bl_loop;

ids[] = Extrude{0,0,celldepth}{
	Surface{bl_surf};
	Layers{1};
	Recombine;
};
ce += 1000;
bl_frontAndBack[] += {bl_surf, ids[0]};
baffle_surf[] += ids[2];
all_volumes[] += ids[1];

For k In {1:elements-1}
	aoa = aoas[k];
	le_x += le_dx;
	le_y += le_dy;
	Call make_wing_element;
	le_x += Cos(aoas[k])*chord;
	le_y -= Sin(aoas[k])*chord;

	le_loops[] += le_loop;
	te_loops[] += te_loop;
	bl_loops[] += bl_loop;

	ids[] = Extrude{0,0,celldepth}{
		Surface{bl_surf};
		Layers{1};
		Recombine;
	};
	ce += 1000;
	bl_frontAndBack[] += {bl_surf, ids[0]};
	baffle_surf[] += ids[2];
	all_volumes[] += ids[1];

EndFor


pts[] = {};
Point(ce++) = {domain_size, -domain_size, 0, domain_lc};pts[] += ce;
Point(ce++) = {domain_size, domain_size, 0, domain_lc};pts[] += ce;
Point(ce++) = {-domain_size, domain_size, 0, domain_lc};pts[] += ce;
Point(ce++) = {-domain_size, -domain_size, 0, domain_lc};pts[] += ce;

lns[] = {};
Line(ce++) = {pts[0], pts[1]};lns[] += ce;
Line(ce++) = {pts[1], pts[2]};lns[] += ce;
Line(ce++) = {pts[2], pts[3]};lns[] += ce;
Line(ce++) = {pts[3], pts[0]};lns[] += ce;

Line Loop(ce++) = {lns[]};
domain_loop = ce;

Plane Surface(ce++) = {domain_loop, te_loops[], le_loops[], bl_loops[] };
domain_surf = ce;

ids[] = Extrude{0,0,celldepth}{
	Surface{domain_surf};
	Layers{1};
	Recombine;
};
ce += 1000;
all_volumes[]+=ids[1];

Physical Surface("inlet") = {ids[4]};
Physical Surface("outlet") = {ids[2]};
Physical Surface("tunnel") = {ids[{3,5}]};
Physical Surface("wing") = {ids[{6:5+8*elements}]};//,baffle_surf};
Physical Surface("wing_baffle") = {baffle_surf[]};
Physical Surface("frontAndBack") = {ids[0],domain_surf,bl_frontAndBack[]};

Physical Volume(100000) = {all_volumes[]};