//Physical surface arrays (to be filled).
TUNNEL[]={};
WEDGE0[]={};
WEDGE1[]={};
DUCT[]={};
ROTOR[]={};
INLET[]={};
OUTLET[]={};
//Physical volume array.
AIR[]={};

Include "functions.geo";
Include "inputs.geo";
ce = 0;
Point(ce++)={0,0,0};
origin=ce;

Include "shapes/nacelle.geo";
Include "shapes/basicbl.geo";
Include "shapes/splineFoil.geo";

Include "unstructuredboundary.geo";
Include "domainboundary.geo";

Transfinite Surface{ROTOR[]};
Recombine Surface{ROTOR[]};

Physical Surface("inlet") = INLET[];
Physical Surface("outlet") = OUTLET[];
Physical Surface("tunnel") = TUNNEL[];
Physical Surface("duct") = DUCT[];
Physical Surface("wedge0") = WEDGE0[];
Physical Surface("wedge1") = WEDGE1[];
Physical Surface("baffle")=ROTOR[];

Physical Volume("air") = AIR[];

