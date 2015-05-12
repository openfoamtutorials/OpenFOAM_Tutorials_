//Gmsh

DFA = 0*Pi/180;//rad, duct flare angle.
BLL = DC/20;//m, boundary layer length.
BLC = 10;//m, boundary layer cells.
BLP = 1.1;//boundary layer progression.
TEMAD = -10*Pi/180;//m, te mesh angle addition.
TELM = 2;//TE length multiplier.
TELP = 1.05;//TE length progression.
DLC = 2*LR/DLS;//duct lip cells.
OPAA=20*Pi/180;//outer point angle adjustment.

top=RCP*DC;
bottom=top-DC;

start=top-LR;
innerx=-RD/2;
dtex=innerx+bottom*Tan(DFA);//duct TE x.
dtey=bottom;//duct TE y.

Point(ce++)={innerx,start,0,DLS};ip=ce;
Point(ce++)={innerx-LR,start,0,DLS};cp=ce;
Point(ce++)={innerx-LR,top,0,DLS};tp=ce;
Point(ce++)={dtex,dtey,0,DLS};bp=ce;//Physical Point("test")={ce};
Point(ce++)={innerx,0,0,DLS};rp=ce;

//side1=(dtex-LR-RD/2)^2+(DC-LR)^2;
//side2=LR;
angle=Acos(LR/(Sqrt( (DC-LR)^2+(LR)^2 )));
//Point(ce++)={innerx-LR+Cos(-angle-Pi/2)*LR,start+Sin(-angle-Pi/2)*LR,0,DLS};op=ce;
Point(ce++)={innerx-LR*2+(1-Cos(OPAA))*LR,start-Sin(OPAA)*LR,0,DLS};op=ce;


ductlines[]={};
Line(ce++)={rp,bp};ductlines[]+=ce;
Line(ce++)={bp,op};ductlines[]+=ce;
Circle(ce++)={op,cp,tp};ductlines[]+=ce;
Circle(ce++)={tp,cp,ip};ductlines[]+=ce;
Line(ce++)={ip,rp};ductlines[]+=ce;

//boundary layer.
//points clockwise from rotor disk point.
pts[]+={};
//angle=-DFA/2;Call prepTrig;
//Point(ce++)={innerx+cs*BLL,sn*BLL,0};pts[]+=ce;
Point(ce++)={innerx+BLL,0,0};pts[]+=ce;//0
angle=-DFA-TEMAD;Call prepTrig;
Point(ce++)={dtex+cs*BLL,dtey+sn*BLL,0};pts[]+=ce;//1
angle=-Atan(TELM)-DFA-TEMAD;Call prepTrig;
Point(ce++)={dtex+cs*BLL*TELM*Sqrt(1+(1/TELM)^2),dtey+sn*BLL*TELM*Sqrt(1+(1/TELM)^2),0};pts[]+=ce;//2
angle=-Pi/2-DFA-TEMAD;Call prepTrig;
Point(ce++)={dtex+cs*BLL*TELM,dtey+sn*BLL*TELM,0};pts[]+=ce;//3
angle=-Pi+Atan(TELM)-DFA-TEMAD;Call prepTrig;
Point(ce++)={dtex+cs*BLL*TELM*Sqrt(1+(1/TELM)^2),dtey+sn*BLL*TELM*Sqrt(1+(1/TELM)^2),0};pts[]+=ce;//4
angle=-Pi-DFA-TEMAD;Call prepTrig;
Point(ce++)={dtex+cs*BLL,dtey+sn*BLL,0};pts[]+=ce;//5
//+(1-Cos(OPAA))*(LR+BLL)-Cos(OPAA)*(LR+BLL)
Point(ce++)={innerx-LR*2-BLL+(1-Cos(OPAA))*(LR+BLL),start-Sin(OPAA)*(LR+BLL),0,DLS};pts[]+=ce;//6
angle=-DFA/2;Call prepTrig;
Point(ce++)={innerx-LR,start+LR+BLL,0};pts[]+=ce;//7
Point(ce++)={innerx+BLL,start,0};pts[]+=ce;//8

//foo[]=Point{cp};
//Rotate {{0, 0, 1}, {foo[0],foo[1],0}, EA} {
//	Point{op,pts[6]};
//}

tangentlines[]={};
For kk In {0:#pts[]-4}
	Line(ce++)={pts[kk],pts[(kk+1)%(#pts[])]};tangentlines[]+=ce;
EndFor

Circle(ce++)={pts[6],cp,pts[7]};tangentlines[]+=ce;
Circle(ce++)={pts[7],cp,pts[8]};tangentlines[]+=ce;
Line(ce++)={pts[#pts[]-1],pts[0]};tangentlines[]+=ce;

bllines[]={};
Line(ce++)={rp,pts[0]};bllines[]+=ce;
Line(ce++)={bp,pts[1]};bllines[]+=ce;
Line(ce++)={bp,pts[3]};bllines[]+=ce;
Line(ce++)={bp,pts[5]};bllines[]+=ce;
Line(ce++)={op,pts[6]};bllines[]+=ce;
Line(ce++)={tp,pts[7]};bllines[]+=ce;
Line(ce++)={ip,pts[8]};bllines[]+=ce;

Transfinite Line{bllines[]}=BLC Using Progression BLP;
Transfinite Line{tangentlines[{1:4}]}=BLC;
Transfinite Line{tangentlines[0],ductlines[0]}=((1-RCP)*DC)/DLS;
Transfinite Line{tangentlines[5],ductlines[1]}=(DC-LR)/DLS;
Transfinite Line{tangentlines[{6,7}],ductlines[{2,3}]}=(Pi/2*LR)/DLS;
Transfinite Line{tangentlines[{8}],ductlines[{4}]}=SDC;//(RCP*DC-LR)/DLS;

Transfinite Line{bllines[2],tangentlines[1],-tangentlines[4]}=BLC Using Progression 1/TELP;
Transfinite Line{tangentlines[{6,7}],ductlines[{2,3}]}=DLC;

dir[]={0,1,0};ori[]={0,0,0};angle=5*Pi/180;cc=1;



lines[]={bllines[6],tangentlines[8],bllines[0],ductlines[4]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
ROTOR[]+=surf[0];
WEDGE1[]+=newbase;


lines[]={bllines[1],bllines[2],tangentlines[2],tangentlines[1]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
//DUCT[]+=surf[3];
WEDGE1[]+=newbase;

lines[]={bllines[2],bllines[3],tangentlines[4],tangentlines[3]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
//DUCT[]+=surf[3];
WEDGE1[]+=newbase;

lines[]={bllines[3],tangentlines[5],bllines[4],ductlines[1]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
WEDGE1[]+=newbase;

lines[]={bllines[4],tangentlines[6],bllines[5],ductlines[2]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
WEDGE1[]+=newbase;

lines[]={bllines[5],tangentlines[7],bllines[6],ductlines[3]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
//ROTOR[]+=surf[2];
WEDGE1[]+=newbase;

lines[]={bllines[0],tangentlines[0],bllines[1],ductlines[0]};
Call autoLineLoop;
Call PSS;
WEDGE0[]+=ce;
bb=ce;Call revolve;
AIR[]+=vol;
DUCT[]+=surf[3];
//ROTOR[]+=surf[0];
WEDGE1[]+=newbase;



lines[]=tangentlines[];
Call autoLineLoop;
ductblloop=ce;
