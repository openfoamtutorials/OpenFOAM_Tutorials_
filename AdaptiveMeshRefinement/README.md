Solution-Adaptive Mesh Refinement in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/AdaptiveMeshRefinement

DESCRIPTION:
Here we will be using the built-in dynamicRefineFvMesh to run a solution-adaptive mesh refinement (SAMR) simulation on the pisoFoam cavity tutorial case. The caveat with the built-in SAMR is that only hexahedral cells can be used and the case must be 3D (due to octree splitting). I have tried making a 2D case more 3D by changing the empty faces to symmetry, but the solver crashes after several iterations.

Currently, it is not working for 3D cases even with no symmetry planes or empty faces. It crashes after several iterations.

This tutorial was run on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1
