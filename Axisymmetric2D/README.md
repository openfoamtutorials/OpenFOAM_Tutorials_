Axisymmetric 2D Simulations in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/Axisymmetric2D

DESCRIPTION:
Here we will do a simple 2D axisymmetric simulation of a donut shape in freestream. The 'wedge' boundary condition will be introduced and details on setting up an axisymmetric case will be shown.

OUTLINE:
-Use rotational extrude in Gmsh to create a wedge shape.
-Convert the mesh and change the boundary file.
-Change the write format in system/controlDict to 'binary' to prevent errors.
-Run the simulation and view post-processed results.

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3