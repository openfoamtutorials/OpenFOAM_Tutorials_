//Gmsh

z=wtBoundDim[2];
p[]=p3[];
uboundlines[]=uboundlines3[];
ubc[]=ubc3[];
ubs[]=ubs3[];


Include "wt.geo";
pp3[]=pp[];
outwardLines3[]=outwardLines[];
peripheralLines3[]=peripheralLines[];
farsurfaces3[]=farsurfaces[];

pplines[]={};
For k In {0:#pp2[]-1}
	Line(ce++)={pp2[k],pp3[k]};pplines[]+=ce;
EndFor
Transfinite Line{pplines[]}=extCells+1;

//outwardSurfaces[]=outwardLines3[];
peripheralLines1[]=peripheralLines2[];
peripheralLines2[]=peripheralLines3[];
outwardLines1[]=outwardLines2[];
outwardLines2[]=outwardLines3[];
farsurfaces1[]=farsurfaces2[];
farsurfaces2[]=farsurfaces3[];
//ubc[];
//ubs[];
Include "wtfill.geo";
inletSurfaces[]+=peripheralSurfaces[{3:5}];
outletSurfaces[]+=peripheralSurfaces[{9:11}];
tunnelSurfaces[]+=peripheralSurfaces[{0:2,6:8}];
tunnelSurfaces[]+=farsurfaces3[];
