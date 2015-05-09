//Inputs
plateChord = 1;
width = 20*plateChord;
height = 10*plateChord;
neargridsize = 0.025*plateChord;
fargridsize = 1*plateChord;
celldepth = 0.1*plateChord;

ce = 0;

//Outer surface.
pts[] = {};
Point(ce++) = {0,0,0,fargridsize};pts[]+=ce;
Point(ce++) = {width,0,0,fargridsize};pts[]+=ce;
Point(ce++) = {width,height,0,fargridsize};pts[]+=ce;
Point(ce++) = {0,height,0,fargridsize};pts[]+=ce;

outer_lns[] = {};
Line(ce++) = {pts[0],pts[1]};outer_lns[]+=ce;
Line(ce++) = {pts[1],pts[2]};outer_lns[]+=ce;
Line(ce++) = {pts[2],pts[3]};outer_lns[]+=ce;
Line(ce++) = {pts[3],pts[0]};outer_lns[]+=ce;

//Inner surface.
pts[] = {};
Point(ce++) = {width/2,height/2-plateChord/2,0,neargridsize};pts[]+=ce;
Point(ce++) = {width/2+plateChord,height/2-plateChord/2,0,neargridsize};pts[]+=ce;
Point(ce++) = {width/2+plateChord,height/2+plateChord/2,0,neargridsize};pts[]+=ce;
Point(ce++) = {width/2,height/2+plateChord/2,0,neargridsize};pts[]+=ce;

inner_lns[]={};
Line(ce++) = pts[{0,1}];inner_lns[]+=ce;
Line(ce++) = pts[{1,2}];inner_lns[]+=ce;
Line(ce++) = pts[{2,3}];inner_lns[]+=ce;
Line(ce++) = pts[{3,0}];inner_lns[]+=ce;

//Surfaces.
Line Loop(ce++) = outer_lns[];
outer_loop = ce;
Line Loop(ce++) = inner_lns[];
inner_loop = ce;
Plane Surface(ce++) = {outer_loop,inner_loop};
outer_surface=ce;
Plane Surface(ce++) = {inner_loop};
inner_surface=ce;

//Extrudes.
outer_entities[] = 
Extrude { 0,0,celldepth }
{
	Surface{outer_surface};
	Layers{1};
	Recombine;
};

inner_entities[] = 
Extrude { 0,0,celldepth }
{
	Surface{inner_surface};
	Layers{1};
	Recombine;
};

//Groupings.
Physical Surface("inlet") = {outer_entities[5]};
Physical Surface("outlet") = {outer_entities[3]};
Physical Surface("tunnel") = {outer_entities[{2,4}]};
Physical Surface("plate") = {inner_entities[5]};
Physical Surface("frontAndBack") = {outer_surface,inner_surface,outer_entities[0],inner_entities[0]};

Physical Volume(1000) = {outer_entities[1],inner_entities[1]};