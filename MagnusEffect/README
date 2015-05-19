Magnus Effect Simulation in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/MagnusEffect

DESCRIPTION:
Here we will simulate the Magnus effect on a spinning cylinder in freestream in a 2D simulation in OpenFOAM. The mesh will be hybrid structured-unstructured and generated in Gmsh. The flowfield will be inspected.

OUTLINE:
-Gmsh mesh overview.
-Mesh generation and conversion to OpenFOAM.
-Simulation using pimpleFoam.
-Inspect flow field.

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Set freestream velocity and rotation speed.
# Modify boundary file.
pimpleFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3