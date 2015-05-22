//Inputs
INCH_TO_METER = 0.0254;
length = 16.835*INCH_TO_METER;//m
square_dimension = 0.75*INCH_TO_METER;
hole_diameter = 0.144*INCH_TO_METER;
thickness = 1./16.*INCH_TO_METER;
hole_location_1 = 5.75*INCH_TO_METER;
hole_location_3 = 16.085*INCH_TO_METER;
hole_location_2 = hole_location_3-2.5*INCH_TO_METER;
width_gridsize = square_dimension/30;
length_gridsize = length/150;
hole_gridsize = hole_diameter/20;
thickness_gridlayers = 7;
vertical_wall_gridlayers = 0.1*(square_dimension-2*thickness)/thickness*thickness_gridlayers;

//Derived
hole_section_dimension = square_dimension-2*thickness;

//
ce = 0;
//Center points
Point(ce++) = {0,0,0};origin=ce;
hole_centers[] = {};
section_points_1[] = {};
section_points_2[] = {};
section_points_3[] = {};
//fixed
Point(ce++) = {hole_location_1-hole_section_dimension/2,0,0};section_points_1[] += ce;
Point(ce++) = {hole_location_1-hole_diameter/2,0,0,hole_gridsize};section_points_1[] += ce;
Point(ce++) = {hole_location_1,0,0,hole_gridsize};hole_centers[] += ce;
Point(ce++) = {hole_location_1,0,hole_diameter/2,hole_gridsize};section_points_1[] += ce;
Point(ce++) = {hole_location_1+hole_diameter/2,0,0,hole_gridsize};section_points_1[] += ce;
Point(ce++) = {hole_location_1+hole_section_dimension/2,0,0};section_points_1[] += ce;
//first load
Point(ce++) = {hole_location_2-hole_section_dimension/2,0,0};section_points_2[] += ce;
Point(ce++) = {hole_location_2-hole_diameter/2,0,0,hole_gridsize};section_points_2[] += ce;
Point(ce++) = {hole_location_2,0,0,hole_gridsize};hole_centers[] += ce;
Point(ce++) = {hole_location_2,0,hole_diameter/2,hole_gridsize};section_points_2[] += ce;
Point(ce++) = {hole_location_2+hole_diameter/2,0,0,hole_gridsize};section_points_2[] += ce;
Point(ce++) = {hole_location_2+hole_section_dimension/2,0,0};section_points_2[] += ce;
//second load
Point(ce++) = {hole_location_3-hole_section_dimension/2,0,0};section_points_3[] += ce;
Point(ce++) = {hole_location_3-hole_diameter/2,0,0,hole_gridsize};section_points_3[] += ce;
Point(ce++) = {hole_location_3,0,0,hole_gridsize};hole_centers[] += ce;
Point(ce++) = {hole_location_3,0,hole_diameter/2,hole_gridsize};section_points_3[] += ce;
Point(ce++) = {hole_location_3+hole_diameter/2,0,0,hole_gridsize};section_points_3[] += ce;
Point(ce++) = {hole_location_3+hole_section_dimension/2,0,0};section_points_3[] += ce;
//tip
Point(ce++) = {length,0,0};endpoint = ce;

mid_lines[] = {};
Line(ce++) = {origin,section_points_1[0]};mid_lines[] += ce;
//first section
Line(ce++) = {section_points_1[0],section_points_1[1]};mid_lines[] += ce;
Circle(ce++) = {section_points_1[1],hole_centers[0],section_points_1[2]};mid_lines[] += ce;
Circle(ce++) = {section_points_1[2],hole_centers[0],section_points_1[3]};mid_lines[] += ce;
Line(ce++) = {section_points_1[3],section_points_1[4]};mid_lines[] += ce;

Line(ce++) = {section_points_1[4],section_points_2[0]};mid_lines[] += ce;
//second section
Line(ce++) = {section_points_2[0],section_points_2[1]};mid_lines[] += ce;
Circle(ce++) = {section_points_2[1],hole_centers[1],section_points_2[2]};mid_lines[] += ce;
Circle(ce++) = {section_points_2[2],hole_centers[1],section_points_2[3]};mid_lines[] += ce;
Line(ce++) = {section_points_2[3],section_points_2[4]};mid_lines[] += ce;

Line(ce++) = {section_points_2[4],section_points_3[0]};mid_lines[] += ce;
//third section
Line(ce++) = {section_points_3[0],section_points_3[1]};mid_lines[] += ce;
Circle(ce++) = {section_points_3[1],hole_centers[2],section_points_3[2]};mid_lines[] += ce;
Circle(ce++) = {section_points_3[2],hole_centers[2],section_points_3[3]};mid_lines[] += ce;
Line(ce++) = {section_points_3[3],section_points_3[4]};mid_lines[] += ce;

Line(ce++) = {section_points_3[4],endpoint};mid_lines[] += ce;


outer_points[] = {};
//Center points
Point(ce++) = {0,0,hole_section_dimension/2};outer_points[] += ce;
//fixed
Point(ce++) = {hole_location_1-hole_section_dimension/2,0,hole_section_dimension/2};outer_points[] += ce;
Point(ce++) = {hole_location_1+hole_section_dimension/2,0,hole_section_dimension/2};outer_points[] += ce;
//first section
Point(ce++) = {hole_location_2-hole_section_dimension/2,0,hole_section_dimension/2};outer_points[] += ce;
Point(ce++) = {hole_location_2+hole_section_dimension/2,0,hole_section_dimension/2};outer_points[] += ce;
//second section
Point(ce++) = {hole_location_3-hole_section_dimension/2,0,hole_section_dimension/2};outer_points[] += ce;
Point(ce++) = {hole_location_3+hole_section_dimension/2,0,hole_section_dimension/2};outer_points[] += ce;
//tip
Point(ce++) = {length,0,hole_section_dimension/2};outer_points[] += ce;



outer_lines[]={};
Line(ce++) = {outer_points[{0,1}]};outer_lines[] += ce;
Line(ce++) = {outer_points[{1,2}]};outer_lines[] += ce;
Line(ce++) = {outer_points[{2,3}]};outer_lines[] += ce;
Line(ce++) = {outer_points[{3,4}]};outer_lines[] += ce;
Line(ce++) = {outer_points[{4,5}]};outer_lines[] += ce;
Line(ce++) = {outer_points[{5,6}]};outer_lines[] += ce;
Line(ce++) = {outer_points[{6,7}]};outer_lines[] += ce;



edge_points[] = {};
//Center points
Point(ce++) = {0,0,square_dimension/2};edge_points[] += ce;
//fixed
Point(ce++) = {hole_location_1-hole_section_dimension/2,0,square_dimension/2};edge_points[] += ce;
Point(ce++) = {hole_location_1+hole_section_dimension/2,0,square_dimension/2};edge_points[] += ce;
//first section
Point(ce++) = {hole_location_2-hole_section_dimension/2,0,square_dimension/2};edge_points[] += ce;
Point(ce++) = {hole_location_2+hole_section_dimension/2,0,square_dimension/2};edge_points[] += ce;
//second section
Point(ce++) = {hole_location_3-hole_section_dimension/2,0,square_dimension/2};edge_points[] += ce;
Point(ce++) = {hole_location_3+hole_section_dimension/2,0,square_dimension/2};edge_points[] += ce;
//tip
Point(ce++) = {length,0,square_dimension/2};edge_points[] += ce;



edge_lines[]={};
Line(ce++) = {edge_points[{0,1}]};edge_lines[] += ce;
Line(ce++) = {edge_points[{1,2}]};edge_lines[] += ce;
Line(ce++) = {edge_points[{2,3}]};edge_lines[] += ce;
Line(ce++) = {edge_points[{3,4}]};edge_lines[] += ce;
Line(ce++) = {edge_points[{4,5}]};edge_lines[] += ce;
Line(ce++) = {edge_points[{5,6}]};edge_lines[] += ce;
Line(ce++) = {edge_points[{6,7}]};edge_lines[] += ce;



out2edge[] = {};
Line(ce++) = {outer_points[0],edge_points[0]};out2edge[] += ce;
Line(ce++) = {outer_points[1],edge_points[1]};out2edge[] += ce;
Line(ce++) = {outer_points[2],edge_points[2]};out2edge[] += ce;
Line(ce++) = {outer_points[3],edge_points[3]};out2edge[] += ce;
Line(ce++) = {outer_points[4],edge_points[4]};out2edge[] += ce;
Line(ce++) = {outer_points[5],edge_points[5]};out2edge[] += ce;
Line(ce++) = {outer_points[6],edge_points[6]};out2edge[] += ce;
Line(ce++) = {outer_points[7],edge_points[7]};out2edge[] += ce;



mid2out[] = {};
Line(ce++) = {origin,outer_points[0]};mid2out[] += ce;
Line(ce++) = {section_points_1[0],outer_points[1]};mid2out[] += ce;
Line(ce++) = {section_points_1[4],outer_points[2]};mid2out[] += ce;
Line(ce++) = {section_points_2[0],outer_points[3]};mid2out[] += ce;
Line(ce++) = {section_points_2[4],outer_points[4]};mid2out[] += ce;
Line(ce++) = {section_points_3[0],outer_points[5]};mid2out[] += ce;
Line(ce++) = {section_points_3[4],outer_points[6]};mid2out[] += ce;
Line(ce++) = {endpoint,outer_points[7]};mid2out[] += ce;




Transfinite Line{mid2out[]} = hole_section_dimension/2/width_gridsize+1;
Transfinite Line{out2edge[]} = thickness/width_gridsize+1;
Transfinite Line{outer_lines[{1,3,5}],edge_lines[{1,3,5}]} = hole_section_dimension/length_gridsize+1;
tmp_cells[] = {(hole_location_1-hole_section_dimension/2)/length_gridsize+1,
				(hole_location_2-hole_location_1-hole_section_dimension)/length_gridsize+1,
				(hole_location_3-hole_location_2-hole_section_dimension)/length_gridsize+1,
				(length-hole_location_3-hole_section_dimension/2)/length_gridsize+1};
Transfinite Line{mid_lines[0],outer_lines[0],edge_lines[0]} = tmp_cells[0];
Transfinite Line{mid_lines[5],outer_lines[2],edge_lines[2]} = tmp_cells[1];
Transfinite Line{mid_lines[10],outer_lines[4],edge_lines[4]} = tmp_cells[2];
Transfinite Line{mid_lines[15],outer_lines[6],edge_lines[6]} = tmp_cells[3];



mid_surfaces[] = {};
Line Loop(ce++) = {mid_lines[0],mid2out[1],-outer_lines[0],-mid2out[0]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
mid_surfaces[] += ce;
Line Loop(ce++) = {mid_lines[5],mid2out[3],-outer_lines[2],-mid2out[2]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
mid_surfaces[] += ce;
Line Loop(ce++) = {mid_lines[10],mid2out[5],-outer_lines[4],-mid2out[4]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
mid_surfaces[] += ce;
Line Loop(ce++) = {mid_lines[15],mid2out[7],-outer_lines[6],-mid2out[6]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
mid_surfaces[] += ce;



edge_surfaces[] = {};
Line Loop(ce++) = {edge_lines[0],-out2edge[1],-outer_lines[0],out2edge[0]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;
Line Loop(ce++) = {edge_lines[1],-out2edge[2],-outer_lines[1],out2edge[1]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;
Line Loop(ce++) = {edge_lines[2],-out2edge[3],-outer_lines[2],out2edge[2]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;
Line Loop(ce++) = {edge_lines[3],-out2edge[4],-outer_lines[3],out2edge[3]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;
Line Loop(ce++) = {edge_lines[4],-out2edge[5],-outer_lines[4],out2edge[4]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;
Line Loop(ce++) = {edge_lines[5],-out2edge[6],-outer_lines[5],out2edge[5]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;
Line Loop(ce++) = {edge_lines[6],-out2edge[7],-outer_lines[6],out2edge[6]};
Plane Surface(ce++) = ce-1;
Transfinite Surface{ce};
Recombine Surface{ce};
edge_surfaces[] += ce;






hole_surfaces[] = {};
Line Loop(ce++) = {mid_lines[{1:4}],mid2out[2],-outer_lines[1],-mid2out[1]};
Plane Surface(ce++) = ce-1;
hole_surfaces[] += ce;
Line Loop(ce++) = {mid_lines[{6:9}],mid2out[4],-outer_lines[3],-mid2out[3]};
Plane Surface(ce++) = ce-1;
hole_surfaces[] += ce;
Line Loop(ce++) = {mid_lines[{11:14}],mid2out[6],-outer_lines[5],-mid2out[5]};
Plane Surface(ce++) = ce-1;
hole_surfaces[] += ce;


//Extrusions
plain_surface[] = {};
volumes[] = {};
symmetry[] = {};
symmetry2[] = {};
fixed_hole[] = {};
load_holes[] = {};



mid_volumes[] = {};
plain_surface[] += mid_surfaces[];
For k In {0:#mid_surfaces[]-1}
	new_entities[] = 
	Extrude{0,thickness,0}
	{
		Surface{mid_surfaces[k]};
		Layers{thickness_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[0];
	symmetry[] += new_entities[2];
	If(k == 0)
		symmetry2[] += new_entities[5];
	EndIf
	If(k == #mid_surfaces[]-1)
		plain_surface[] += new_entities[3];
	EndIf
	new_surf = new_entities[0];
	new_mid_surf = 
	Translate{0,square_dimension-2*thickness,0}
	{
		Duplicata { Surface { new_surf }; }
	};
	new_mid_surf_lines[] = Boundary{Surface{new_mid_surf};};
	Transfinite Line{new_mid_surf_lines[{0,2}]} = tmp_cells[k];
	Transfinite Line{new_mid_surf_lines[{1,3}]} = hole_section_dimension/2/width_gridsize+1;
	Transfinite Surface{new_mid_surf};
	Recombine Surface{new_mid_surf};
	plain_surface[] += new_mid_surf;
	new_entities[] = 
	Extrude{0,thickness,0}
	{
		Surface{new_mid_surf};
		Layers{thickness_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[0];
	symmetry[] += new_entities[2];
	If(k == 0)
		symmetry2[] += new_entities[5];
	EndIf
	If(k == #mid_surfaces[]-1)
		plain_surface[] += new_entities[3];
	EndIf
EndFor

plain_surface[] += edge_surfaces[];
For k In {0:#edge_surfaces[]-1}
	//bottom corner
	new_entities[] = 
	Extrude{0,thickness,0}
	{
		Surface{edge_surfaces[k]};
		Layers{thickness_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[2];
	If(k == 0)
		symmetry2[] += new_entities[5];
	EndIf
	If(k == #edge_surfaces[]-1)
		plain_surface[] += new_entities[3];
	EndIf
	new_surf = new_entities[0];
	//side wall
	new_entities[] = 
	Extrude{0,square_dimension-2*thickness,0}
	{
		Surface{new_surf};
		Layers{vertical_wall_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[{2,4}];
	If(k == 0)
		symmetry2[] += new_entities[5];
	EndIf
	If(k == #edge_surfaces[]-1)
		plain_surface[] += new_entities[3];
	EndIf
	new_surf = new_entities[0];
	//top corner
	new_entities[] = 
	Extrude{0,thickness,0}
	{
		Surface{new_surf};
		Layers{thickness_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[{0,2}];
	If(k == 0)
		symmetry2[] += new_entities[5];
	EndIf
	If(k == #edge_surfaces[]-1)
		plain_surface[] += new_entities[3];
	EndIf
EndFor

plain_surface[] += hole_surfaces[];
For k In {0:#hole_surfaces[]-1}
	new_entities[] = 
	Extrude{0,thickness,0}
	{
		Surface{hole_surfaces[k]};
		Layers{thickness_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[0];
	symmetry[] += new_entities[{2,5}];
	If (k == 0)
		fixed_hole[] += new_entities[{3,4}];
	EndIf
	If (k > 0)
		load_holes[] += new_entities[{3,4}];
	EndIf
	new_surf = new_entities[0];
	new_hole_surf = 
	Translate{0,square_dimension-2*thickness,0}
	{
		Duplicata { Surface { new_surf }; }
	};
	new_hole_surf_lines[] = Boundary{Surface{new_hole_surf};};
	Transfinite Line{new_hole_surf_lines[{4,6}]} = hole_section_dimension/2/width_gridsize+1;
	Transfinite Line{new_hole_surf_lines[5]} = hole_section_dimension/length_gridsize+1;
	plain_surface[]+=new_hole_surf;
	new_entities[] = 
	Extrude{0,thickness,0}
	{
		Surface{new_hole_surf};
		Layers{thickness_gridlayers};
		Recombine;
	};
	volumes[] += new_entities[1];
	plain_surface[] += new_entities[0];
	symmetry[] += new_entities[{2,5}];
	If (k == 0)
		fixed_hole[] += new_entities[{3,4}];
	EndIf
	If (k > 0)
		load_holes[] += new_entities[{3,4}];
	EndIf
EndFor


Physical Surface("plain_surface") = {plain_surface[]};
Physical Surface("symmetry") = {symmetry[]};
Physical Surface("symmetry2") = {symmetry2[]};
Physical Surface("fixed_hole") = {fixed_hole[]};
Physical Surface("load_holes") = {load_holes[]};
Physical Volume("solid") = {volumes[]};
