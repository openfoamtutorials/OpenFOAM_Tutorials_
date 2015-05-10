//Gmsh

surfsp[]={};//surface spline points.
blsp[]={};//bl/tangent spline points.
surfp[]={};//surface points.
blp[]={};//bl/tangent points.
surfl[]={};//surface lines.
bll[]={};//boundary layer/tangent lines.
ol[]={};//outward lines.

BH=RCP*DC-LR;

Point(ce++)={0,NR+BH,0};surfp[]+=ce;
Point(ce++)={-NR,BH,0};surfp[]+=ce;
Point(ce++)={-NR,0,0};surfp[]+=ce;
Point(ce++)={0,-NTEY,0};surfp[]+=ce;
Point(ce++)={0,-NTEY-TELM*BLL,0};surfp[]+=ce;

Point(ce++)={0,BH,0};nc=ce;

Point(ce++)={-NR,-NSPL+BH,0};surfsp[]+=ce;
Point(ce++)={-NR-BLL,-NSPL+BH,0};blsp[]+=ce;


Circle(ce++)={surfp[0],nc,surfp[1]};surfl[]+=ce;
Line(ce++)={surfp[1],surfp[2]};surfl[]+=ce;
BSpline(ce++)={surfp[2],surfsp[],surfp[3]};surfl[]+=ce;
Line(ce++)={surfp[3],surfp[4]};surfl[]+=ce;


Point(ce++)={0,NR+BLL+BH,0};blp[]+=ce;
Point(ce++)={-NR-BLL,BH,0};blp[]+=ce;
Point(ce++)={-NR-BLL,0,0};blp[]+=ce;
Point(ce++)={-BLL*Cos(NTEBLA),-NTEY-BLL*Sin(NTEBLA),0};blp[]+=ce;
Point(ce++)={-BLL,-NTEY-TELM*BLL,0};blp[]+=ce;


Circle(ce++)={blp[0],nc,blp[1]};bll[]+=ce;
Line(ce++)={blp[1],blp[2]};bll[]+=ce;
BSpline(ce++)={blp[2],blsp[],blp[3]};bll[]+=ce;
Line(ce++)={blp[3],blp[4]};bll[]+=ce;


For kk In {0:4}
	Line(ce++)={surfp[kk],blp[kk]};ol[]+=ce;
EndFor


For kk In {0:0}
	lines[]={ol[kk],surfl[kk],ol[kk+1],bll[kk]};
	Call autoLineLoop;
EndFor






Transfinite Line{ol[]}=BLC Using Progression BLP;
Transfinite Line{ol[#ol[]-1]}=BLC;
Transfinite Line{bll[2],surfl[2]}=((1-RCP)*DC)/DLS;
Transfinite Line{bll[0],surfl[0]}=(Pi/2*NR)/DLS;
Transfinite Line{bll[1],surfl[1]}=SDC;
Transfinite Line{bll[3],surfl[3]}=BLC Using Progression 1/TELP;




dir[]={0,1,0};ori[]={0,0,0};angle=5*Pi/180;cc=1;


lines[]={ol[1],bll[1],ol[2],surfl[1]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
ROTOR[]+=surf[2];
WEDGE1[]+=newbase;


lines[]={ol[2],bll[2],ol[3],surfl[2]};
Call autoLineLoop;
	Plane Surface(ce++)=ce-1;
	//Recombine Surface{ce};
	Transfinite Surface{ce};
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
//ROTOR[]+=surf[0];
WEDGE1[]+=newbase;



lines[]={ol[0],bll[0],ol[1],surfl[0]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[2];
//ROTOR[]+=surf[0];
WEDGE1[]+=newbase;



lines[]={ol[3],bll[3],ol[4],surfl[3]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
//DUCT[]+=surf[2];
//ROTOR[]+=surf[0];
WEDGE1[]+=newbase;

nacelleendpoints[]={blp[0],surfp[#surfp[]-1]};
nacellecircumscribe[]={bll[],ol[#ol[]-1]};
nacellebridgep[]={blp[1],blp[2]};

