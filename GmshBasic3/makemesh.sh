#!/bin/bash

cp -r originals/cavity .

gmsh main.geo -3 -o test.msh

gmshToFoam test.msh -case cavity

#Now go into 'cavity/constant/polyMesh/boundary', 
#and change the types to be consistent with those in '0',
#as shown in the tutorial video.  