//Gmsh

z=span+ept;
pts[]={};
Point(ce++)={plateDim[0]/2+uBoundCenter[0],plateDim[1]/2+uBoundCenter[1],z,platels};pts[]+=ce;
Point(ce++)={-plateDim[0]/2+uBoundCenter[0],plateDim[1]/2+uBoundCenter[1],z,platels};pts[]+=ce;
Point(ce++)={-plateDim[0]/2+uBoundCenter[0],-plateDim[1]/2+uBoundCenter[1],z,platels};pts[]+=ce;
Point(ce++)={plateDim[0]/2+uBoundCenter[0],-plateDim[1]/2+uBoundCenter[1],z,platels};pts[]+=ce;

lns[]={};
Line(ce++)={pts[0],pts[1]};lns[]+=ce;
Line(ce++)={pts[1],pts[2]};lns[]+=ce;
Line(ce++)={pts[2],pts[3]};lns[]+=ce;
Line(ce++)={pts[3],pts[0]};lns[]+=ce;

dlns[]={};
Line(ce++)={p2[0],pts[0]};dlns[]+=ce;
Line(ce++)={p2[1],pts[1]};dlns[]+=ce;
Line(ce++)={p2[2],pts[2]};dlns[]+=ce;
Line(ce++)={p2[3],pts[3]};dlns[]+=ce;
Characteristic Length { p2[] } = outerplatels;

surfs[]={};
lines[]={dlns[0],lns[0],dlns[1],uboundlines2[0]};
Call autoLineLoop;
Call RSU;
surfs[]+=ce;
lines[]={dlns[1],lns[1],dlns[2],uboundlines2[1]};
Call autoLineLoop;
Call RSU;
surfs[]+=ce;
lines[]={dlns[2],lns[2],dlns[3],uboundlines2[2]};
Call autoLineLoop;
Call RSU;
surfs[]+=ce;
lines[]={dlns[3],lns[3],dlns[0],uboundlines2[3]};
Call autoLineLoop;
Call RSU;
surfs[]+=ce;
lines[]=lns[];
Call autoLineLoop;
Call PSU;
surfs[]+=ce;

capSurfaces[]+=surfs[];

l=wtBoundDim[2]-span;
p=extProgression;
c=extCells;
ubs3[]={};
For kk In {0:3}
	b=surfs[kk];
	Call myExtrusion;
	statorVolumes[]+=vol;
	tunnelSurfaces[]+=newbase;
	ubs3[]+=surf[3];
EndFor
b=surfs[4];
Call myExtrusion;
statorVolumes[]+=vol;
tunnelSurfaces[]+=newbase;
ubc3[]={};
uboundlines3[]={};
For kk In {0:3}
	tmp[]=Boundary{Surface{ubs3[kk]};};
	ubc3[]+=tmp[1];
	uboundlines3[]+=tmp[2];
EndFor
p3={};
For kk In {0:3}
	tmp[]=Boundary{Line{ubc3[kk]};};
	p3[]+=tmp[1];	
EndFor
//tmp[]=uboundlines3[];
//Call pt;
//tmp[]=ubs3[];
//Call pt;
//tmp[]=ubc3[];
//Call pt;






/*
last=#periphery2[]-1;
//reverse
copy[]=periphery2[];
For k In {0:last}
	periphery2[k]=copy[last-k];
EndFor
//points
pts[]={};
For k In {0:last}
	tmp[]=Boundary{Line{periphery2[(k+last)%(#periphery2[])]};};
	pts[k]=tmp[1];
EndFor
//tmp[]=pts[];
//Call pt;

epp[]={};
For k In {0:#epx[]-1}
	Point(ce++)={epx[k],epy[k],span+ept,platels};epp[]+=ce;
EndFor
epl[]={};
For k In {1:#epp[]}
	Line(ce++)={epp[k-1],epp[k%#epp[]]};epl[]+=ce;
EndFor

epl2[]={};
For k In {0:6}
	Line(ce++)={epp[k],pts[k]};epl2[]+=ce;
EndFor
For nn In {0:last}
	lines[]={epl2[nn],periphery2[(nn+last)%(last+1)],epl2[(nn+1)%(last+1)],epl[nn]};
	Call autoLineLoop;
	//	Plane Surface(ce++)=ce-1;
	Call RSU;
	capSurfaces[]+=ce;
	//Printf("%g %g %g %g",ll[0],ll[1],ll[2],ll[3]);
	//Printf("Current ce: %g",ce);
		l=wtBoundDim[2]-span;
		c=extCells;
		p=extProgression;
		b=ce;
		Call myExtrusion;
		tunnelSurfaces[]+=newbase;
		statorVolumes[]+=vol;
EndFor
Line Loop(ce++)=epl[];
//	Plane Surface(ce++)=ce-1;
Call PSU;
capSurfaces[]+=ce;
	l=wtBoundDim[2]-span;
	c=extCells;
	p=extProgression;
	b=ce;
	Call myExtrusion;
	tunnelSurfaces[]+=newbase;
	statorVolumes[]+=vol;
	

/*
epp[]={};
For k In {0:#epx[]-1}
	Point(ce++)={epx[k],epy[k],span+ept,platels};epp[]+=ce;
EndFor
epl[]={};
For k In {1:#epp[]}
	Line(ce++)={epp[k-1],epp[k%#epp[]]};epl[]+=ce;
EndFor
epl2[]={};
Line(ce++)={epp[0],outlips[1]};epl2[]+=ce;
Line(ce++)={epp[1],inlips[1]};epl2[]+=ce;
Line(ce++)={epp[2],topDisks[1]};epl2[]+=ce;
//Line(ce++)={epp[3],suppressors[1]};epl2[]+=ce;
Line(ce++)={epp[3],adapts[1]};epl2[]+=ce;
Line(ce++)={epp[4],topCorners[1]};epl2[]+=ce;
Line(ce++)={epp[5],tes[1]};epl2[]+=ce;
Line(ce++)={epp[6],bottoms[1]};epl2[]+=ce;

lines[]={epl2[0],periphery2[7],epl2[1],epl[0]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;
lines[]={epl2[1],periphery2[0],epl2[2],epl[1]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;
lines[]={epl2[2],periphery2[1],periphery2[2],epl2[3],epl[2]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;
Printf("Debug");
tmp[]=lines[];Call pt;
lines[]={epl2[3],periphery2[3],epl2[4],epl[3]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;
lines[]={epl2[4],periphery2[4],epl2[5],epl[4]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;
lines[]={epl2[5],periphery2[5],epl2[6],epl[5]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;
lines[]={epl2[6],periphery2[6],epl2[0],epl[6]};
Call autoLineLoop;
Call RSU;
capSurfaces[]+=ce;

Line Loop(ce++)=epl[];
Call PSU;
capSurfaces[]+=ce;
*/
