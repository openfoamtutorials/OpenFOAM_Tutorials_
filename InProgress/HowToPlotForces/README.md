How to Plot Forces in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/HowToPlotForces

DESCRIPTION:
Here we will go over how to generate force data, and then plot it using gnuplot. We will use a standard OpenFOAM tutorial case, airFoil2D, which can be found at $FOAM_TUTORIALS/incompressible/simpleFoam/airFoil2D.

OUTLINE:
-Modify the controlDict to output force data.
-Run the simulation.
-Walk through the python script that processes and plots the force output.

COMMANDS:
./Allclean
./Allrun
./plot_forces.py

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1