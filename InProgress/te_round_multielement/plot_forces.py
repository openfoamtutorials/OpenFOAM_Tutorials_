#!/usr/bin/python

import os
import sys
import math

forces_file = "case/postProcessing/airfoil/0/forces.dat"

cell_depth = 0.02
chord = 1.12
surface_area = cell_depth*chord
density = 1.18
velocity = 11
dynamic_pressure = 0.5 * density * velocity ** 2
force_multiplier = 1 / dynamic_pressure / surface_area
moment_multiplier = force_multiplier / chord
skip = 1000

if not os.path.isfile(forces_file):
	print "Forces file not found at "+forces_file
	print "Be sure that the case has been run and you have the right directory!"
	print "Exiting."
	sys.exit()

def line2dict(line):
	tokens_unprocessed = line.split()
	tokens = [x.replace(")","").replace("(","") for x in tokens_unprocessed]
	floats = [float(x) for x in tokens]
	data_dict = {}
	data_dict['time'] = floats[0]
	force_dict = {}
	force_dict['pressure'] = floats[1:4]
	force_dict['viscous'] = floats[4:7]
	force_dict['porous'] = floats[7:10]
	moment_dict = {}
	moment_dict['pressure'] = floats[10:13]
	moment_dict['viscous'] = floats[13:16]
	moment_dict['porous'] = floats[16:19]
	data_dict['force'] = force_dict
	data_dict['moment'] = moment_dict
	return data_dict

time = []
drag = []
lift = []
moment = []
with open(forces_file,"r") as datafile:
	for line in datafile:
		if line[0] == "#":
			continue
		data_dict = line2dict(line)
		time += [data_dict['time']]
		drag += [ force_multiplier * ( data_dict['force']['pressure'][0] + data_dict['force']['viscous'][0] ) ]
		lift += [ force_multiplier * ( data_dict['force']['pressure'][1] + data_dict['force']['viscous'][1] ) ]
		moment += [ moment_multiplier * ( data_dict['moment']['pressure'][2] + data_dict['moment']['viscous'][2] ) ]
datafile.close()

outputfile = open('forces.txt','w')
for i in range(skip,len(time)):
	outputfile.write(str(time[i])+' '+str(lift[i])+' '+str(drag[i])+' '+str(moment[i])+'\n')
outputfile.close()

os.system("./gnuplot_script.sh")
