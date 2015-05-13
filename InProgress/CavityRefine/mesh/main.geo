boxdim = 1;
celldim = 0.1*boxdim;

Point(1) = {0,0,0};
Point(2) = {boxdim,0,0};
Point(3) = {boxdim,boxdim/2,0};
Point(4) = {0,boxdim/2,0};
Point(5) = {boxdim,boxdim,0};
Point(6) = {0,boxdim,0};

Line(7) = {1,2};
Line(8) = {2,3};
Line(9) = {3,4};
Line(10) = {4,1};

Line(11) = {3,5};
Line(12) = {5,6};
Line(13) = {6,4};

Line Loop(14) = {7:10};
Plane Surface(15) = 14;

Line Loop(16) = {-9,11,12,13};
Plane Surface(17) = 16;

Transfinite Line{8,10,11,13} = boxdim/celldim/2+1;
Transfinite Line{7,9,12} = boxdim/celldim+1;
Transfinite Surface{15,17};
Recombine Surface{15,17};

top_entities[] = Extrude {0,0,boxdim}
{
	Surface{15};
	Layers{boxdim/celldim};
	Recombine;
};
bottom_entities[] = Extrude {0,0,boxdim}
{
	Surface{17};
	Layers{boxdim/celldim};
	Recombine;
};

Physical Surface("walls") = {15,17,top_entities[{0,2,3,5}],bottom_entities[{0,3,5}]};
Physical Surface("lid") = {bottom_entities[4]};

Physical Volume(1000) = top_entities[1];
Physical Volume(1001) = bottom_entities[1];