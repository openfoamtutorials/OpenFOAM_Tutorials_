High-Lift Multi-Element Airfoil Simulation

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/MultiElementAirfoil

DESCRIPTION:
Multi-element airfoils is a composite airfoil of smaller airfoils that allow for high lift coefficients. Here we simulate 2D incompressible multi-element airfoils.

OUTLINE:
-View mesh and boundaries.
-Convert mesh.
-Change boundary file.
-Run simulation.
-View post-processed results.

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Modify boundary file
pimpleFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.4.0
-Gmsh 2.9.3