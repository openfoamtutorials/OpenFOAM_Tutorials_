//Gmsh

z=span;
p[]=p2[];
uboundlines[]=uboundlines2[];
Include "wt.geo";
pp2[]=pp[];
outwardLines2[]=outwardLines[];
peripheralLines2[]=peripheralLines[];
farsurfaces2[]=farsurfaces[];

pplines[]={};
For k In {0:#pp1[]-1}
	Line(ce++)={pp1[k],pp2[k]};pplines[]+=ce;
	//Line(ce++)={pp2[k],pp3[k]};
EndFor
Transfinite Line{pplines[]}=spanCells+1;

Include "wtfill.geo";
inletSurfaces[]+=peripheralSurfaces[{3:5}];
outletSurfaces[]+=peripheralSurfaces[{9:11}];
tunnelSurfaces[]+=peripheralSurfaces[{0:2,6:8}];
//tunnelSurfaces[]+=farsurfaces2[];

