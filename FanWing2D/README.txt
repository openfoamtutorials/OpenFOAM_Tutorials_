FanWing Simulation in OpenFOAM Using Arbitrary Mesh Interface (AMI)

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/FanWing2D

DESCRIPTION:
Here we will simulate a FanWing wing section in 2D. The FanWing is a novel lift device invented recently in the late 90's by Patrick Peebles. It utilizes a cross flow fan to produce air flow over the whole span of the wing. In 2D, the simulation does not match well with wind tunnel experiments, but 3D cases do match well (a tutorial for this is/will be made on this channel). The 2D simulation would still be good for fast parametric design simulations. The rotor is a moving mesh made possible by the OpenFOAM Arbitrary Mesh Interface (AMI).

OUTLINE:
-Create mesh in Gmsh.
-Convert the mesh and change the 'constant/polyMesh/boundary' file.
-To the AMI patches add (replace angle brackets; the parameter values can be changed):
    type cyclicAMI;
    neighbourPatch <patchname>;
    matchTolerance 1e-4;
    transform noOrdering;
-Run the simulation and view post-processed results.

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Modify boundary file
pimpleDyMFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.4.0
-Gmsh 2.9.3