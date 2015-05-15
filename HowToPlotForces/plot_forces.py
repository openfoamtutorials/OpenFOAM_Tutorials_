#!/usr/bin/python

import os
import math

forces_file = "airFoil2D_new/postProcessing/airfoil/0/forces.dat"

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
		drag += [data_dict['force']['pressure'][0] + data_dict['force']['viscous'][0]]
		lift += [data_dict['force']['pressure'][1] + data_dict['force']['viscous'][1]]
		moment += [data_dict['moment']['pressure'][2] + data_dict['moment']['viscous'][2]]
datafile.close()

outputfile = open('forces.txt','w')
for i in range(0,len(time)):
	outputfile.write(str(time[i])+' '+str(lift[i])+' '+str(drag[i])+' '+str(moment[i])+'\n')
outputfile.close()

os.system("./gnuplot_script.sh")
