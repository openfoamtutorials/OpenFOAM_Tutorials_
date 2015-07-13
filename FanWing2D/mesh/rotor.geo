//Gmsh

//shaft
sr=shaftRadius;
shaftPoints[]={};
Point(ce++)={sr,0,0,shaftls};shaftPoints[]+=ce;
Point(ce++)={0,sr,0,shaftls};shaftPoints[]+=ce;
Point(ce++)={-sr,0,0,shaftls};shaftPoints[]+=ce;
Point(ce++)={0,-sr,0,shaftls};shaftPoints[]+=ce;

//interface
ir=cr-gap/2;
interfacePoints[]={};
interfaceOffset=3;
angle=interfaceOffset;Call prepTrig;
Point(ce++)={cs*ir,sn*ir,0,interfacels};interfacePoints[]+=ce;
angle=90+interfaceOffset;Call prepTrig;
Point(ce++)={cs*ir,sn*ir,0,interfacels};interfacePoints[]+=ce;
angle=180+interfaceOffset;Call prepTrig;
Point(ce++)={cs*ir,sn*ir,0,interfacels};interfacePoints[]+=ce;
angle=270+interfaceOffset;Call prepTrig;
Point(ce++)={cs*ir,sn*ir,0,interfacels};interfacePoints[]+=ce;

//Points
bladeTes[]={};
bladeLes[]={};
bladeK1s[]={};
bladeK2s[]={};
Point(ce++)={cr-gap,0,0,bladels};						bladeTes[]+=ce;
angle=180-bladePitch;Call prepTrig;
Point(ce++)={cr-gap+bladeChord*cs,bladeChord*sn,0,bladels};			bladeLes[]+=ce;
Point(ce++)={cr-gap+bladeChord/2*cs-k1*sn,bladeChord/2*sn+k1*cs,0,bladels};	bladeK1s[]+=ce;
Point(ce++)={cr-gap+bladeChord/2*cs-k2*sn,bladeChord/2*sn+k2*cs,0,bladels};	bladeK2s[]+=ce;
For k In {0:bladeCount-1}
	Rotate {{0,0,1},{0,0,0},2*Pi/bladeCount*k} {Duplicata{Point{bladeTes[0]};}}
	ce++;
	bladeTes[]+=ce;
	Rotate {{0,0,1},{0,0,0},2*Pi/bladeCount*k} {Duplicata{Point{bladeLes[0]};}}
	ce++;
	bladeLes[]+=ce;
	Rotate {{0,0,1},{0,0,0},2*Pi/bladeCount*k} {Duplicata{Point{bladeK1s[0]};}}
	ce++;
	bladeK1s[]+=ce;
	Rotate {{0,0,1},{0,0,0},2*Pi/bladeCount*k} {Duplicata{Point{bladeK2s[0]};}}
	ce++;
	bladeK2s[]+=ce;
EndFor

//Lines
bladeLoops[]={};
For k In {0:bladeCount-1}
	bladeLines[]={};
	Circle(ce++)={bladeTes[k],bladeK1s[k],bladeLes[k]};bladeLines[]+=ce;
	Circle(ce++)={bladeLes[k],bladeK2s[k],bladeTes[k]};bladeLines[]+=ce;
	Line Loop(ce++)=bladeLines[];
	bladeLoops[]+=ce;
EndFor

surfacesPerBlade=2;

//Rotor Interface
rotorInterfaceLines[]={};
For k In {0:3}
	Circle(ce++)={interfacePoints[k],origin1,interfacePoints[(k+1)%4]};
	rotorInterfaceLines[]+=ce;
EndFor
Line Loop(ce++)=rotorInterfaceLines[];
rotorInterfaceLoop=ce;

//Shaft
shaftLines[]={};
For k In {0:3}
	Circle(ce++)={shaftPoints[k],origin1,shaftPoints[(k+1)%4]};
	shaftLines[]+=ce;
EndFor
Line Loop(ce++)=shaftLines[];
shaftLoop=ce;

Plane Surface(ce++)={rotorInterfaceLoop,bladeLoops[],shaftLoop};rotorSurface=ce;
Recombine Surface{ce};
symmetrySurfaces[]+=ce;

l=span;
c=spanCells;
p=spanProgression;
b=ce;
Call myExtrusion;
rotorVolume=vol;
rotorInterfaceSurfaces[]=surf[{0:3}];
//capSurfaces[]+=newbase;
rotorcap=newbase;
bladeSurfaces[]=surf[{4:4+bladeCount*2-1}];
shaftSurfaces[]=surf[{4+bladeCount*2:7+bladeCount*2}];
