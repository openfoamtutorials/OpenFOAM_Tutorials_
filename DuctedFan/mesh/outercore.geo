//Gmsh

/*
pts[]={};
Point(ce++)={-ICR,BD/2-(0.5-RCP)*DC,0};pts[]+=ce;
Point(ce++)={-ICR,UR-(0.5-RCP)*DC,0,TRCL};pts[]+=ce;
Point(ce++)={-ICR,RCP*DC-LR,0,TRCL};pts[]+=ce;
Point(ce++)={-ICR,0,0,TRCL};pts[]+=ce;
Point(ce++)={-ICR,-UR-(0.5-RCP)*DC,0,TRCL};pts[]+=ce;
Point(ce++)={-ICR,-BD/2-(0.5-RCP)*DC,0};pts[]+=ce;
hlines[]={};
Line(ce++)={pp[0],pts[0]};hlines[]+=ce;
Line(ce++)={ups[0],pts[1]};hlines[]+=ce;
Line(ce++)={ocrp2,pts[2]};hlines[]+=ce;
Line(ce++)={ocrp,pts[3]};hlines[]+=ce;
Line(ce++)={ups[1],pts[4]};hlines[]+=ce;
Line(ce++)={pp[1],pts[5]};hlines[]+=ce;
*/

vlines[]={coreline,coreline1,coreline2,coreline3,coreline4};
//vlines[]={};
//Line(ce++)={pts[1],pts[0]};vlines[]+=ce;
//Line(ce++)={pts[1],pts[2]};vlines[]+=ce;
//Line(ce++)={pts[2],pts[3]};vlines[]+=ce;
//Line(ce++)={pts[3],pts[4]};vlines[]+=ce;
//Line(ce++)={pts[4],pts[5]};vlines[]+=ce;


//hlines[]={};
//Line(ce++)={pp[0],pts[0]};hlines[]+=ce;
//Line(ce++)={ups[0],pts[1]};hlines[]+=ce;
//Line(ce++)={ocrp2,pts[2]};hlines[]+=ce;
//Line(ce++)={ocrp,pts[3]};hlines[]+=ce;
//Line(ce++)={ups[1],pts[4]};hlines[]+=ce;
//Line(ce++)={pp[1],pts[5]};hlines[]+=ce;


pts[]={};
For kk In {0:#vlines[]-1}
	ids[]=Boundary{Line{vlines[kk]};};
	pts[]+=ids[1];
EndFor
ids[]=Boundary{Line{vlines[4]};};
pts[]+=ids[0];
hlines[]={};
Line(ce++)={pp[0],pts[0]};hlines[]+=ce;
Line(ce++)={ups[0],pts[1]};hlines[]+=ce;
Line(ce++)={ocrp2,pts[2]};hlines[]+=ce;
Line(ce++)={ocrp,pts[3]};hlines[]+=ce;
Line(ce++)={ups[1],pts[4]};hlines[]+=ce;
Line(ce++)={pp[1],pts[5]};hlines[]+=ce;


Transfinite Line{hlines[]}=OCC;
Transfinite Line{hlines[{0,5}]}=OCC Using Progression 1/OCP;
Transfinite Line{vlines[{0,4}]}=RCC Using Progression RP;
Transfinite Line{vlines[2]}=(RCP*DC-LR)/DLS;





lines[]={hlines[0],blines[0],hlines[1],vlines[0]};
Call autoLineLoop;
Call PSS;
SYMMETRY[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[0];
bb=newbase;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[0];
SYMMETRY[]+=newbase;

lines[]={hlines[1],ublines[1],hlines[2],vlines[1]};
Call autoLineLoop;
Call PSS;
SYMMETRY[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
ROTOR2[]+=surf[2];
bb=newbase;Call revolve;
AIR[]+=vol;
ROTOR2[]+=surf[2];
SYMMETRY[]+=newbase;

lines[]={hlines[2],ublines[0],hlines[3],vlines[2]};
Call autoLineLoop;
Call PSS;
SYMMETRY[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
ROTOR[]+=surf[2];
bb=newbase;Call revolve;
AIR[]+=vol;
ROTOR[]+=surf[2];
SYMMETRY[]+=newbase;

lines[]={hlines[3],ublines[3],hlines[4],vlines[3]};
Call autoLineLoop;
Call PSS;
SYMMETRY[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
bb=newbase;Call revolve;
AIR[]+=vol;
SYMMETRY[]+=newbase;

lines[]={hlines[4],blines[2],hlines[5],vlines[4]};
//Physical Line("test")=lines[];
Call autoLineLoop;
Call PSS;
SYMMETRY[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[2];
bb=newbase;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[2];
SYMMETRY[]+=newbase;

/*
ids[]=Boundary{Surface{ss2};};
//Physical Line("testLine")=ids[3];
lines[]={ids[3]};
ids[]=Boundary{Line{lines[0]};};

ids2[]=Boundary{Line{coreline};};
//pts[]={};
//Point(ce++)={-ICR,BD/2,0};pts[]+=ce;
//Point(ce++)={-ICR,UR,0};pts[]+=ce;

Line(ce++)={ids[0],ids2[1]};lines[]+=ce;
//Line(ce++)={pts[0],pts[1]};lines[]+=ce;
lines[]+=coreline;
Line(ce++)={ids2[0],ids[1]};lines[]+=ce;	connector1=ce;

Transfinite Line{lines[{1,3}]}=ICC;
//Transfinite Line{lines[2]}=RCC Using Progression RP;
//Physical Line("testLine")=lines[];

Call autoLineLoop;
Call PSS;
oc1=ce;//outer core 1.

//Above-disk section.
ids[]=Boundary{Line{usline1};};
ids2[]=Boundary{Line{coreline1};};
Line(ce++)={ids[0],ids2[0]};			connector2=ce;

Transfinite Line{connector2}=ICC;

lines[]={usline1,connector1,coreline1,connector2};
Call autoLineLoop;
Call PSS;
oc2=ce;

//Disk section.
ids[]=Boundary{Line{usline2};};
ids2[]=Boundary{Line{coreline2};};
Line(ce++)={ids[0],ids2[0]};			connector3=ce;

Transfinite Line{connector3}=ICC;

lines[]={usline2,connector2,coreline2,connector3};
Call autoLineLoop;
Call PSS;
oc3=ce;

//Below-disk section.
ids[]=Boundary{Line{usline3};};
ids2[]=Boundary{Line{coreline3};};
Line(ce++)={ids[0],ids2[0]};			connector4=ce;

Transfinite Line{connector4}=ICC;

lines[]={usline3,connector3,coreline3,connector4};
Call autoLineLoop;
Call PSS;
oc4=ce;

//Bottom freestream.
ids[]=Boundary{Line{usline4};};
ids2[]=Boundary{Line{coreline4};};
Line(ce++)={ids[1],ids2[0]};			connector5=ce;

Transfinite Line{connector5}=ICC;

lines[]={usline4,connector4,coreline4,connector5};
Call autoLineLoop;
Call PSS;
oc5=ce;
*/
