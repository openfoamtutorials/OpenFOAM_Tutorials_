chords[] = {0.1, 0.2, 0.3, 0.2, 0.1};
alphas[] = {0*Pi/180,10*Pi/180,20*Pi/180,30*Pi/180,40*Pi/180};
radius_multipliers[] = {4,4,4,4,4};
le_rotates[] = {1*Pi/180,1*Pi/180,1*Pi/180,1*Pi/180,1*Pi/180};
le_radius[] = {.25*.0254,.25*.0254,.25*.0254,.25*.0254,.25*.0254};
le_span_multipliers[] = {0.005,0.005,0.005,0.005,0.005};
dtex[] = {0.0, 0.0, 0.0, 0.0};
dtey[] = {-0.02, -0.02, -0.02, -0.02};
leadjust = 35*Pi/180;

delta = 0.001;
midspan = 6*Pi/180;

fine = 0.0003;
medium = 0.003;
coarse = 0.005;

domain = 10;
domain_lc = 2;

plate_start[] = {-0.1,0.1};
plate_dim[] = {1.03,0.6};
plate_lc[] = {0.02,0.05,0.02,0.05};
tip_lc = 0.1;
plate_thickness = 0.001;

span = 1;
span_cells = 10;
span_progression = 1.2;
tunnel_span = 1;
tunnel_cells = 10;
tunnel_progression = 1.2;



symmetry_walls[] = {};
tunnel_walls[] = {};
plate_walls[] = {};
wing_walls[] = {};
inlet_walls[] = {};
outlet_walls[] = {};



Geometry.Tolerance = 1e-8;
loops[]={};
ce = 0;
le[] = {0,0};
Point(ce++) = {le[0],le[1],0,fine};
origin = ce;
currentle = ce;
tes[] = {};
For k In {0:#alphas[]-1}
	lepos[] = Point{currentle};
	a = alphas[k];
	c = chords[k];
	tepos[] = {lepos[0] + Cos(a)*c, lepos[1] - Sin(a)*c};
	Point(ce++) = {tepos[0], tepos[1], 0, fine};
	tes[] += ce;
	avgpos[] = {(lepos[0]+tepos[0])/2, (lepos[1]+tepos[1])/2};
	centerpos[] = {avgpos[0] - Sin(a)*radius_multipliers[k]*c, avgpos[1] - Cos(a)*radius_multipliers[k]*c};
	Point(ce++) = {centerpos[0], centerpos[1], 0, fine};
	c0 = ce;
	p1pos[] = {lepos[0] + Cos(le_rotates[k]+1.5*Pi-a)*le_radius[k],
		lepos[1] + Sin(le_rotates[k]+1.5*Pi-a)*le_radius[k]};
	Point(ce++) = {p1pos[0], p1pos[1], 0, fine};
	p1 = ce;


	lelns[] = {};
	id[] = Rotate{ {0,0,1}, {centerpos[0],centerpos[1],0}, -le_span_multipliers[k]/c } { 
		Duplicata{ Point{currentle}; }
	};
	ce += 1;
	p2 = id[0];
	Characteristic Length { p2 } = fine;


	Point(ce++) = {p1pos[0] + Cos(le_rotates[k]+Pi-a)*le_radius[k], 
		p1pos[1] + Sin(le_rotates[k]+Pi-a)*le_radius[k], 0, fine};
	p3 = ce;
	Point(ce++) = {p1pos[0] + Cos(le_rotates[k]+1.5*Pi-a+leadjust)*le_radius[k], 
		p1pos[1] + Sin(le_rotates[k]+1.5*Pi-a+leadjust)*le_radius[k], 0, fine};
	p4 = ce;
	Circle(ce++) = {currentle,p1,p3};lelns[]+=ce;
	Circle(ce++) = {p3,p1,p4};lelns[]+=ce;


	jp[] = Point{p2};
	rvec[] = {jp[0]-centerpos[0],jp[1]-centerpos[1]};
	rmag = Sqrt(rvec[0]^2 + rvec[1]^2);
	rdir[] = {rvec[0]/rmag, rvec[1]/rmag};
	jptpos[] = {jp[0]-rdir[0]*delta,jp[1]-rdir[1]*delta};
	Point(ce++) = {jptpos[0],jptpos[1],0, medium};
	jpt = ce;
	avgpos2[] = {(jptpos[0]+tepos[0])/2, (jptpos[1]+tepos[1])/2};
	cvec[] = {jptpos[0]-tepos[0],jptpos[1]-tepos[1]};
	cmag = Sqrt(cvec[0]^2 + cvec[1]^2);
	cdir[] = {cvec[0]/cmag,cvec[1]/cmag};
	ndir[] = {-cdir[1],cdir[0]};
	c1pos[] = {avgpos2[0]+ndir[0]*radius_multipliers[k]*c,
		avgpos2[1]+ndir[1]*radius_multipliers[k]*c};
	Point(ce++) = {c1pos[0],c1pos[1],0};
	c1 = ce;
	

	id[] = Rotate{ {0,0,1}, {c1pos[0],c1pos[1],0}, -midspan } { 
		Duplicata{ Point{jpt}; }
	};
	ce += 1;
	mt = ce;
	id[] = Rotate{ {0,0,1}, {centerpos[0],centerpos[1],0}, -midspan } { 
		Duplicata{ Point{p2}; }
	};
	ce += 1;
	mb = ce;

	Characteristic Length { mb,mt } = coarse;

	lns[] = {};
	lns[]+=lelns[];
	Line(ce++) = {p4,jpt};lns[]+=ce;

	Circle(ce++) = {mt,c1,jpt};lns[]+=-ce;
	Circle(ce++) = {tes[k],c1,mt};lns[]+=-ce;
	Circle(ce++) = {mb,c0,tes[k]};lns[]+=-ce;

	Circle(ce++) = {currentle,c0,mb};lns[]+=-ce;

	Line Loop(ce++) = lns[];
	loops[] += ce;

	If (k < #alphas[]-1)
		nextlepos[] = {tepos[0] + dtex[k], tepos[1] + dtey[k]};
		Point(ce++) = {nextlepos[0], nextlepos[1], 0, fine};
	EndIf
	currentle = ce;
EndFor

pts[] = {};
Point(ce++) = {plate_start[0],plate_start[1],0,plate_lc[0]};pts[]+=ce;
Point(ce++) = {plate_start[0]+plate_dim[0],plate_start[1],0,plate_lc[1]};pts[]+=ce;
Point(ce++) = {plate_start[0]+plate_dim[0],plate_start[1]-plate_dim[1],0,plate_lc[2]};pts[]+=ce;
Point(ce++) = {plate_start[0],plate_start[1]-plate_dim[1],0,plate_lc[3]};pts[]+=ce;
lns[] = {};
Line(ce++) = {pts[0],pts[1]};lns[] += ce;
Line(ce++) = {pts[1],pts[2]};lns[] += ce;
Line(ce++) = {pts[2],pts[3]};lns[] += ce;
Line(ce++) = {pts[3],pts[0]};lns[] += ce;
Line Loop(ce++) = lns[];
plate_loop = ce;

pts[] = {};
// Point(ce++) = {domain, 0, 0, domain_lc};pts[]+=ce;
// Point(ce++) = {0, domain, 0, domain_lc};pts[]+=ce;
// Point(ce++) = {-domain, 0, 0, domain_lc};pts[]+=ce;
// Point(ce++) = {0, -domain, 0, domain_lc};pts[]+=ce;
Point(ce++) = {domain, domain, 0, domain_lc};pts[]+=ce;
Point(ce++) = {-domain, domain, 0, domain_lc};pts[]+=ce;
Point(ce++) = {-domain, -domain, 0, domain_lc};pts[]+=ce;
Point(ce++) = {domain, -domain, 0, domain_lc};pts[]+=ce;

lns[] = {};
// Circle(ce++) = {pts[0],origin,pts[1]};lns[] += ce;
// Circle(ce++) = {pts[1],origin,pts[2]};lns[] += ce;
// Circle(ce++) = {pts[2],origin,pts[3]};lns[] += ce;
// Circle(ce++) = {pts[3],origin,pts[0]};lns[] += ce;
Line(ce++) = {pts[0],pts[1]};lns[] += ce;
Line(ce++) = {pts[1],pts[2]};lns[] += ce;
Line(ce++) = {pts[2],pts[3]};lns[] += ce;
Line(ce++) = {pts[3],pts[0]};lns[] += ce;

Line Loop(ce++) = lns[];
loop = ce;

Plane Surface(ce++) = {loop,plate_loop};
outer_surf = ce;
Plane Surface(ce++) = {plate_loop,loops[]};
// Recombine Surface{ce};
plate_surf = ce;




// Include "extrusion.geo";
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



symmetry_walls[] += outer_surf;
symmetry_walls[] += plate_surf;


b=outer_surf;
l=span;
c=span_cells;
p=1/span_progression;
Call myExtrusion;
new_outer_surf = newbase;
outlet_walls[] += surf[3];
inlet_walls[] += surf[1];
tunnel_walls[]+=surf[{0,2}];
b=plate_surf;
Call myExtrusion;
plate_surf2 = newbase;
wing_walls[] += surf[{4:(3+7*#chords[])}];

// celldepth = 0.02;
// ids1[] = Extrude{0,0,celldepth}{
// 	Surface{outer_surf};
// 	Layers{1};
// 	Recombine;
// // };
// ids2[] = Extrude{0,0,celldepth}{
// 	Surface{surf};
// 	Layers{1};
// 	Recombine;
// };

plate_walls[]+=plate_surf2;

lns[] = Boundary{Surface{plate_surf2};};
plate_pts[] = {0,0,0,0};
tmp_pts[] = Boundary{Line{lns[0]};};
plate_pts[0] = tmp_pts[0];
tmp_pts[] = Boundary{Line{lns[1]};};
plate_pts[1] = tmp_pts[0];
tmp_pts[] = Boundary{Line{lns[2]};};
plate_pts[2] = tmp_pts[0];
tmp_pts[] = Boundary{Line{lns[3]};};
plate_pts[3] = tmp_pts[0];


Point(ce++) = {plate_start[0]+plate_dim[0]/2,plate_start[1]-plate_dim[1]/2,span+plate_thickness,tip_lc};
tip = ce;

new_lns[] = {};
Line(ce++) = {plate_pts[0],tip};new_lns[]+=ce;
Line(ce++) = {plate_pts[1],tip};new_lns[]+=ce;
Line(ce++) = {plate_pts[2],tip};new_lns[]+=ce;
Line(ce++) = {plate_pts[3],tip};new_lns[]+=ce;

new_surf[] = {};
Line Loop(ce++) = {lns[0],new_lns[1],-new_lns[0]};
Plane Surface(ce++) = ce-1;
new_surf[]+= ce;
Line Loop(ce++) = {lns[1],new_lns[2],-new_lns[1]};
Plane Surface(ce++) = ce-1;
new_surf[]+= ce;
Line Loop(ce++) = {lns[2],new_lns[3],-new_lns[2]};
Plane Surface(ce++) = ce-1;
new_surf[]+= ce;
Line Loop(ce++) = {lns[3],new_lns[0],-new_lns[3]};
Plane Surface(ce++) = ce-1;
new_surf[]+= ce;


plate_walls[]+=new_surf[];



b=new_surf[0];
l=tunnel_span;
c=tunnel_cells;
p=tunnel_progression;
Call myExtrusion;
tunnel_walls[]+=newbase;
b=new_surf[1];
Call myExtrusion;
tunnel_walls[]+=newbase;
b=new_surf[2];
Call myExtrusion;
tunnel_walls[]+=newbase;
b=new_surf[3];
Call myExtrusion;
tunnel_walls[]+=newbase;
b=new_outer_surf;
Call myExtrusion;
tunnel_walls[]+=newbase;
outlet_walls[] += surf[3];
inlet_walls[] += surf[1];
tunnel_walls[]+=surf[{0,2}];



// Physical Surface("frontAndBack") = {outer_surf,surf,ids1[0],ids2[0]};
// // Physical Surface("freestream") = {ids[{2:5}]};
// Physical Surface("tunnel") = {ids1[{2,4}]};
// Physical Surface("inlet") = {ids1[{3}]};
// Physical Surface("outlet") = {ids1[{5}]};

// Physical Surface("wing") = {ids2[{6:(8*#chords[])}]};

Physical Surface("tunnel") = tunnel_walls[];
// Physical Surface("plate") = {wing_walls[],plate_walls[]};
Physical Surface("symmetry") = symmetry_walls[];
Physical Surface("inlet") = inlet_walls[];
Physical Surface("outlet") = outlet_walls[];
Physical Surface("wing") = {wing_walls[],plate_walls[]};

Physical Volume(100000) = {1,2,3,4,5,6,7};