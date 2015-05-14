Point(1) = {0,0,0};
Point(2) = {1,0,0};

Line(3) = {1,2};

new_entities[] = 
Extrude{0,1,0}
{
	Line{-3};
	Layers{5};
	Recombine;
};

surf = new_entities[1];

Extrude{ Surface{surf}; Layers{10}; Recombine; }