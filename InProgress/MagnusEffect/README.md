Magnus Effect Simulation in OpenFOAM (Hybrid Structured-Unstructured Mesh in Gmsh)

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/DuctedFan

DESCRIPTION:
Here we will simulate the Magnus effect on a spinning cylinder in freestream in a 2D simulation in OpenFOAM. The mesh will be hybrid structured-unstructured and generated in Gmsh. Lift and drag forces will be inspected, as well as the flowfield.

OUTLINE:
-Gmsh mesh overview.
-Mesh generation and conversion to OpenFOAM.
-Simulation using pimpleFoam.
-Inspect lift and drag forces.
-Inspect flow field.

COMMANDS:
gmsh main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Modify boundary file.
pimpleFoam
./plot_forces.py

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3