#!/bin/bash

gmsh main.geo -3 -o test.msh

gmshToFoam test.msh -case dummyCase

rm test.msh
