//Gmsh

pp[]={};
Point(ce++)={wtBoundDim[0]/2,wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={uBoundCenter[0]+uBoundDim[0]/2+topAdjustment[1],wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={uBoundCenter[0]-uBoundDim[0]/2+topAdjustment[0],wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={-wtBoundDim[0]/2,wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={-wtBoundDim[0]/2,uBoundCenter[1]+uBoundDim[1]/2+frontAdjustment[0],z};pp[]+=ce;
Point(ce++)={-wtBoundDim[0]/2,uBoundCenter[1]-uBoundDim[1]/2+frontAdjustment[1],z};pp[]+=ce;
Point(ce++)={-wtBoundDim[0]/2,-wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={uBoundCenter[0]-uBoundDim[0]/2+bottomAdjustment[0],-wtBoundDim[1]/2,z};pp[]+=ce;
//Point(ce++)={uBoundAdapt[0]+bottomAdjustment[1],-wtBoundDim[1]/2,z};pp[]+=ce;
//Point(ce++)={uBoundAdapt[1]+bottomAdjustment[2],-wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={uBoundCenter[0]+uBoundDim[0]/2+bottomAdjustment[3],-wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={wtBoundDim[0]/2,-wtBoundDim[1]/2,z};pp[]+=ce;
Point(ce++)={wtBoundDim[0]/2,uBoundCenter[1]-uBoundDim[1]/2+backAdjustment[3],z};pp[]+=ce;
//Point(ce++)={wtBoundDim[0]/2,uBoundAdapt[2]+backAdjustment[2],z};pp[]+=ce;
//Point(ce++)={wtBoundDim[0]/2,uBoundAdapt[3]+backAdjustment[1],z};pp[]+=ce;
Point(ce++)={wtBoundDim[0]/2,uBoundCenter[1]+uBoundDim[1]/2+backAdjustment[0],z};pp[]+=ce;

peripheralLines[]={};
For nnn In {0:#pp[]-1}
	Line(ce++)={pp[nnn],pp[(nnn+1)%(#pp[])]};peripheralLines[]+=ce;
EndFor
outwardLines[]={};
Line(ce++)={p[0],pp[1]};outwardLines[]+=ce;//0
Line(ce++)={p[1],pp[2]};outwardLines[]+=ce;
Line(ce++)={p[1],pp[4]};outwardLines[]+=ce;
Line(ce++)={p[2],pp[5]};outwardLines[]+=ce;
Line(ce++)={p[2],pp[7]};outwardLines[]+=ce;
Line(ce++)={p[3],pp[8]};outwardLines[]+=ce;
Line(ce++)={p[3],pp[10]};outwardLines[]+=ce;
Line(ce++)={p[0],pp[11]};outwardLines[]+=ce;

For nnn In {0:3}
	Transfinite Line{outwardLines[{nnn*2,nnn*2+1}]}=outwardCells[nnn]+1 Using Progression outwardProgressions[nnn];
EndFor
Transfinite Line{peripheralLines[1]}=middleCells[1]+1;
Transfinite Line{peripheralLines[4]}=middleCells[0]+1;
Transfinite Line{peripheralLines[7]}=middleCells[3]+1;
Transfinite Line{peripheralLines[10]}=middleCells[2]+1;

Transfinite Line{peripheralLines[11]}=outwardCells[1]+1 Using Progression outwardProgressions[1];
Transfinite Line{peripheralLines[3]}=outwardCells[1]+1 Using Progression 1/outwardProgressions[1];
Transfinite Line{peripheralLines[2]}=outwardCells[0]+1 Using Progression outwardProgressions[0];
Transfinite Line{peripheralLines[6]}=outwardCells[0]+1 Using Progression 1/outwardProgressions[0];
Transfinite Line{peripheralLines[5]}=outwardCells[3]+1 Using Progression outwardProgressions[3];
Transfinite Line{peripheralLines[9]}=outwardCells[3]+1 Using Progression 1/outwardProgressions[3];
Transfinite Line{peripheralLines[8]}=outwardCells[2]+1 Using Progression outwardProgressions[2];
Transfinite Line{peripheralLines[0]}=outwardCells[2]+1 Using Progression 1/outwardProgressions[2];

farsurfaces[]={};
lines[]={outwardLines[7],outwardLines[0],peripheralLines[0],peripheralLines[11]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;
lines[]={outwardLines[0],peripheralLines[1],outwardLines[1],uboundlines[0]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;
lines[]={outwardLines[1],outwardLines[2],peripheralLines[3],peripheralLines[2]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;
lines[]={outwardLines[2],peripheralLines[4],outwardLines[3],uboundlines[1]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;
lines[]={outwardLines[3],outwardLines[4],peripheralLines[6],peripheralLines[5]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;

lines[]={outwardLines[4],peripheralLines[7],outwardLines[5],uboundlines[2]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;
lines[]={outwardLines[5],outwardLines[6],peripheralLines[9],peripheralLines[8]};
Call autoLineLoop;
Call PSS;

farsurfaces[]+=ce;
lines[]={outwardLines[6],peripheralLines[10],outwardLines[7],uboundlines[3]};
Call autoLineLoop;
Call PSS;
farsurfaces[]+=ce;


