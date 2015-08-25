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
domain_lc = 1;

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

Plane Surface(ce++) = {loop,loops[]};
// Recombine Surface{ce};
surf = ce;

celldepth = 0.02;
ids[] = Extrude{0,0,celldepth}{
	Surface{surf};
	Layers{1};
	Recombine;
};

Physical Surface("frontAndBack") = {surf,ids[0]};
// Physical Surface("freestream") = {ids[{2:5}]};
Physical Surface("tunnel") = {ids[{2,4}]};
Physical Surface("inlet") = {ids[{3}]};
Physical Surface("outlet") = {ids[{5}]};

Physical Surface("wing") = {ids[{6:(8*#chords[])}]};

Physical Volume(100000) = {1};