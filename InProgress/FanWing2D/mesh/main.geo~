//Gmsh
Printf("Start:");

Include "intro.geo";

Include "firstplane.geo";
//statorExtremeLengths[]={minLength,maxLength};
Include "wtspan.geo";

//Include "cap.geo";
//Include "secondplane.geo";
//Include "wtext.geo";

Include "rotor.geo";
//rotorExtremeLengths[]={minLength,maxLength};


//Physical Surface("symmetry")=symmetrySurfaces[];
//Physical Surface("plate")=capSurfaces[];
//Physical Surface("cap0")=rotorcap;


Physical Surface("casing")=casingSurfaces[];
Physical Surface("ami00")=statorInterfaceSurfaces[];
Physical Surface("ami01")=rotorInterfaceSurfaces[];
Physical Surface("tunnel")=tunnelSurfaces[];
Physical Surface("shaft0")=shaftSurfaces[];
Physical Surface("inlet")=inletSurfaces[];
Physical Surface("outlet")=outletSurfaces[];
Physical Surface("blades0")={bladeSurfaces[{2:#bladeSurfaces[]-1}]};
Physical Surface("singleBlade")=bladeSurfaces[{0,1}];
//Physical Surface("baffle")=baffleSurfaces[];
Physical Volume("statorVolume")=statorVolumes[];
Physical Volume("rotorVolume0")=rotorVolume;
//Printf("Rotor and stator min lengths: %g %g",rotorExtremeLengths[0],statorExtremeLengths[0]);
//Printf("Estimated rotor and stator min aspect ratios: %g %g",rotorExtremeLengths[0]/interfacels,statorExtremeLengths[0]/interfacels);
//Printf("Rotor and stator max lengths: %g %g",rotorExtremeLengths[1],statorExtremeLengths[1]);
//Printf("Estimated rotor and stator max aspect ratios: %g %g",rotorExtremeLengths[1]/interfacels,statorExtremeLengths[1]/interfacels);

Printf("Finished.");
