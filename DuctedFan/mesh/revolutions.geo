//Gmsh

dir[]={0,1,0};ori[]={0,0,0};angle=Pi/2;cc=EC/2;
bb=ss1;Call revolve;
AIR[]+=vol;
//Transfinite Volume{vol};
//Recombine Volume{vol};
FREESTREAM[]+=surf[1];
ss1=newbase;

bb=ss1;Call revolve;
AIR[]+=vol;
//Transfinite Volume{vol};
//Recombine Volume{vol};
FREESTREAM[]+=surf[1];
SYMMETRY[]+=newbase;

//TL[]={};//top lines for base surface of center extrusions.
//TLS=2;//surface for TL extraction.
//TLI=1;//line index to get TL from TLS.

bb=ss2;Call revolve;
AIR[]+=vol;
//Transfinite Volume{vol};
//Recombine Volume{vol};
FREESTREAM[]+=surf[2];
//ids[]=Boundary{Surface{surf[TLS]};};
//TL[]+=ids[TLI];
ss2=newbase;

bb=ss2;Call revolve;
AIR[]+=vol;
//Transfinite Volume{vol};
//Recombine Volume{vol};
FREESTREAM[]+=surf[2];
//ids[]=Boundary{Surface{surf[TLS]};};
//TL[]+=ids[TLI];
SYMMETRY[]+=newbase;

bb=us;Call revolve;
AIR[]+=vol;
//Recombine Volume{vol};
DUCT[]+=surf[{5:9}];
us=newbase;

bb=us;Call revolve;
AIR[]+=vol;
//Recombine Volume{vol};
SYMMETRY[]+=newbase;
DUCT[]+=surf[{5:9}];

//top freestream outer core.
SYMMETRY[]+=oc1;
bb=oc1;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[1];
oc1=newbase;

bb=oc1;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[1];
oc1=newbase;
SYMMETRY[]+=oc1;

//above-disk outer core.
SYMMETRY[]+=oc2;
bb=oc2;Call revolve;
AIR[]+=vol;
oc2=newbase;

bb=oc2;Call revolve;
AIR[]+=vol;
oc2=newbase;
SYMMETRY[]+=oc2;

//disk outer core.
SYMMETRY[]+=oc3;
bb=oc3;Call revolve;
ROTOR[]+=vol;
oc3=newbase;

bb=oc3;Call revolve;
ROTOR[]+=vol;
oc3=newbase;
SYMMETRY[]+=oc3;

//below-disk outer core.
SYMMETRY[]+=oc4;
bb=oc4;Call revolve;
AIR[]+=vol;
oc4=newbase;

bb=oc4;Call revolve;
AIR[]+=vol;
oc4=newbase;
SYMMETRY[]+=oc4;

//bottom freestream outer core.
SYMMETRY[]+=oc5;
bb=oc5;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[3];
oc5=newbase;

bb=oc5;Call revolve;
AIR[]+=vol;
FREESTREAM[]+=surf[3];
oc5=newbase;
SYMMETRY[]+=oc5;
