//Gmsh

dtr=Pi/180;
itm=0.0254;
ftm=0.3048;

cr=0.2;//6*itm;//m, casing radius.
gap=cr/20;//m, gap between blades and casing.
ct=1*itm;//m, casing thickness.

jetAngles[]={40*dtr,40*dtr};//rad, {root,tip}
cornerAngle=10*dtr;//rad
lipAngles[0]=20*dtr;
outlipspan=10*dtr;
lipAngles[1]=lipAngles[0]+outlipspan;
plateAngle[]={50*dtr,80*dtr};//rad, {disk location, corner location}
plateGridAdapt=0.5;//non-dimensional length of point along the top plate line for grid reasons. 
plateSpline1[]={0.02*cr,1.05*cr};
plateSpline2[]={1.1*cr,0.1*cr};

uBoundDim[]={cr*4,cr*3};
uBoundCenter[]={0.5*cr,0};
uBoundAdapt[]={-0.0*cr,2.5*cr,-1.2*cr,0.3*cr};//m, locations along uBound lines, {bottom,right-bottom,right-top}
uBoundAdaptAdjustments[]={0.0*cr,0.0*cr};//added to {uBoundAdapt[1],uBoundAdapt[2]} for z>0


ept=0.007;//m, end plate thickness
epx[]={-cr/3,	-cr/3,	
	0.8*cr,	1.2*cr,
	2.0*cr,		1.6*cr,	0*cr};
epy[]={-cr/2,	-cr/3,	
	0.3*cr,	0.3*cr,
	-0.4*cr,	-0.9*cr,-0.75*cr};
plateDim[]={0.5*uBoundDim[0],0.5*uBoundDim[1]};
outerplatels=cr/7;

span=.1*cr;
wtBoundDim[]={50*cr,50*cr,2*span};//m

shaftRadius=0.25*itm;//cr/8;
bladeChord=1.5*itm;//cr/4;//m
bladePitch=15;//deg
bladeCount=16;
k1=0.1;
k2=0.2;
bladeThicknessRatio=0.025/1.5;//thickness/chord

ssx[]={1.5*cr, 2.5*cr};//m, suppressor spline x
ssy[]={0.75*cr, -0.2*cr};
//ssx[]={1.2*cr*Sin(plateAngle[0]), 1.0*cr, 3.*cr};//m, suppressor spline x
//ssy[]={1.2*cr*Cos(plateAngle[0]), 1.*cr, -1.2*cr};

lipcoord[]={-1.25*cr,-cr-ct};

//Grid
outwardProgressions[]={1.15,1.15,1.15,1.15};//{front,top,back,bottom}
outwardCells[]={25,25,25,25};//{front,top,back,bottom}
middleCells[]={30,30,30,30};//{front,top,back,bottom}
backAdjustment[]={0.0075*wtBoundDim[0],0.015*wtBoundDim[0],-0.01*wtBoundDim[0],-0.0075*wtBoundDim[0]};//topmost  to bottommost
bottomAdjustment[]={-0.0075*wtBoundDim[1],-0.0075*wtBoundDim[1],0.00*wtBoundDim[1],0.0075*wtBoundDim[1]};//leftmost  to rightmost
topAdjustment[]={-0.0075*wtBoundDim[1],0.0075*wtBoundDim[1]};//leftmost  to rightmost
frontAdjustment[]={0.0075*wtBoundDim[0],-0.0075*wtBoundDim[0]};//topmost  to bottommost

jetCells=25;jetProgression=1.1;jetInflation=1.05;
bottomCells=20;bottomProgression=1.00;

tipBottomCellProgression=1.;//For the line that emanates downward from the tip TE.

additionalJetCells[]={2,9};//to add to twisted regions above te. {horizontal,vertical}
additionalBottomCells[]={0,5};//to add to twisted regions below te. {horizontal,vertical}

spanCells=1;
spanProgression=1;
extCells=25;
extProgression=1.15;

//ringCells=300;
gapCells=2;

platels=cr/5;
bottomls=cr/20;
interfacels=cr/51;
bladels=interfacels;//m
lipls=cr/25;
tels=cr/25;
topcornerls=cr/15;
adaptls=cr/15;
shaftls=cr/18;
sls[]={2*interfacels,cr/15};//suppressor ls, {near interface,far from interface}

cell2d=0.01;//m

//Meshing Algorithm
Mesh.RecombinationAlgorithm=1;//0=Standard, 1=Blossom
Mesh.Algorithm=6;//1=MeshAdapt, 2=Automatic, 5=Delaunay, 6=Frontal, 7=bamg, 8=delquad

