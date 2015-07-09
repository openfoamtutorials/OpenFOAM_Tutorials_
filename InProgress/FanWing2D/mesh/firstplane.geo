//Gmsh

//Printf("Casing at z=0");
z=0;
o=origin1;
jetAngle=jetAngles[0];
Include "casing.geo";
periphery1[]=periphery[];
jetLines[]+=jetLine;
bottomLines[]+=bottomLine;
tes[]+=te;
corners[]+=corner;
inlips[]+=inlip;
outlips[]+=outlip;
bottoms[]+=bottom;
//topCorners[]+=topCorner;
topDisks[]+=topDisk;



z=0;
Include "bound.geo";
p1[]=p[];
pp1[]=pp[];
uboundlines1[]=uboundlines[];
outwardLines1[]=outwardLines[];
peripheralLines1[]=peripheralLines[];
farsurfaces1[]=farsurfaces[];
symmetrySurfaces[]+=farsurfaces[];



lines[]=uboundlines1[];
Call autoLineLoop;
loop1=ce;
lines[]=periphery1[];
Call autoLineLoop;
loop2=ce;
Plane Surface(ce++)={loop1,loop2};
Recombine Surface(ce);
nearSurface=ce;
symmetrySurfaces[]+=nearSurface;



l=span;
c=spanCells;
p=spanProgression;
b=nearSurface;
Call myExtrusion;
casingSurfaces[]+=surf[{4:7}];
statorVolumes[]+=vol;
capSurfaces[]+=newbase;
nearSurface=newbase;
ubc[]={};//ubound connectors
ubs[]={};//ubound surfaces
uboundlines2[]={};
periphery2[]={};
tmp[]=Boundary{Surface{newbase};};
periphery2[]=tmp[{4:9}];
ubs[]=surf[{0:3}];
For nn In {0:3}
	tmp[]=Boundary{Surface{surf[nn]};};
	ubc[nn]=tmp[3];
	uboundlines2[nn]=tmp[2];
EndFor
p2[]={};
tmp[]=Boundary{Surface{nearSurface};};
For nn In {0:3}
	tmp2[]=Boundary{Line{tmp[nn]};};
	p2[]+=tmp2[0];
EndFor
//tmp[]=p2[];
//Call pt;

//tunnelSurfaces[]+=nearSurface;
