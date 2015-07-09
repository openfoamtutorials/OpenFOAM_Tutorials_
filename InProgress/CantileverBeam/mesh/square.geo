//Inputs
height = 0.1;
length = 1;//m
cell_depth = 0.01;//m

grid_size = 0.1*height;

ce=0;
pts[]={};
Point(ce++) = {0,0,0,grid_size};pts[]+=ce;
Point(ce++) = {length,0,0,grid_size};pts[]+=ce;
Point(ce++) = {length,height,0,grid_size};pts[]+=ce;
Point(ce++) = {0,height,0,grid_size};pts[]+=ce;

lns[]={};
Line(ce++) = {pts[0],pts[1]};lns[]+=ce;
Line(ce++) = {pts[1],pts[2]};lns[]+=ce;
Line(ce++) = {pts[2],pts[3]};lns[]+=ce;
Line(ce++) = {pts[3],pts[0]};lns[]+=ce;

Line Loop(ce++) = lns[];
Plane Surface(ce++) = ce-1;surf = ce;

ids[] = Extrude {0,0,cell_depth} 
{
	Surface{surf};
	Layers{1};
	Recombine;
};

Physical Surface("frontAndBack") = {surf,ids[0]};
Physical Surface("topAndBottom") = ids[{2,4}];
Physical Surface("right") = ids[3];
Physical Surface("left") = ids[5];

Physical Volume("cell_zone") = ids[1];
