# MPI Parallel Simulations in OpenFOAM

All code can be found at: https://github.com/lordvon/OpenFOAM_Tutorials/tree/master/Parallel

## Description
In this tutorial we parallelize a tutorial case. We use the built-in OpenFOAM MPI implementation and invoke a few built-in tools to help with setup and post-processing.

## Outline
-Go over decomposeParDict file.
-Decompose domain.
-Run simulation in parallel.
-Reconstruct output for viewing.

## Commands
decomposeParDict
mpirun -np 4 simpleFoam
reconstructPar

## Other
This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.4.0