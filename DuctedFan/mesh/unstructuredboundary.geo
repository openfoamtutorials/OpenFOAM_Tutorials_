//Gmsh
SBC = 50;//structured bridge cells.
SBP = 1.04;//structured bridge progression.

someunstructuredlines[]={};

Point(ce++)={0,0,0,TRCL};ocrp=ce;
Point(ce++)={0,RCP*DC-LR,0,TRCL};ocrp2=ce;
//Point(ce++)={0,-(0.5-RCP)*DC,0};ubcp=ce;
ups[]={};
Point(ce++)={0,URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;
Point(ce++)={0,-URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;
Point(ce++)={-URX,-URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;
Point(ce++)={-URX,URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;

ids[]=Boundary{Line{tangentlines[#tangentlines[]-1]};};
ublines[]={};
Line(ce++)={ups[0],ocrp2};ublines[]+=ce;
Line(ce++)={ocrp2,ids[0]};ublines[]+=ce;
Line(ce++)={ocrp2,ocrp};ublines[]+=ce;
Line(ce++)={ocrp,ids[1]};ublines[]+=ce;
Line(ce++)={ocrp,ups[1]};ublines[]+=ce;
Line(ce++)={ups[1],ups[2]};ublines[]+=ce;someunstructuredlines[]+=ce;
Line(ce++)={ups[2],ups[3]};ublines[]+=ce;someunstructuredlines[]+=ce;
Line(ce++)={ups[3],ups[0]};ublines[]+=ce;someunstructuredlines[]+=ce;//7

Transfinite Line{ublines[{1,3}]}=SBC Using Progression 1/SBP;
Transfinite Line{ublines[{2}]}=SDC;//(RCP*DC-LR)/DLS;
Transfinite Line{ublines[{4}]}=(-(-URY-(0.5-RCP)*DC))/TRCL;
Transfinite Line{ublines[{0}]}=((URY-(0.5-RCP)*DC)-(RCP*DC-LR))/TRCL;


Transfinite Line{someunstructuredlines[{0,2}]}=URX/URCL;
Transfinite Line{someunstructuredlines[1]}=2*URY/URCL;

dir[]={0,1,0};ori[]={0,0,0};angle=5*Pi/180;cc=1;

lines[]={tangentlines[{0:7}],ublines[{1,0,7,6,5,4,3}]};
Call autoLineLoop;
Call PSU2;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
ROTOR[]+=surf[8];
WEDGE1[]+=newbase;

lines[]={tangentlines[8],ublines[{1,2,3}]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
//ROTOR[]+=surf[1];
WEDGE1[]+=newbase;

/*
Line(ce++)={ocrp,ups[0]};lfix=ce;
Transfinite Line{lfix}=((URY-(0.5-RCP)*DC)-(RCP*DC-LR))/TRCL;
lines[]={tangentlines[],ublines[3],lfix,ublines[{7,6,5,4,3}]};
Call autoLineLoop;
Call PSU2;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
ROTOR[]+=surf[#tangentlines[]];
WEDGE1[]+=newbase;
*/





/*
Line(ce++)={ocrp,ocrp2};ublines[]+=ce;
Line(ce++)={ocrp2,ups[0]};ublines[]+=ce;
Circle(ce++)={ups[0],ubcp,ups[1]};ublines[]+=ce;
//Circle(ce++)={ups[1],ubcp,ups[2]};ublines[]+=ce;
//Line(ce++)={ups[2],ocrp};ublines[]+=ce;
Line(ce++)={ups[1],ocrp};ublines[]+=ce;

ids[]=Boundary{Line{tangentlines[8]};};
Line(ce++)={ids[0],ocrp2};sbl1=ce;
Line(ce++)={ids[1],ocrp};sbl2=ce;

Transfinite Line{ublines[0]}=(RCP*DC-LR)/DLS;
Transfinite Line{sbl1,sbl2}=SBC Using Progression SBP;
Transfinite Line{ublines[2]}=AC+1 Using Bump AB;
Transfinite Line{ublines[1]}=THC[0]+1 Using Progression THP[0];
Transfinite Line{ublines[3]}=THC[1]+1 Using Progression 1/THP[1];

dir[]={0,1,0};ori[]={0,0,0};angle=5*Pi/180;cc=1;

lines[]={sbl1,ublines[0],sbl2,tangentlines[8]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
ROTOR[]+=surf[2];
ROTOR2[]+=surf[0];
WEDGE1[]+=newbase;


lines[]={sbl1,ublines[{1:3}],sbl2,tangentlines[{0:7}]};
Call autoLineLoop;
Call PSU;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
WEDGE1[]+=newbase;
*/





/*
lines[]=ublines[];
Call autoLineLoop;

Plane Surface(ce++)={ce-1,ductblloop};
*/
