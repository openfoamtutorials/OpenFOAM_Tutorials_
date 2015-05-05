//Inputs
plateChord = 1;
width = 20*plateChord;
height = 10*plateChord;
neargridsize = 0.0125*plateChord;
fargridsize = 1*plateChord;
celldepth = 0.1*plateChord;

ce = 0;
pts[] = {};
Point(ce++) = {0,0,0,fargridsize};pts[]+=ce;
Point(ce++) = {width,0,0,fargridsize};pts[]+=ce;
Point(ce++) = {width,height,0,fargridsize};pts[]+=ce;
Point(ce++) = {0,height,0,fargridsize};pts[]+=ce;

lns[] = {};
Line(ce++) = {pts[0],pts[1]};lns[]+=ce;
Line(ce++) = {pts[1],pts[2]};lns[]+=ce;
Line(ce++) = {pts[2],pts[3]};lns[]+=ce;
Line(ce++) = {pts[3],pts[0]};lns[]+=ce;

Line Loop(ce++) = lns[];
Plane Surface(ce++) = ce-1;tunnel=ce;

pts[] = {};
Point(ce++) = {width/2,height/2-plateChord/2,0,neargridsize};pts[]+=ce;
Point(ce++) = {width/2,height/2+plateChord/2,0,neargridsize};pts[]+=ce;

Line(ce++) = pts[];plate=ce;
Line{plate} In Surface{tunnel};

newEntities[] = 
Extrude { 0,0,celldepth }
{
	Surface{tunnel};
	Layers{1};
	Recombine;
};
