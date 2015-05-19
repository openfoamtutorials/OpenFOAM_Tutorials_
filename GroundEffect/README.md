Ground Effect Vehicle Airfoil Simulation in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/GroundEffect

DESCRIPTION:
Here we will be doing a simple 2D simulation of a ground effect vehicle airfoil. This is simply an airfoil that is some small multiple of its chord above the ground. 

OUTLINE:
-Go over mesh.
-Go over boundary conditions.
-Run simulation.
-View results.

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Modify boundary file.
pimpleFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3