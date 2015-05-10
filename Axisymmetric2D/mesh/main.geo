//Inputs
ring_diameter = 0.3;
ring_thickness = 0.1;
domain_diameter = 10*ring_diameter;
domain_length = 20*ring_diameter;
ring_gridsize = 0.05*ring_diameter;
domain_gridsize = 0.05*domain_diameter;

Point(1) = {0,0,0,ring_gridsize};
Point(2) = {ring_diameter,0,0,ring_gridsize};
Point(3) = {ring_diameter+ring_thickness/2,0,0,ring_gridsize};
Point(4) = {ring_diameter,ring_thickness/2,0,ring_gridsize};
Point(5) = {ring_diameter-ring_thickness/2,0,0,ring_gridsize};
Point(6) = {ring_diameter,-ring_thickness/2,0,ring_gridsize};

Circle(7) = {3,2,4};
Circle(8) = {4,2,5};
Circle(9) = {5,2,6};
Circle(10) = {6,2,3};

Line Loop(11) = {7,8,9,10};

Point(12) = {0,-domain_length/2,0,domain_gridsize};
Point(13) = {domain_diameter/2,-domain_length/2,0,domain_gridsize};
Point(14) = {domain_diameter/2,domain_length/2,0,domain_gridsize};
Point(15) = {0,domain_length/2,0,domain_gridsize};

Line(16) = {1,12};
Line(17) = {12,13};
Line(18) = {13,14};
Line(19) = {14,15};
Line(20) = {15,1};

Line Loop(21) = {16:20};

Plane Surface(22) = {21,11};

Rotate {{0,1,0},{0,0,0},2.5*Pi/180.0}
{
	Surface{22};
}
new_entities[] = Extrude {{0,1,0},{0,0,0},-5*Pi/180.0}
{
	Surface{22};
	Layers{1};
	Recombine;
};

Physical Surface("wedge0") = {22};
Physical Surface("wedge1") = {new_entities[0]};
Physical Surface("outlet") = {new_entities[2]};
Physical Surface("tunnel") = {new_entities[3]};
Physical Surface("inlet") = {new_entities[4]};
Physical Surface("ring") = {new_entities[{5:8}]};

Physical Volume(1000) = {new_entities[1]};
