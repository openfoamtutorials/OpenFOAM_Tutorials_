How to Make Baffles (Thin Walls, Internal Faces) in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/Baffle

DESCRIPTION:
Here we will make a simple 2D simulation of a flat plate in a windtunnel. 

The flat plate is generated as an internal face in Gmsh. An internal face is a surface where fluid cells are on both sides of the surface. In OpenFOAM, this is known as a baffle. It an internal face that is to be recognized as an infinitely thin wall. The patch type can be something other than wall, for example, it could be cyclic for a pressure-jump actuator disk.

In Gmsh we can group and name internal faces, but they will not be recognized the same as regular boundaries. In the conversion to OpenFOAM, they do not show up as boundaries, but are stored as faceZones with the same name we specified. We detail how to produce a regular boundary from the faceZones using OpenFOAM utilities.

'commands.txt': contains the commands and procedure descriptions for each step.
'U_result.ogv': video of the velocity field results of running the simulation. 

OUTLINE:
-Generate mesh in Gmsh.
-Convert mesh to OpenFOAM format.
-Convert faceZone to wall baffle.
-Run the simulation.

This tutorial was run on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
-Gmsh 2.9.3