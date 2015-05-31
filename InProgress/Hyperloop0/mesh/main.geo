//Inputs
vehicle_diameter = 1;
tube_diameter = 1.25*vehicle_diameter;
vehicle_length = 10*vehicle_diameter;
tube_length = 3*vehicle_length;

vehicle_gridsize = 0.01*vehicle_diameter;
far_gridsize = 0.1*tube_diameter;


ce = 0;
Point(ce++) = {0,0,0,vehicle_gridsize};e1=ce;
Point(ce++) = {vehicle_diameter/2,0,0,vehicle_gridsize};c1 = ce;
Point(ce++) = {vehicle_diameter/2,vehicle_diameter/2,0,vehicle_gridsize};t1=ce;
Point(ce++) = {vehicle_length,0,0,vehicle_gridsize};e2=ce;
Point(ce++) = {vehicle_length-vehicle_diameter/2,vehicle_diameter/2,0,vehicle_gridsize};t2=ce;
Point(ce++) = {vehicle_length-vehicle_diameter/2,0,0,vehicle_gridsize};c2 = ce;

Point(ce++) = {-tube_length/2+vehicle_length/2,0,0,far_gridsize};i1=ce;
Point(ce++) = {tube_length/2+vehicle_length/2,0,0,far_gridsize};o1=ce;
Point(ce++) = {-tube_length/2+vehicle_length/2,tube_diameter/2,0,far_gridsize};i2=ce;
Point(ce++) = {tube_length/2+vehicle_length/2,tube_diameter/2,0,far_gridsize};o2=ce;

Point(ce++) = {0,tube_diameter/2,0,vehicle_gridsize};g1=ce;
Point(ce++) = {vehicle_length,tube_diameter/2,0,vehicle_gridsize};g2=ce;

lns[]={};
Line(ce++) = {i1,e1};lns[]+=ce;
Circle(ce++) = {e1,c1,t1};lns[]+=ce;
Line(ce++) = {t1,t2};lns[]+=ce;
Circle(ce++) = {t2,c2,e2};lns[]+=ce;
Line(ce++) = {e2,o1};lns[]+=ce;
Line(ce++) = {o1,o2};lns[]+=ce;
Line(ce++) = {o2,g2};lns[]+=ce;
Line(ce++) = {g2,g1};lns[]+=ce;
Line(ce++) = {g1,i2};lns[]+=ce;
Line(ce++) = {i2,i1};lns[]+=ce;

Line Loop(ce++) = lns[];

Plane Surface(ce++) = ce-1;surf=ce;

Rotate {{1,0,0},{0,0,0},2.5*Pi/180.0}
{
	Surface{surf};
}
new_entities[] = Extrude {{1,0,0},{0,0,0},-5*Pi/180.0}
{
	Surface{surf};
	Layers{1};
	Recombine;
};

Physical Surface("vehicle") = {new_entities[{2:4}]};
Physical Surface("tunnel") = {new_entities[{6:8}]};
Physical Surface("outlet") = {new_entities[5]};
Physical Surface("inlet") = {new_entities[9]};
Physical Surface("wedge0") = {surf};
Physical Surface("wedge1") = {new_entities[0]};

Physical Volume("volume") = {new_entities[1]};
