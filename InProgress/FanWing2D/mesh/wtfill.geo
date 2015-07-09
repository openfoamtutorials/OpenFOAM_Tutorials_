//Gmsh
/*
Needed:
outwardSurfaces[]
peripheralLines1[]
peripheralLines2[]
outwardLines1[]
outwardLines2[]
farsurfaces1[]
farsurfaces2[]
pplines[]
ubc[]
ubs[]
*/


peripheralSurfaces[]={};
For k In {0:11}
	lines[]={peripheralLines1[k],pplines[k],peripheralLines2[k],pplines[(k+1)%12]};
	Call autoLineLoop;
	Call PSS;
	peripheralSurfaces[]+=ce;
EndFor

//Printf("Debug");
outwardSurfaces[]={};
lines[]={outwardLines1[0],pplines[1],outwardLines2[0],ubc[0]};
Call autoLineLoop;
Call RSS;
//Printf("Debug");
//tmp[]=lines[];
//Call pt;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[1],pplines[2],outwardLines2[1],ubc[1]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[2],pplines[4],outwardLines2[2],ubc[1]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[3],pplines[5],outwardLines2[3],ubc[2]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[4],pplines[7],outwardLines2[4],ubc[2]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[5],pplines[8],outwardLines2[5],ubc[3]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[6],pplines[10],outwardLines2[6],ubc[3]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
lines[]={outwardLines1[7],pplines[11],outwardLines2[7],ubc[0]};
Call autoLineLoop;
Call RSS;
outwardSurfaces[]+=ce;
//tmp[]=lines[];
//Call pt;
//Printf("Debug");
Transfinite Surface{ubs[]};
Recombine Surface{ubs[]};
surf[]={farsurfaces1[0],farsurfaces2[0],outwardSurfaces[{0,7}],peripheralSurfaces[{0,11}]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[1],farsurfaces2[1],outwardSurfaces[{0,1}],peripheralSurfaces[1],ubs[0]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[2],farsurfaces2[2],outwardSurfaces[{1,2}],peripheralSurfaces[{2,3}]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[3],farsurfaces2[3],outwardSurfaces[{2,3}],peripheralSurfaces[4],ubs[1]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[4],farsurfaces2[4],outwardSurfaces[{3,4}],peripheralSurfaces[{5,6}]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[5],farsurfaces2[5],outwardSurfaces[{4,5}],peripheralSurfaces[7],ubs[2]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[6],farsurfaces2[6],outwardSurfaces[{5,6}],peripheralSurfaces[{8,9}]};
Call TV;
statorVolumes[]+=ce;
surf[]={farsurfaces1[7],farsurfaces2[7],outwardSurfaces[{6,7}],peripheralSurfaces[10],ubs[3]};
Call TV;
statorVolumes[]+=ce;
