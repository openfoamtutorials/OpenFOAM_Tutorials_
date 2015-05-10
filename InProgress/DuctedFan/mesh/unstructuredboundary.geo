//Gmsh
SBC = 60;//structured bridge cells.
SBP = 1.04;//structured bridge progression.
SBB = 0.25;//structured bridge bump.

someunstructuredlines[]={};

//Point(ce++)={0,0,0,TRCL};ocrp=ce;
//Point(ce++)={0,RCP*DC-LR,0,TRCL};ocrp2=ce;
//Point(ce++)={0,-(0.5-RCP)*DC,0};ubcp=ce;
ups[]={};
Point(ce++)={0,URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;
Point(ce++)={0,-URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;
Point(ce++)={-URX,-URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;
Point(ce++)={-URX,URY-(0.5-RCP)*DC,0,TRCL};ups[]+=ce;

ids[]=Boundary{Line{tangentlines[#tangentlines[]-1]};};
ublines[]={};
bridgelines[]={};
Line(ce++)={ups[0],nacelleendpoints[0]};ublines[]+=ce;
Line(ce++)={nacelleendpoints[1],ups[1]};ublines[]+=ce;
Line(ce++)={ups[1],ups[2]};someunstructuredlines[]+=ce;
Line(ce++)={ups[2],ups[3]};someunstructuredlines[]+=ce;
Line(ce++)={ups[3],ups[0]};someunstructuredlines[]+=ce;//7

Line(ce++)={nacellebridgep[0],ids[0]};bridgelines[]+=ce;
Line(ce++)={nacellebridgep[1],ids[1]};bridgelines[]+=ce;


Transfinite Line{bridgelines[]}=SBC Using Bump SBB;
//Transfinite Line{ublines[{2}]}=SDC;//(RCP*DC-LR)/DLS;
Transfinite Line{ublines[0]}=NACC[0] Using Progression 1/NACP[0];
Transfinite Line{ublines[1]}=NACC[1] Using Progression NACP[1];

Transfinite Line{someunstructuredlines[{0,2}]}=URX/URCL;
Transfinite Line{someunstructuredlines[1]}=2*URY/URCL;

dir[]={0,1,0};ori[]={0,0,0};angle=5*Pi/180;cc=1;





lines[]={tangentlines[{0:7}],bridgelines[0],nacellecircumscribe[0],ublines[0],someunstructuredlines[{2:0}],ublines[1],nacellecircumscribe[{4:2}],bridgelines[1]};
//NNN=#lines[]-1;
Call autoLineLoop;
Call PSU2;
//Plane Surface(ce++)={ce-1, elementLoops[]};
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
ROTOR[]+=surf[16];
//DUCT[]+=surf[{13:12+#elementLoops[]*3}];
WEDGE1[]+=newbase;



lines[]={tangentlines[8],bridgelines[1],nacellecircumscribe[1],bridgelines[0]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
//ROTOR[]+=surf[1];
//ROTOR[]+=surf[1];
WEDGE1[]+=newbase;
