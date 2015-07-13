chords[] = {0.5, 0.4, 0.3};
alphas[] = {5*Pi/180,5*Pi/180,5*Pi/180};
radius_multipliers[] = {4,4,4};
le_rotates[] = {1*Pi/180,1*Pi/180,1*Pi/180};
le_radius_multipliers[] = {0.05,0.05,0.05};
le_spans[] = {1*Pi/180,1*Pi/180,1*Pi/180};
dtex[] = {0.02, 0.02};
dtey[] = {-0.02, -0.02};

ce = 0;
le[] = {0,0};
Point(ce++) = {le[0],le[1],0};
currentle = ce;
tes[] = {};
For k In {0:#alphas[]-1}
	lepos[] = Point{currentle};
	a = alphas[k];
	c = chords[k];
	tepos[] = {lepos[0] + Cos(a)*c, lepos[1] - Sin(a)*c};
	Point(ce++) = {tepos[0],tepos[1],0};
	tes[] += ce;
	avgpos[] = {(lepos[0]+tepos[0])/2, (lepos[1]+tepos[1])/2};
	centerpos[] = {avgpos[0] - Sin(a)*radius_multipliers[k]*c, avgpos[1] - Cos(a)*radius_multipliers[k]*c};
	Point(ce++) = {centerpos[0], centerpos[1], 0};
	Point(ce++) = {lepos[0] + Cos(le_rotates[k]+Pi/2)*le_radius_multipliers[k]*c, lepos[1] + Sin(le_rotates[k]+Pi/2)*le_radius_multipliers[k]*c, 0};
	Point(ce++) = {lepos[0] + Cos(le_rotates[k]+Pi)*le_radius_multipliers[k]*c, lepos[1] + Sin(le_rotates[k]+Pi)*le_radius_multipliers[k]*c, 0};
	Point(ce++) = {lepos[0] + Cos(le_rotates[k]+1.5*Pi)*le_radius_multipliers[k]*c, lepos[1] + Sin(le_rotates[k]+1.5*Pi)*le_radius_multipliers[k]*c, 0};
	id[] = Rotate{ {0,0,1}, {centerpos[0],centerpos[1],0}, -le_spans[k] } { 
		Duplicata{ Point{currentle}; }
	};
	ce += 1;

	If (k < #alphas[]-1)
		nextlepos[] = {tepos[0] + dtex[k], tepos[1] + dtey[k]};
		Point(ce++) = {nextlepos[0], nextlepos[1], 0};
	EndIf
	currentle = ce;
EndFor