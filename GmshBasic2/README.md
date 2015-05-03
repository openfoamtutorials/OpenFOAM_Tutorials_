Making Meshes for OpenFOAM with Gmsh, Part 2: Extrusions and Conversion to OpenFOAM Format

DESCRIPTION:
Here we will make a simple cube mesh  by extrusion from a 2D sqaure mesh. Then we will export the mesh to a file and use the OpenFOAM mesh conversion utility to import it into a dummy case.

OUTLINE:
Make a 2D square mesh.
Extrude the 2D mesh to create a 3D mesh.
Define the volume and surfaces so that OpenFOAM can recognize them. 
Create the mesh by exporting it to a file with the command line.
Convert the mesh with the command-line OpenFOAM mesh conversion utility.