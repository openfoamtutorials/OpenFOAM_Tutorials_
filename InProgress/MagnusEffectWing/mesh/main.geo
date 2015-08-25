//Inputs (units are metric)
cylinder_radius = 0.1;
boundarylayer_height = 0.2*cylinder_radius;
boundarylayer_cells = 10;
boundarylayer_progression = 1.1;
surface_gridsize = 0.1*cylinder_radius;

domain_radius = 20*cylinder_radius;
domain_gridsize = 0.1*domain_radius;
cell_depth = cylinder_radius;

Point(1) = {0,0,0};

Point(2) = {cylinder_radius,0,0};
Point(3) = {0,cylinder_radius,0};
Point(4) = {-cylinder_radius,0,0};
Point(5) = {0,-cylinder_radius,0};

Point(6) = {cylinder_radius+boundarylayer_height,0,0};
Point(7) = {0,cylinder_radius+boundarylayer_height,0};
Point(8) = {-(cylinder_radius+boundarylayer_height),0,0};
Point(9) = {0,-(cylinder_radius+boundarylayer_height),0};

Circle(10) = {2,1,3};
Circle(11) = {3,1,4};
Circle(12) = {4,1,5};
Circle(13) = {5,1,2};

Circle(14) = {6,1,7};
Circle(15) = {7,1,8};
Circle(16) = {8,1,9};
Circle(17) = {9,1,6};

Line(18) = {2,6};
Line(19) = {3,7};
Line(20) = {4,8};
Line(21) = {5,9};

Line Loop(22) = {18,14,-19,-10};
Line Loop(23) = {19,15,-20,-11};
Line Loop(24) = {20,16,-21,-12};
Line Loop(25) = {21,17,-18,-13};

Plane Surface(26) = 22;
Plane Surface(27) = 23;
Plane Surface(28) = 24;
Plane Surface(29) = 25;

Transfinite Line{10:17} = cylinder_radius*2*Pi/surface_gridsize;
Transfinite Line{18,19,20,21} = boundarylayer_cells Using Progression boundarylayer_progression;
Transfinite Surface{26,27,28,29};

Recombine Surface{26};
Recombine Surface{27};
Recombine Surface{28};
Recombine Surface{29};

Line Loop(30) = {14:17};

Point(31) = {domain_radius,0,0,domain_gridsize};
Point(32) = {0,domain_radius,0,domain_gridsize};
Point(33) = {-domain_radius,0,0,domain_gridsize};
Point(34) = {0,-domain_radius,0,domain_gridsize};

Circle(35) = {31,1,32};
Circle(36) = {32,1,33};
Circle(37) = {33,1,34};
Circle(38) = {34,1,31};

Line Loop(39) = {35:38};

Plane Surface(40) = {39,30};



Function generateArray//From n; Get series[];
	series[]={};
	For k In {0:n-1}
		series[k]=1;
	EndFor
Return
Function generateGeometricSeries//From r,n,lt; Get series[];
	series[]={};
	sum=0;
	For k In {0:n-1}
		sum+=r^k;
	EndFor
	//Printf("Series:");
	sum2=0;
	For k In {0:n-1}
		sum2+=r^k;
		series[k]=sum2/sum;
		//Printf("%g",series[k]);
	EndFor
Return
Function myExtrusion//From b=;l=;c=;p=; Get surf[];vol;newbase;
	n=c;
	Call generateArray;
	a[]=series[];
	s[]=a[];
	If(p!=1)
		r=p;n=c;lt=l;Call generateGeometricSeries;
		s[]=series[];
	EndIf
	If(p==1)
		ids[]=Extrude {0, 0, l} {
		   	Surface{b};
		   	Layers{c};
		 	Recombine;
		};
	EndIf
	If(p!=1)
		ids[]=Extrude {0, 0, l} {
			Surface{b};
			Layers{a[],s[]};
		   	Recombine;
		};
	EndIf
	extremeLengths[]={s[1]-s[0],s[#s[]-1]-s[#s[]-2]};
	maxLength=extremeLengths[1];
	minLength=extremeLengths[0];
	If(extremeLengths[0]>extremeLengths[1])
		maxLength=extremeLengths[0];
		minLength=extremeLengths[1];
	EndIf
	//Printf("extremeLengths: %g %g",extremeLengths[0],extremeLengths[1]);
	newbase=ids[0];
	vol=ids[1];
	surf[]=ids[{2:#ids[]-1}];
	ce+=10000;
Return





span_progression = 1/1.2;
span_cells = 10;
span = 1;

b=26;
l=span;
c=span_cells;
p=span_progression;
Call myExtrusion;


// new_entities1[] = 
// Extrude{0,0,cell_depth}
// {
// 	Surface{26};
// 	Layers{1};
// 	Recombine;
// };
// new_entities2[] = 
// Extrude{0,0,cell_depth}
// {
// 	Surface{27};
// 	Layers{1};
// 	Recombine;
// };
// new_entities3[] = 
// Extrude{0,0,cell_depth}
// {
// 	Surface{28};
// 	Layers{1};
// 	Recombine;
// };
// new_entities4[] = 
// Extrude{0,0,cell_depth}
// {
// 	Surface{29};
// 	Layers{1};
// 	Recombine;
// };
// new_entities5[] = 
// Extrude{0,0,cell_depth}
// {
// 	Surface{40};
// 	Layers{1};
// 	Recombine;
// };

// Physical Surface("cylinder") = {new_entities1[5],new_entities2[5],new_entities3[5],new_entities4[5]};
// Physical Surface("domain_boundary") = {new_entities5[{2:5}]};
// Physical Surface("symmetry") = {26:29,40,new_entities1[0],new_entities2[0],new_entities3[0],new_entities4[0],new_entities5[0]};

// Physical Volume(1000) = {new_entities1[1],new_entities2[1],new_entities3[1],new_entities4[1],new_entities5[1]};