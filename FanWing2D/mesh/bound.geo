//Gmsh
//Given a z.

p[]={};
Point(ce++)={uBoundCenter[0]+uBoundDim[0]/2,uBoundCenter[1]+uBoundDim[1]/2,z};p[]+=ce;
Point(ce++)={uBoundCenter[0]-uBoundDim[0]/2,uBoundCenter[1]+uBoundDim[1]/2,z};p[]+=ce;
Point(ce++)={uBoundCenter[0]-uBoundDim[0]/2,uBoundCenter[1]-uBoundDim[1]/2,z};p[]+=ce;
Point(ce++)={uBoundCenter[0]+uBoundDim[0]/2,uBoundCenter[1]-uBoundDim[1]/2,z};p[]+=ce;

uboundlines[]={};
Line(ce++)={p[0],p[1]};uboundlines[]+=ce;Transfinite Line{ce}=middleCells[1]+1;
Line(ce++)={p[1],p[2]};uboundlines[]+=ce;Transfinite Line{ce}=middleCells[0]+1;
Line(ce++)={p[2],p[3]};uboundlines[]+=ce;Transfinite Line{ce}=middleCells[3]+1;
Line(ce++)={p[3],p[0]};uboundlines[]+=ce;Transfinite Line{ce}=middleCells[2]+1;

Include "wt.geo";
