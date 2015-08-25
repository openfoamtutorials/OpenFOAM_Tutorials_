chords[] = {0.1, 0.2, 0.3, 0.2, 0.1};
alphas[] = {0*Pi/180,10*Pi/180,20*Pi/180,30*Pi/180,40*Pi/180};
radius_multipliers[] = {4,4,4,4,4};
le_rotates[] = {1*Pi/180,1*Pi/180,1*Pi/180,1*Pi/180,1*Pi/180};
le_radius[] = {.25*.0254,.25*.0254,.25*.0254,.25*.0254,.25*.0254};
le_spans[] = {3*Pi/180,3*Pi/180,3*Pi/180,3*Pi/180,3*Pi/180};
dtex[] = {0.0, 0.0, 0.0, 0.0};
dtey[] = {-0.02, -0.02, -0.02, -0.02};

delta = 0.001;
midspan = 6*Pi/180;

fine = 0.0001;
coarse = 0.005;

domain = 10;
domain_lc = 1;

loops[]={};
ce = 0;
le[] = {0,0};
Point(ce++) = {le[0],le[1],0};
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
	Point(ce++) = {lepos[0] + Cos(le_rotates[k]+Pi/2-a)*le_radius[k], 
		lepos[1] + Sin(le_rotates[k]+Pi/2-a)*le_radius[k], 0, fine};
	p0 = ce;
	Point(ce++) = {lepos[0] + Cos(le_rotates[k]+Pi-a)*le_radius[k], 
		lepos[1] + Sin(le_rotates[k]+Pi-a)*le_radius[k], 0, fine};
	Point(ce++) = {lepos[0] + Cos(le_rotates[k]+1.5*Pi-a)*le_radius[k], 
		lepos[1] + Sin(le_rotates[k]+1.5*Pi-a)*le_radius[k], 0, fine};
	p1 = ce;
	lelns[] = {};
	Circle(ce++) = {ce-3,currentle,ce-2};lelns[]+=ce;
	Circle(ce++) = {ce-3,currentle,ce-2};lelns[]+=ce;
	id[] = Rotate{ {0,0,1}, {centerpos[0],centerpos[1],0}, -le_spans[k] } { 
		Duplicata{ Point{currentle}; }
	};
	ce += 1;
	p2 = id[0];
	Characteristic Length { p2 } = fine;

	jp[] = Point{p2};
	rvec[] = {jp[0]-centerpos[0],jp[1]-centerpos[1]};
	rmag = Sqrt(rvec[0]^2 + rvec[1]^2);
	rdir[] = {rvec[0]/rmag, rvec[1]/rmag};
	jptpos[] = {jp[0]+rdir[0]*delta,jp[1]+rdir[1]*delta};
	Point(ce++) = {jptpos[0],jptpos[1],0, fine};
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
	Line(ce++) = {jpt,p0};lns[]+=ce;
	lns[]+=lelns[];
	Line(ce++) = {p1,p2};lns[]+=ce;

	Circle(ce++) = {tes[k],c1,mt};lns[]+=ce;
	Circle(ce++) = {mt,c1,jpt};lns[]+=ce;
	Circle(ce++) = {p2,c0,mb};lns[]+=ce;
	Circle(ce++) = {mb,c0,tes[k]};lns[]+=ce;

	Line Loop(ce++) = lns[];
	loops[] += ce;

	If (k < #alphas[]-1)
		nextlepos[] = {tepos[0] + dtex[k], tepos[1] + dtey[k]};
		Point(ce++) = {nextlepos[0], nextlepos[1], 0};
	EndIf
	currentle = ce;
EndFor


pts[] = {};
Point(ce++) = {domain, 0, 0, domain_lc};pts[]+=ce;
Point(ce++) = {0, domain, 0, domain_lc};pts[]+=ce;
Point(ce++) = {-domain, 0, 0, domain_lc};pts[]+=ce;
Point(ce++) = {0, -domain, 0, domain_lc};pts[]+=ce;

lns[] = {};
Circle(ce++) = {pts[0],origin,pts[1]};lns[] += ce;
Circle(ce++) = {pts[1],origin,pts[2]};lns[] += ce;
Circle(ce++) = {pts[2],origin,pts[3]};lns[] += ce;
Circle(ce++) = {pts[3],origin,pts[0]};lns[] += ce;

Line Loop(ce++) = lns[];
loop = ce;

Plane Surface(ce++) = {loop,loops[]};