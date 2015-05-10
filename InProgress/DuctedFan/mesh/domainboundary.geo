//Gmsh

//outer boundary
pp[]={};
DD=BD/2-(0.5-RCP)*DC;
Point(ce++)={0,DD,0};pp[]+=ce;
Point(ce++)={-URX-Tan(DDAA[1])*DD,DD,0};pp[]+=ce;
Point(ce++)={-BD/2,DD,0};pp[]+=ce;

DD=-BD/2;
Point(ce++)={DD,URY-(0.5-RCP)*DC-Tan(DDAA[0])*DD,0};pp[]+=ce;
Point(ce++)={DD,-URY-(0.5-RCP)*DC+Tan(DDAA[0])*DD,0};pp[]+=ce;

DD=-BD/2-(0.5-RCP)*DC;
Point(ce++)={-BD/2,DD,0};pp[]+=ce;
Point(ce++)={-URX+Tan(DDAA[1])*DD,DD,0};pp[]+=ce;
Point(ce++)={0,DD,0};pp[]+=ce;

pts0[]=Boundary{Line{someunstructuredlines[0]};};
pts1[]=Boundary{Line{someunstructuredlines[1]};};
pts2[]=Boundary{Line{someunstructuredlines[2]};};
ups[]={pts2[1],pts2[0],pts1[0],pts0[0]};
//tmp[]=ups[];Call pt;

blines[]={};
For kk In {0:#pp[]-2}
	Line(ce++)={pp[kk],pp[(kk+1)%#pp[]]};blines[]+=ce;
EndFor
olines[]={};
Line(ce++)={ups[0],pp[0]};olines[]+=ce;
Line(ce++)={ups[1],pp[1]};olines[]+=ce;

Line(ce++)={ups[1],pp[3]};olines[]+=ce;
Line(ce++)={ups[2],pp[4]};olines[]+=ce;

Line(ce++)={ups[2],pp[6]};olines[]+=ce;
Line(ce++)={ups[3],pp[7]};olines[]+=ce;

//Transfinite Line{olines[],blines[{1,4}]}=FFC Using Progression FFP;
Transfinite Line{olines[]}=FFC Using Progression FFP;
//Transfinite Line{blines[{2,5}]}=FFC Using Progression 1/FFP;
Transfinite Line{blines[{0,6}]}=URX/URCL;
Transfinite Line{blines[3]}=2*URY/URCL;


Transfinite Line{blines[1]}=FFC Using Progression DDPP[0];
Transfinite Line{blines[5]}=FFC Using Progression 1/DDPP[0];
Transfinite Line{blines[4]}=FFC Using Progression DDPP[1];
Transfinite Line{blines[2]}=FFC Using Progression 1/DDPP[1];

lines[]={olines[0],blines[0],olines[1],someunstructuredlines[2]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
INLET[]+=surf[0];
WEDGE1[]+=newbase;
lines[]={olines[1],blines[1],blines[2],olines[2]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
INLET[]+=surf[1];
TUNNEL[]+=surf[2];
WEDGE1[]+=newbase;
lines[]={olines[2],blines[3],olines[3],someunstructuredlines[1]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
TUNNEL[]+=surf[1];
WEDGE1[]+=newbase;
lines[]={olines[3],blines[4],blines[5],olines[4]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
OUTLET[]+=surf[2];
TUNNEL[]+=surf[1];
WEDGE1[]+=newbase;
lines[]={olines[4],blines[6],olines[5],someunstructuredlines[0]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
OUTLET[]+=surf[1];
WEDGE1[]+=newbase;





/*
blines[]={};
Line(ce++)={ups[0],pp[0]};blines[]+=ce;
Circle(ce++)={pp[0],ubcp,pp[1]};blines[]+=ce;
Line(ce++)={ups[1],pp[1]};blines[]+=ce;


Transfinite Line{blines[1]}=AC+1 Using Bump AB;
Transfinite Line{blines[{0,2}]}=RCC Using Progression RP;

lines[]={blines[],ublines[2]};
Call autoLineLoop;
Call PSS;
SYMMETRY[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[1];
bb=newbase;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[1];
SYMMETRY[]+=newbase;
*/
