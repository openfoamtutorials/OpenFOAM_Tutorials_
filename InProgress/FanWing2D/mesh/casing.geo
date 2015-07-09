//Gmsh
//Casing drawing given o, z, jetAngle, and jetLength.

circles1[]={};
circles2[]={};

//Front casing
s=Sin(-cornerAngle);
c=Cos(-cornerAngle);
Point(ce++)={cr*c,cr*s,z,interfacels};corner=ce;
s=Sin(lipAngles[0]+Pi);
c=Cos(lipAngles[0]+Pi);
Point(ce++)={cr*c,cr*s,z,interfacels};inlip=ce;
Circle(ce++)={corner,o,inlip};innerLine=ce;
s=Sin(lipAngles[1]+Pi);
c=Cos(lipAngles[1]+Pi);
Point(ce++)={(cr+ct)*c,(cr+ct)*s,z,lipls};outlip=ce;
//Point(ce++)={lipcoord[0],lipcoord[1],z,lipls};outlip=ce;
Line(ce++)={inlip,outlip};inLine=ce;
Point(ce++)={0,-(cr+ct),z,bottomls};bottom=ce;
Circle(ce++)={outlip,o,bottom};outLine=ce;
//Line(ce++)={outlip,bottom};outLine=ce;
//Te calculation
s=Sin(-cornerAngle);
c=Cos(-cornerAngle);
ss=Sin(jetAngle);
cc=Cos(jetAngle);
Point(ce++)={c*cr+jetLength*cc,s*cr-ss*jetLength,z,tels};te=ce;
//Bottom and jet
Line(ce++)={bottom,te};bottomLine=ce;
Line(ce++)={te,corner};jetLine=ce;

ss=Sin(Pi/2-plateAngle[0]);
cc=Cos(Pi/2-plateAngle[0]);
tdc[]={cc*cr,ss*cr};
Point(ce++)={tdc[0],tdc[1],z,interfacels};topDisk=ce;

periphery[]={};
Circle(ce++)={inlip,o,topDisk};
periphery[]+=ce;

//sps[]={};
//Point(ce++)={ssx[0],ssy[0],0,sls[0]};sps[]+=ce;
//Line(ce++)={topDisk,sps[0]};topdiskbaffle=ce;
//periphery[]+=ce;
/*
If(#ssx[]>2)
	For nn In {1:#ssx[]-2}
		Point(ce++)={ssx[nn],ssy[nn],0};sps[]+=ce;
	EndFor
EndIf
*/
//If(#ssx[]==3)
//	Point(ce++)={ssx[1],ssy[1],0};sps[]+=ce;
//EndIf
//Point(ce++)={ssx[#ssx[]-1],ssy[#ssx[]-1],0,sls[1]};sps[]+=ce;topCorner=ce;
//BSpline(ce++)={sps[]};baffleLine=ce;
//periphery[]+=ce;

//Line(ce++)={sps[(#ssx[]-1)],te};aftLine=ce;
//periphery[]+=ce;

Circle(ce++)={topDisk,o,corner};topdiskcorner=ce;
periphery[]+=topdiskcorner;
periphery[]+=jetLine;
periphery[]+=bottomLine;
periphery[]+=outLine;
periphery[]+=inLine;


/*
lines[]={jetLine,topdiskcorner,topdiskbaffle,baffleLine,aftLine};
Call autoLineLoop;
Call PSU;
plateSurface=ce;
symmetrySurfaces[]+=plateSurface;
*/
/*
l=span;
c=spanCells;
p=spanProgression;
b=plateSurface;
Call myExtrusion;
casingSurfaces[]+=surf[0];
baffleSurfaces[]+=surf[3];
statorVolumes[]+=vol;
capSurfaces[]+=newbase;
*/
/*
Point(ce++)={plateSpline2[0],plateSpline2[1],z,interfacels};somepoint=ce;
BSpline(ce++)={corner,somepoint,adapt};corneradapt=ce;
fraction=(uBoundAdapt[3]-uBoundAdapt[2])/uBoundDim[1];
Transfinite Line{ce}=fraction*middleCells[2]+1+additionalJetCells[1] Using Progression jetInflation;

Transfinite Line{jetLine}=jetCells+1 Using Progression 1/jetProgression;
Transfinite Line{bottomLine}=bottomCells+1 Using Progression bottomProgression;

Line Loop(ce++)={-jetLine,-periphery[4],-periphery[3],-corneradapt};
Plane Surface(ce++)=ce-1;jetplate=ce;
symmetrySurfaces[]+=jetplate;
Recombine Surface{ce};
Transfinite Surface{ce};
*/

//Near Interface
pts[]={};
r=cr-gap/2;
s=Sin(lipAngles[0]+Pi);
c=Cos(lipAngles[0]+Pi);
Point(ce++)={r*c,r*s,z};pts[]+=ce;
s=Sin(-cornerAngle);
c=Cos(-cornerAngle);
Point(ce++)={r*c,r*s,z};pts[]+=ce;
s=Sin(Pi/2-plateAngle[0]);
c=Cos(Pi/2-plateAngle[0]);
Point(ce++)={r*c,r*s,z};pts[]+=ce;
Circle(ce++)={pts[0],o,pts[1]};circles2[]+=ce;
Circle(ce++)={pts[1],o,pts[2]};circles2[]+=ce;
Circle(ce++)={pts[2],o,pts[0]};circles2[]+=ce;

ringCells=2*Pi*cr/interfacels;
cells=(Pi-lipAngles[0]-cornerAngle)/2/Pi*ringCells;
Transfinite Line{innerLine,circles2[0]}=cells+1;
cells=(Pi/2+lipAngles[0]+plateAngle)/2/Pi*ringCells;
Transfinite Line{periphery[0],circles2[2]}=cells+1;
cells=(Pi/2-plateAngle+cornerAngle)/2/Pi*ringCells;
Transfinite Line{topdiskcorner,circles2[1]}=cells+1;

ol[]={};
Line(ce++)={pts[0],inlip};ol[]+=ce;
Line(ce++)={pts[1],corner};ol[]+=ce;
Line(ce++)={pts[2],topDisk};ol[]+=ce;
Transfinite Line{ol[]}=gapCells+1;

/*
Line Loop(ce++)={corneradapt,-periphery[1],-periphery[2],topdiskcorner};
Plane Surface(ce++)=ce-1;adaptSurface=ce;
Recombine Surface{ce};
l=span;
c=spanCells;
p=spanProgression;
b=adaptSurface;
symmetrySurfaces[]+=adaptSurface;
Call myExtrusion;
capSurfaces[]+=newbase;
newAdaptSurface=newbase;
cornerAdaptSurface=surf[0];
baffleSurfaces[]+=surf[1];
statorVolumes[]+=vol;
*/

nears[]={};
Line Loop(ce++)={ol[0],periphery[0],-ol[2],circles2[2]};
//Printf("%g,%g,%g,%g",ol[0],periphery[0],-ol[2],circles2[2]);
Plane Surface(ce++)=ce-1;
Recombine Surface{ce};
Transfinite Surface{ce};
nears[]+=ce;

Line Loop(ce++)={ol[2],topdiskcorner,-ol[1],circles2[1]};
Plane Surface(ce++)=ce-1;
Recombine Surface{ce};
Transfinite Surface{ce};
nears[]+=ce;

Line Loop(ce++)={ol[1],innerLine,-ol[0],circles2[0]};
Plane Surface(ce++)=ce-1;
Recombine Surface{ce};
Transfinite Surface{ce};
nears[]+=ce;

symmetrySurfaces[]+=nears[];

l=span;
c=spanCells;
p=spanProgression;
b=nears[0];
Call myExtrusion;
statorInterfaceSurfaces[]+=surf[3];
statorVolumes[]+=vol;
//capSurfaces[]+=newbase;
//tunnelSurfaces[]+=newbase;
l=span;
c=spanCells;
p=spanProgression;
b=nears[1];
Call myExtrusion;
statorInterfaceSurfaces[]+=surf[3];
statorVolumes[]+=vol;
//capSurfaces[]+=newbase;
//tunnelSurfaces[]+=newbase;
l=span;
c=spanCells;
p=spanProgression;
b=nears[2];
Call myExtrusion;
casingSurfaces[]+=surf[1];
statorInterfaceSurfaces[]+=surf[3];
statorVolumes[]+=vol;
//capSurfaces[]+=newbase;
//tunnelSurfaces[]+=newbase;
