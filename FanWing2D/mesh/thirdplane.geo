//Gmsh

z=wtBoundDim[2];
Include "bound.geo";
p3[]=p[];
pp3[]=pp[];
uboundlines3[]=uboundlines[];
outwardLines3[]=outwardLines[];
peripheralLines3[]=peripheralLines[];
farsurfaces3[]=farsurfaces[];
tunnelSurfaces[]+=farsurfaces3[];

l=span;
c=spanCells;
p=spanProgression;
b=nearSurface;
Call myExtrusion;
//casingSurfaces[]+=surf[{4:6}];
statorVolumes[]+=vol;
nearSurface=newbase;
ubc[]={};//ubound connectors
ubs[]={};//ubound surfaces
uboundlines3[]={};
periphery3[]={};
tmp[]=Boundary{Surface{newbase};};
periphery3[]=tmp[{4:10}];
ubs[]=surf[{0:3}];
For nn In {0:3}
	tmp[]=Boundary{Surface{surf[nn]};};
	ubc[nn]=tmp[1];
	uboundlines3[nn]=tmp[2];
EndFor
/*
l=wtBoundDim[2]-span;
c=extCells;
For nnn In {0:8}
	p=extProgression;
	b=capSurfaces[5+nnn];
	Call myExtrusion;
	tunnelSurfaces[]+=newbase;
	statorVolumes[]+=vol;
EndFor

b=nearSurface;
Call myExtrusion;
tunnelSurfaces[]+=newbase;
statorVolumes[]+=vol;
ubs[0]=surf[2];
ubs[1]=surf[3];
ubs[2]=surf[4];
ubs[7]=surf[1];
tmp[]=Boundary{Surface{surf[1]};};
ubc[0]=tmp[1];
ubc[7]=tmp[3];
tmp[]=Boundary{Surface{surf[3]};};
ubc[1]=tmp[3];
ubc[2]=tmp[1];
tmp[]=Boundary{Surface{surf[4]};};
ubc[3]=tmp[1];

/*
b=surfaceBVL;
Call myExtrusion;
tunnelSurfaces[]+=newbase;
statorVolumes[]+=vol;
ubs[3]=surf[2];

b=surfaceC;
Call myExtrusion;
tunnelSurfaces[]+=newbase;
statorVolumes[]+=vol;
ubs[4]=surf[1];
tmp[]=Boundary{Surface{ubs[4]};};
ubc[4]=tmp[3];
ubc[5]=tmp[1];
ubs[5]=surf[2];

b=surfaceJet2;
Call myExtrusion;
tunnelSurfaces[]+=newbase;
statorVolumes[]+=vol;
ubs[6]=surf[2];
tmp[]=Boundary{Surface{ubs[6]};};
ubc[6]=tmp[3];
ubc[7]=tmp[1];

//tmp[]=ubc[];
//Call pt;
*/
