//Gmsh

/*
l=wtBoundDim[2]-span;
c=extCells;
p=extProgression;
b=nearSurface;
Call myExtrusion;
//casingSurfaces[]+=surf[{4:6}];
statorVolumes[]+=vol;
tunnelSurfaces[]+=newbase;
nearSurface=newbase;
ubc[]={};//ubound connectors
ubs[]={};//ubound surfaces
uboundlines3[]={};
periphery3[]={};
tmp[]=Boundary{Surface{newbase};};
periphery3[]=tmp[{4:10}];
ubs[]=surf[{0:3}];
For nn In {0:3}
	tmp[]=Boundary{Surface{surf[nn]};};
	ubc[nn]=tmp[3];
	uboundlines3[nn]=tmp[2];
EndFor
p3[]={};
tmp[]=Boundary{Surface{nearSurface};};
For nn In {0:3}
	tmp2[]=Boundary{Line{tmp[nn]};};
	p3[]+=tmp2[0];
EndFor
*/


/*
pts[]={};
uboundlines2[]={};
periphery2[]={};

//Printf("Cap Surfaces");
//Printf("Current ce: %g",ce);
l=span;
c=spanCells;
p=spanProgression;
b=nearSurface;
Call myExtrusion;
statorVolumes[]+=vol;
nearSurface=newbase;
casingSurfaces[]+=surf[{6,7}];
bottomVSurface=surf[5];
topHSurface=surf[0];
topHSurface2=surf[11];
ubs[0]=surf[2];
ubs[1]=surf[3];
ubs[2]=surf[4];
ubs[7]=surf[1];
tmp[]=Boundary{Surface{surf[1]};};
ubc[0]=tmp[1];
ubc[7]=tmp[3];
tmp[]=Boundary{Surface{surf[3]};};
ubc[1]=tmp[3];
ubc[2]=tmp[1];
tmp[]=Boundary{Surface{surf[4]};};
ubc[3]=tmp[1];
//Call pt;
tmp[]=Boundary{Surface{newbase};};
//Call pt;
uboundlines2[0]=tmp[2];
uboundlines2[1]=tmp[3];
uboundlines2[2]=tmp[4];
uboundlines2[7]=tmp[1];
tmp2[]=Boundary{Line{tmp[0]};};
topCorner2=tmp2[1];
tmp2[]=Boundary{Line{tmp[1]};};
pts[0]=tmp2[1];
pts[7]=tmp2[0];
tmp2[]=Boundary{Line{tmp[3]};};
pts[1]=tmp2[0];
pts[2]=tmp2[1];
tmpbv2=tmp[5];
tmp2[]=Boundary{Line{tmp[5]};};
bottoms[]+=tmp2[1];
bottom2=tmp2[0];
tmp2[]=Boundary{Line{tmp[7]};};
outlips[]+=tmp2[0];
inlips[]+=tmp2[1];
//tmp2[]=Boundary{Line{tmp[8]};};
//o2=tmp2[1];
//Printf("%g",tmp2[1]);
tmp2[]=Boundary{Line{tmp[9]};};
topDisks[]+=tmp2[0];
suppressors[]+=tmp2[1];
tmptop=tmp[11];
tmptop2=tmp[0];
tmp2[]=Boundary{Line{tmp[11]};};
adapts[]+=tmp2[0];
topCorners[]+=tmp2[1];
//tmp[]=tmp2[];Call pt;
periphery2[7]=tmp[7];
periphery2[0]=tmp[8];//front above lip
periphery2[1]=tmp[9];
periphery2[2]=tmp[10];
periphery2[3]=tmp[11];
periphery2[6]=tmp[6];

tmp[]=Boundary{Surface{newAdaptSurface};};
corneradapts[]+=tmp[0];//line
tmp[]=Boundary{Line{tmp[0]};};
corners[]+=tmp[0];

//Filling in cap plane surfaces.
z=span;
tmp[]={};
Point(ce++)={uBoundAdapt[1]+uBoundAdaptAdjustments[0],uBoundCenter[1]-uBoundDim[1]/2,z};tmp[]+=ce;
Point(ce++)={uBoundCenter[0]+uBoundDim[0]/2,uBoundCenter[1]-uBoundDim[1]/2,z};tmp[]+=ce;
Point(ce++)={uBoundCenter[0]+uBoundDim[0]/2,uBoundAdapt[2]+uBoundAdaptAdjustments[1],z};tmp[]+=ce;
s=Sin(-cornerAngle);
c=Cos(-cornerAngle);
ss=Sin(jetAngles[1]);
cc=Cos(jetAngles[1]);
Point(ce++)={c*cr+jetLength*cc,s*cr-ss*jetLength,z,tels};
tes[]+=ce;

Line(ce++)={bottoms[1],tes[1]};bottomLines[]+=ce;
periphery2[5]=ce;
Line(ce++)={corners[1],tes[1]};jetLines[]+=ce;
Line(ce++)={tmp[0],tes[1]};tmpbv=ce;
Line(ce++)={tmp[2],tes[1]};bottomline2=ce;
Line(ce++)={tes[0],tes[1]};te=ce;
Line(ce++)={bottom2,tmp[0]};tmpbottomline=ce;
uboundlines2[3]=ce;
pts[3]=bottom2;
pts[4]=tmp[0];
Line(ce++)={tmp[0],tmp[1]};tmpbr=ce;
uboundlines2[4]=ce;
Line(ce++)={tmp[1],tmp[2]};tmpbr2=ce;
uboundlines2[5]=ce;
pts[5]=tmp[1];
pts[6]=tmp[2];
Line(ce++)={tmp[2],topCorner2};tmpaft2=ce;
uboundlines2[6]=ce;
Line(ce++)={p[4],tmp[0]};tmpaftbottom0=ce;
Line(ce++)={p[5],tmp[1]};tmpaftcorner=ce;
Line(ce++)={p[6],tmp[2]};tmpaftbottom=ce;
//Circle(ce++)={tes[1],corners[1],topCorners[1]};tmpaft=ce;
Line(ce++)={tes[1],topCorners[1]};tmpaft=ce;
periphery2[4]=ce;
Transfinite Line{jetLines[1]}=jetCells+1 Using Progression jetProgression;
Transfinite Line{bottomLines[1],tmpbottomline}=bottomCells+1 Using Progression bottomProgression;
fraction=(uBoundAdapt[3]-uBoundAdapt[2])/uBoundDim[1];
Transfinite Line{tmpaft2}=fraction*middleCells[2]+1+additionalJetCells[1];
Transfinite Line{tmpaft}=fraction*middleCells[2]+1+additionalJetCells[1];// Using Progression jetInflation;
fraction=(uBoundCenter[0]+uBoundDim[0]/2-uBoundAdapt[1])/uBoundDim[0];
Transfinite Line{bottomline2,tmpbr}=fraction*middleCells[3]+1+additionalJetCells[0];
fraction=(uBoundAdapt[2]-(uBoundCenter[1]-uBoundDim[1]/2))/uBoundDim[1];
Transfinite Line{tmpbr2}=fraction*middleCells[2]+1+additionalBottomCells[1];
Transfinite Line{tmpbv}=fraction*middleCells[2]+1+additionalBottomCells[1] Using Progression 1/tipBottomCellProgression;
Transfinite Line{te,tmpaftbottom,tmpaftbottom0,tmpaftcorner}=spanCells+1 Using Progression spanProgression;

lines[]={tmpbv,tmpaftbottom0,lns1[1],te};
Call autoLineLoop;
Call RSS;
surfaceBV=ce;

lines[]={tmpbr2,tmpaftbottom,lns[5],tmpaftcorner};
Call autoLineLoop;
Call PSS;
surfaceSCV=ce;
ubs[5]=ce;

lines[]={tmpbr,tmpaftbottom0,lns[4],tmpaftcorner};
Call autoLineLoop;
Call PSS;
surfaceSCH=ce;
ubs[4]=ce;
tmp[]=Boundary{Surface{surfaceSCH};};
ubc[4]=tmp[1];
ubc[5]=tmp[3];
//Call pt;

tmp[]=Boundary{Surface{bottomVSurface};};
//Call pt;
lines[]={tmpbottomline,tmpaftbottom0,lns[3],tmp[3]};
Call autoLineLoop;
Call PSS;
surfaceSBH=ce;
ubs[3]=ce;
//Printf("%g",surfaceSBH);

tmp[]=Boundary{Surface{topHSurface};};
//Call pt;
lines[]={periphery[4],te,tmpaft,tmp[3]};
Call autoLineLoop;
//tmp[]=lines[];
//Call pt;
Call RSS;
surfaceSAft=ce;

tmp[]=Boundary{Surface{topHSurface};};
//Call pt;
lines[]={lns[6],tmpaftbottom,tmpaft2,tmp[1]};
//tmp[]=lines[];
//Call pt;
Call autoLineLoop;
Call RSS;
surfaceSAft2=ce;
ubs[6]=ce;
tmp[]=Boundary{Surface{surfaceSAft2};};
ubc[6]=tmp[1];
ubc[7]=tmp[3];
//Call pt;

lines[]={lns2[0],te,bottomline2,tmpaftbottom};
Call autoLineLoop;
Call RSS;
surfaceAftBottom=ce;

tmp[]=Boundary{Surface{cornerAdaptSurface};};
//Call pt;
lines[]={jetLines[1],te,jetLines[0],tmp[3]};
Call autoLineLoop;
Call RSS;
surfaceSJet=ce;

tmp[]=Boundary{Surface{bottomVSurface};};
//Call pt;
lines[]={bottomLines[1],te,bottomLines[0],tmp[1]};
Call autoLineLoop;
Call RSS;
surfaceBottom=ce;

lines[]={bottomLines[1],tmpbv,tmpbottomline,tmpbv2};
Call autoLineLoop;
Call PSS;
surfaceBVL=ce;

lines[]={tmpbv,tmpbr,tmpbr2,bottomline2};
Call autoLineLoop;
Call PSS;
surfaceC=ce;

lines[]={tmpaft,bottomline2,tmpaft2,tmptop2};
Call autoLineLoop;
Call PSS;
surfaceJet2=ce;

lines[]={corneradapts[1],jetLines[1],tmpaft,tmptop};
Call autoLineLoop;
Call PSS;
jetPlates[]+=ce;
surfaceJet=ce;

//tmp[]=Boundary{Surface{cornerAdaptSurface};};
//tmp2[]=Boundary{Line{tmp[0]};};
//tmp3[]=Boundary{Line{tmp[2]};};
//tmp[]={tmp2[],tmp3[]};

Transfinite Surface{cornerAdaptSurface};//=tmp[];
Recombine Surface{cornerAdaptSurface};
Transfinite Surface{topHSurface2};
Recombine Surface{topHSurface2};
surf[]={cornerAdaptSurface,jetPlates[],surfaceSJet,surfaceSAft,topHSurface2};
Call TV;
statorVolumes[]+=ce;
//	Surface Loop(ce++)=surf[];
//	Volume(ce++)=ce-1;
//	Transfinite Volume{ce};//={27,28,40073,50116,3,15,13,10};
//tmp[]=surf[];
//Call pt;

Transfinite Surface{topHSurface};
Recombine Surface{topHSurface};
surf[]={topHSurface,surfaceSAft,surfaceSAft2,jetplane2,surfaceJet2,surfaceAftBottom};
//tmp[]=surf[];
//Call pt;
Call TV;
statorVolumes[]+=ce;

surf[]={surfaceSCV,surfaceSCH,brcornersurface,surfaceAftBottom,surfaceBV,surfaceC};
Call TV;
statorVolumes[]+=ce;

Transfinite Surface{bottomVSurface};
Recombine Surface{bottomVSurface};
surf[]={bottomVSurface,surfaceBV,surfaceBottom,surfaceSBH,bsurface,surfaceBVL};
//tmp[]=surf[];
//Call pt;
Call TV;
statorVolumes[]+=ce;

casingSurfaces[]+=surfaceSJet;
casingSurfaces[]+=surfaceBottom;
capSurfaces[]+=jetPlates[1];
baffleSurfaces[]+=topHSurface2;
//tmp[]=periphery2[];
//Call pt;
*/
