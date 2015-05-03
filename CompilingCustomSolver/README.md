Compiling Your Own Custom OpenFOAM Solver, Part 0

DESCRIPTION:
Here we will take an existing solver, pimpleDyMFoam, and simply rename it and compile it so that OpenFOAM recognizes the newly named solver. This may sound trivial, but making your own solver typically would follow this procedure of copying and existing similar solver and adding modifications. Here, we will simply omit the modifications.

OUTLINE:
-Rename the following files with your new solver name:
	-Solver folder
	-Solver main source file (.C)
	-Application and Source description in the main source file comment header
	-Change names in 'Make/files'
-Run 'sudo bash' to become super user. This is necessary because you might get permissions errors when trying to create your new solver executable in $(FOAM_APPBIN) as specified in 'Make/files'.
-Run 'wclean' and 'wmake' in main directory of your new solver.
-Run 'exit' to leave 'sudo bash'.
-Run 'mySolver -help' to show that your new compiled custom solver is recognized!

NOTE: we have copied various '.H' files into the main directory of this tutorial because the specification of the includes in 'Make/options' are such that these headers need to be in the directory above the solver main directory (via '-I..'). You can of course change this, but this is how it is in the default pimpleDyMFoam solver included in $FOAM_SOLVERS.

This tutorial was run successfully on:
-Ubuntu 14.04 64-bit
-OpenFOAM 2.3.1