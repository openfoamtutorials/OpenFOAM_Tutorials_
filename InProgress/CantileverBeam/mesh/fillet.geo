//Inputs
height = 0.1;
length = 1;//m
cell_depth = 0.01;//m
fillet_radius = 0.1*height;

grid_size = 0.1*height;
fine_grid_size = 0.1*grid_size;

ce=0;
pts[]={};
Point(ce++) = {fillet_radius,0,0,fine_grid_size};pts[]+=ce;
// Point(ce++) = {0,0,0,fine_grid_size};pts[]+=ce;
Point(ce++) = {length-fillet_radius,0,0,grid_size};pts[]+=ce;
Point(ce++) = {length-fillet_radius,fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {length,fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {length,height-fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {length-fillet_radius,height-fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {length-fillet_radius,height,0,grid_size};pts[]+=ce;
// Point(ce++) = {0,height,0,fine_grid_size};pts[]+=ce;
// Point(ce++) = {0,height-fillet_radius,0,grid_size};pts[]+=ce;
// Point(ce++) = {-fillet_radius,height-fillet_radius,0,grid_size};pts[]+=ce;
// Point(ce++) = {-fillet_radius,fillet_radius,0,grid_size};pts[]+=ce;
// Point(ce++) = {0,fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {fillet_radius,height,0,fine_grid_size};pts[]+=ce;
Point(ce++) = {fillet_radius,height-fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {0,height-fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {0,fillet_radius,0,grid_size};pts[]+=ce;
Point(ce++) = {fillet_radius,fillet_radius,0,grid_size};pts[]+=ce;

lns[]={};
Line(ce++) = pts[{0,1}];lns[]+=ce;
Circle(ce++) = pts[{1:3}];lns[]+=ce;
Line(ce++) = pts[{3,4}];lns[]+=ce;
Circle(ce++) = pts[{4:6}];lns[]+=ce;
Line(ce++) = pts[{6,7}];lns[]+=ce;
Circle(ce++) = pts[{7:9}];lns[]+=ce;
Line(ce++) = pts[{9,10}];lns[]+=ce;
Circle(ce++) = pts[{10,11,0}];lns[]+=ce;

Line Loop(ce++) = lns[];
Plane Surface(ce++) = ce-1;surf = ce;

ids[] = Extrude {0,0,cell_depth} 
{
	Surface{surf};
	Layers{1};
	Recombine;
};

Physical Surface("frontAndBack") = {surf,ids[0]};
// Physical Surface("topAndBottom") = ids[{2,3,5,6}];
Physical Surface("topAndBottom") = ids[{2,3,5,6,7,9}];
Physical Surface("right") = ids[4];
// Physical Surface("left") = ids[{7:9}];
Physical Surface("left") = ids[8];

Physical Volume("cell_zone") = ids[1];
