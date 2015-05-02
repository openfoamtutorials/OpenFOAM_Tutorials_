//Inputs
boxdim = 1;
gridsize = boxdim/10;

Point(1) = {0,0,0,gridsize};
Point(2) = {boxdim,0,0,gridsize};
Point(3) = {boxdim,boxdim,0,gridsize};
Point(4) = {0,boxdim,0,gridsize};

Point(5) = {2*boxdim,0,0,gridsize};
Point(6) = {2*boxdim,boxdim,0,gridsize};

Line(7) = {1,2};
Line(8) = {2,3};
Line(9) = {3,4};
Line(10) = {4,1};

Line(11) = {2,5};
Line(12) = {5,6};
Line(13) = {6,3};

Line Loop(14) = {7,8,9,10};
Line Loop(15) = {11,12,13,-8};

Plane Surface(16) = 14;
Plane Surface(17) = 15;

//Make one square structured.
Transfinite Line{7,8,9,10} = boxdim/gridsize;
Transfinite Surface{16};
Recombine Surface{16};

Recombine Surface{17};