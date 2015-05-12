//Gmsh

pts[]={};
Point(ce++)={0,BD/2-(0.5-RCP)*DC,0,TRCL};pts[]+=ce;
Point(ce++)={-ICR,BD/2-(0.5-RCP)*DC,0,TRCL};tp=ce;
Point(ce++)={0,BD/2-(0.5-RCP)*DC,ICR,TRCL};pts[]+=ce;
Point(ce++)={ICR,BD/2-(0.5-RCP)*DC,0,TRCL};pts[]+=ce;

//ids[]=Boundary{Line{vlines[0]};};
//tp=ids[1];
//Characteristic Length { tp } = TRCL;
lines[]={};
Circle(ce++)={tp,pts[0],pts[1]};lines[]+=ce;
Circle(ce++)={pts[1],pts[0],pts[2]};lines[]+=ce;
//Line(ce++)={pts[2],pts[0]};lines[]+=ce;
//Line(ce++)={pts[0],pt};lines[]+=ce;

Line(ce++)={pts[2],tp};lines[]+=ce;//l2[]+=ce;

Transfinite Line{lines[{0,1}]}=EC/2+1;

Call autoLineLoop;
Call PSU;

FREESTREAM[]+=ce;

b=ce;l[]={0,-BD/2+UR,0};p=1/RP;c=RCC-1;Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline=ids[3];
//Physical Line("testLine")=coreline;
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-(UR-0.5*DC+LR),0};p=1/THP[0];c=THC[0];Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline1=ids[3];
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-RCP*DC+LR,0};p=1;c=(RCP*DC-LR)/DLS-1;Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline2=ids[3];
SYMMETRY[]+=surf[2];
ROTOR[]+=newbase;

b=newbase;
l[]={0,-(UR+(0.5-RCP)*DC),0};p=THP[1];c=THC[1];Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline3=ids[3];
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-(BD/2-UR),0};p=RP;c=RCC-1;Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline4=ids[3];
SYMMETRY[]+=surf[2];
FREESTREAM[]+=newbase;

/*
//p2[]={};
//Point(ce++)={ICR,UR,0};p2[]+=ce;
//Point(ce++)={-ICR,UR,0};p2[]+=ce;
///l2[]={};
//Line(ce++)={pt,p2[1]};l2[]+=ce;coreline=ce;
//Line(ce++)={p2[0],p2[1]};l2[]+=ce;
//Line(ce++)={pts[2],p2[0]};l2[]+=ce;
//lines[]=l2[];
//Call autoLineLoop;
//Call PSS;

//ids[]=Boundary{Surface{oc1};};
//ids[]=Boundary{Line{ids[2]};};
//pt=ids[0];
//Physical Point("testPoint")=pt;

lines[]={};
Circle(ce++)={pt,pts[0],pts[1]};lines[]+=ce;
Circle(ce++)={pts[1],pts[0],pts[2]};lines[]+=ce;
//Line(ce++)={pts[2],pts[0]};lines[]+=ce;
//Line(ce++)={pts[0],pt};lines[]+=ce;
Line(ce++)={pts[2],pt};lines[]+=ce;//l2[]+=ce;

Transfinite Line{lines[{2}]}=RDC;
//Transfinite Line{lines[{2}],l2[1]}=RDC;
//Transfinite Line{lines[{2,3}]}=RDC/2;
Transfinite Line{lines[{0,1}]}=EC/2+1;
//Transfinite Line{l2[{0,2}]}=RCC Using Progression 1/RP;

Call autoLineLoop;
Call RSU;

FREESTREAM[]+=ce;
b=ce;l[]={0,-(BD/2-UR),0};p=1/RP;c=RCC-1;Call extrude;
AIR[]+=vol;
//Physical Surface("testSurface")=surf[0];
ids[]=Boundary{Surface{surf[0]};};
coreline=ids[3];
//Physical Line("testLine")=coreline;
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-(UR-DT/2),0};p=1;c=TC-1;Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline1=ids[3];
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-DT,0};p=1;c=1;Call extrude;
ROTOR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline2=ids[3];
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-(UR-DT/2),0};p=1;c=TC-1;Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline3=ids[3];
SYMMETRY[]+=surf[2];

b=newbase;
l[]={0,-(BD/2-UR),0};p=RP;c=RCC-1;Call extrude;
AIR[]+=vol;
ids[]=Boundary{Surface{surf[0]};};
coreline4=ids[3];
SYMMETRY[]+=surf[2];
FREESTREAM[]+=newbase;
*/





/*
//make new base surface for center extrusion.
TP[]={};//top points.
ids[]=Boundary{Line{TL[0]};};
TP[]+=ids[0];
testPoints[]+=ids[];
ids[]=Boundary{Line{TL[1]};};
TP[]+=ids[1];
testPoints[]+=ids[];
Line(ce++)=TP[];
Transfinite Line{ce}=RDC;
lines[]={TL[],ce};Call autoLineLoop;
Call PSU;

b=ce;l={0,(BD/2-UR),0};p=RP;c=RCC-1;Call extrude;
//Transfinite Volume{vol};
AIR[]+=vol;
Physical Volume("air1") = vol;
SYMMETRY[]+=surf[2];
//Transfinite Surface{surf[{}]};
//Recombine Surface{surf[]};
*/
