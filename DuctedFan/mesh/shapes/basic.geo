//Gmsh

LR = DC/20;//le radius.
DFA = 10*Pi/180;//rad, duct flare angle.

top=RCP*DC;
bottom=top-DC;

start=top-LR;
innerx=-RD/2;

Point(ce++)={innerx,start,0,DLS};ip=ce;
Point(ce++)={innerx-LR,start,0,DLS};cp=ce;
Point(ce++)={innerx-LR,top,0,DLS};tp=ce;
Point(ce++)={innerx+bottom*Tan(DFA),bottom,0,DLS};bp=ce;
Point(ce++)={innerx,0,0,DLS};rp=ce;

angle=Acos(LR/(Sqrt( (DC-LR)^2+(LR)^2 )));
Point(ce++)={innerx-LR+Cos(-angle-Pi/2)*LR,start+Sin(-angle-Pi/2)*LR,0,DLS};op=ce;


lns[]={};
Line(ce++)={bp,rp};lns[]+=ce;
Line(ce++)={rp,ip};lns[]+=ce;
Circle(ce++)={ip,cp,tp};lns[]+=ce;
Circle(ce++)={tp,cp,op};lns[]+=ce;
Line(ce++)={op,bp};lns[]+=ce;


