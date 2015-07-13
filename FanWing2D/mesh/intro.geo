//Gmsh

Include "inputs.geo";
Include "extrusion.geo";
Include "subs.geo";
capSurfaces[]={};
casingSurfaces[]={};
statorInterfaceSurfaces[]={};
tunnelSurfaces[]={};
inletSurfaces[]={};
outletSurfaces[]={};
symmetrySurfaces[]={};
baffleSurfaces[]={};

statorVolumes[]={};

ce=0;
Point(ce++)={0,0,0};origin1=ce;
Point(ce++)={0,0,span};origin2=ce;

//Te calculation
s=Sin(-cornerAngle);
c=Cos(-cornerAngle);
dy=(cr+s*cr+ct);
dx=dy/Tan(jetAngles[0]);
jetLength=Sqrt(dx^2+dy^2);

jetLines[]={};
bottomLines[]={};
corneradapts[]={};
jetPlates[]={};
tes[]={};
corners[]={};
inlips[]={};
outlips[]={};
bottoms[]={};
topCorners[]={};
topDisks[]={};
adapts[]={};
