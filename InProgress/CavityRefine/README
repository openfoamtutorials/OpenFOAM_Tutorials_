
All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/DuctedFan

DESCRIPTION:

OUTLINE:

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Change boundary file
refineMesh -case case -dict system/refineMeshDict
pimpleFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3