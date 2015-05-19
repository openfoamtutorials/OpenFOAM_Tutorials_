Ducted Fan Simulation in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/DuctedFan

DESCRIPTION:
An actuator disk (pressure-jump baffle) will be used to simulate a propeller. A duct surrounds the actuator disk. The simulation is axisymmetric 2D via the wedge boundary condition.
The knowledge required to create this simulation can be obtained from the baffle, axisymmetric 2D, and Gmsh tutorials.

OUTLINE:
-Overview of the mesh.
-Overview of the necessary boundary conditions.
-Inspect the velocity and pressure fields.

COMMANDS:
gmsh mesh/main.geo -3 -o test.msh
gmshToFoam test.msh -case case
# Modify boundary file
createBaffles -case case -dict system/baffleDict -overwrite
pimpleFoam

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3