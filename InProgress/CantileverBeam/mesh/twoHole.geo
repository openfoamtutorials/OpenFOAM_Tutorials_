//Inputs
height = 0.1;
length = 1;//m
hole_diameter = 0.75*height;
cell_depth = 0.01;//m
hole_offset = 2.0*height;

grid_size = 0.1*height;
hole_grid_size = 0.05*height;

ce=0;
pts[]={};
Point(ce++) = {0,0,0,grid_size};pts[]+=ce;
Point(ce++) = {length,0,0,grid_size};pts[]+=ce;
Point(ce++) = {length,height,0,grid_size};pts[]+=ce;
Point(ce++) = {0,height,0,grid_size};pts[]+=ce;
Point(ce++) = {-hole_offset,height,0,grid_size};pts[]+=ce;
Point(ce++) = {-hole_offset-height/2,height/2,0,grid_size};pts[]+=ce;
Point(ce++) = {-hole_offset,0,0,grid_size};pts[]+=ce;

Point(ce++) = {-hole_offset,height/2,0,grid_size};center=ce;

lns[]={};
Line(ce++) = {pts[0],pts[1]};lns[]+=ce;
Line(ce++) = {pts[1],pts[2]};lns[]+=ce;
Line(ce++) = {pts[2],pts[3]};lns[]+=ce;
Line(ce++) = {pts[3],pts[4]};lns[]+=ce;
Circle(ce++) = {pts[4],center,pts[5]};lns[]+=ce;
Circle(ce++) = {pts[5],center,pts[6]};lns[]+=ce;
Line(ce++) = {pts[6],pts[0]};lns[]+=ce;

pts2[]={};
Point(ce++) = {-hole_offset+hole_diameter/2,height/2,0,hole_grid_size};pts2[]+=ce;
Point(ce++) = {-hole_offset,height/2+hole_diameter/2,0,hole_grid_size};pts2[]+=ce;
Point(ce++) = {-hole_offset-hole_diameter/2,height/2,0,hole_grid_size};pts2[]+=ce;
Point(ce++) = {-hole_offset,height/2-hole_diameter/2,0,hole_grid_size};pts2[]+=ce;

lns2[]={};
Circle(ce++) = {pts2[0],center,pts2[1]};lns2[]+=ce;
Circle(ce++) = {pts2[1],center,pts2[2]};lns2[]+=ce;
Circle(ce++) = {pts2[2],center,pts2[3]};lns2[]+=ce;
Circle(ce++) = {pts2[3],center,pts2[0]};lns2[]+=ce;

Point(ce++) = {-hole_diameter/2,height/2,0,grid_size};center2=ce;

pts3[]={};
Point(ce++) = {-hole_diameter/2+hole_diameter/2,height/2,0,hole_grid_size};pts3[]+=ce;
Point(ce++) = {-hole_diameter/2,height/2+hole_diameter/2,0,hole_grid_size};pts3[]+=ce;
Point(ce++) = {-hole_diameter/2-hole_diameter/2,height/2,0,hole_grid_size};pts3[]+=ce;
Point(ce++) = {-hole_diameter/2,height/2-hole_diameter/2,0,hole_grid_size};pts3[]+=ce;

lns3[]={};
Circle(ce++) = {pts3[0],center2,pts3[1]};lns3[]+=ce;
Circle(ce++) = {pts3[1],center2,pts3[2]};lns3[]+=ce;
Circle(ce++) = {pts3[2],center2,pts3[3]};lns3[]+=ce;
Circle(ce++) = {pts3[3],center2,pts3[0]};lns3[]+=ce;

Line Loop(ce++) = lns[];
Line Loop(ce++) = lns2[];
Line Loop(ce++) = lns3[];
Plane Surface(ce++) = {ce-3,ce-2,ce-1};surf = ce;

ids[] = Extrude {0,0,cell_depth} 
{
	Surface{surf};
	Layers{1};
	Recombine;
};

Physical Surface("frontAndBack") = {surf,ids[0]};
Physical Surface("topAndBottom") = ids[{2,4:8}];
// Physical Surface("topAndBottom") = ids[{2,4:8,11:14}];
Physical Surface("right") = ids[3];
Physical Surface("left") = ids[{9:16}];
// Physical Surface("left") = ids[{9,10,15,16}];

Physical Volume("cell_zone") = ids[1];
