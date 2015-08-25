
All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/

DESCRIPTION:

OUTLINE:

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Set freestream velocity speed.
# Modify boundary file.
createBaffles -case case -dict system/baffleDict -overwrite
pimpleFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.4.0
-Gmsh 2.9.3