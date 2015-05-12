//Gmsh
ftm=0.3048;//feet to meter.
itm=0.0254;//in to meter.

RD = 27*itm;//m, rotor diameter.
TG = 0.01*RD;//m, rotor tip gap.
DC = 0.3*RD;//m, duct chord.
BD = 45*RD;//m, boundary diameter.
RCP = 0.4;//rotor chord position, non-dimensionalized by chord.
LR = RD/20;//le radius of duct lip.

ICR = 0.5*RD/2;//m, inner core radius.
OCR = 0.75*RD/2;//m, outer core radius.

DLS = DC/75;//m, length characteristic of duct.
BLS = BD/50;//m, length characteristic of boundary.
TRCL = RD/50;//throughflow region characteristic length.

DT = DLS;//m, disk thickness.
URY = .35*RD;//m, unstructured radius in y direction.
URX = 0.8*RD;//m, unstructured radius in x direction.
URCL = RD/40;//m, unstructured region length characteristic.
RP = 1.1;//radial progression.

OCC = 10;//outer core cells.
OCP = 1.25;//outer core progression.
ICC = 10;//inner core cells.
RCC = 40;//radial cell count.
RDC = 30;//m, rotor disk cells.
AC = 50;//azimuthal cells.
TC = 50;//throughflow region cells.
EC = 50;//extrusion cells.
THC = {30, 40};//throughflow region cells.
THP = {1.075, 1.05};//throughflow region progressions.

AB = 0.3;//azimuthal bump.

//structured grid sizing.
FFC=30;FFP=1.2;

//diverge angle parameters, so that farfield mesh is not too high aspect ratio.
DDAA[]={3*Pi/180,3*Pi/180};
DDPP[]={1.15,1.1};

SDC=16;

//shape="0012.geo";//file name in 'shapes' folder.
