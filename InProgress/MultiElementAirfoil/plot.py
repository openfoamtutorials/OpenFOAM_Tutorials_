#!/usr/bin/env python
# Plots the chosen quantities for a spedified run.
# 1: The name of the run (of those in Runs/).
# 2: The quantity to plot: 'r': residuals, 'f': forces, 'c': coefficients.
# If 'c' is specified, then a characteristic length has to be supplied.

import os
import sys

execfile('functions.py')
def cleanString(string):
	string = string.replace("(","")
	string = string.replace(")","")
	return string
def cleanList(lst):
	# Clears list from forces.dat from parentheses.
	for i in range(len(lst)):
		lst[i] = float(cleanString(lst[i]))
	return lst
def processForceLine(line):
	"""
	Returns a dictionary of lists:
	ret = {time, pressureForce, viscousForce, pressureMoment, viscousMoment}
	(porous quantities are ignored)
	"""
	raw = line.split()
	ret = {}
	ret['time'] = float(cleanString(raw[0]))
	ret['pressureForce'] = cleanList(raw[1:4])
	ret['viscousForce'] = cleanList(raw[4:7])
	ret['pressureMoment'] = cleanList(raw[10:14])
	ret['viscousMoment'] = cleanList(raw[14:17])
	return ret
def processForceFile(path):
	"""
	Returns a list of dicts.
	"""
	lines = getLinesFromFile(path)
	ret = []
	for line in lines:
		if line.split()[0] != "#":
			dct = processForceLine(line)
			ret.append(dct)
	return ret


RUNNAME = sys.argv[1]
PLOTMODE = sys.argv[2]
if PLOTMODE == "f" or PLOTMODE == "c":
	if len(sys.argv) < 4:	
		print "Be sure to supply depth when requesting forces or coefficients. Exiting."
		sys.exit()
	else:
		DEPTH = float(sys.argv[3])
	if PLOTMODE=="c" and len(sys.argv) < 5:
		print "Be sure to supply both chord and depth when requesting coefficients. Exiting."
		sys.exit()
	else:
		CHORD = float(sys.argv[4])


caseDir = RUNNAME+"/case"
properChdir(caseDir)

if PLOTMODE == "r":
	os.system("./plotResiduals")
elif PLOTMODE == "f" or PLOTMODE == "c":
	forceFileName = "postProcessing/wings/0/forces.dat"
	data = processForceFile(forceFileName)
	if PLOTMODE == "f":
		if not os.path.exists("forces"):
 			os.makedirs("forces")
		lift = open("forces/lift","w")
		drag = open("forces/drag","w")
		moment = open("forces/moment","w")
		for dct in data:
			fp = dct['pressureForce']
			fv = dct['viscousForce']
			lift.write(str(dct['time'])+" "+str(fp[1]+fv[1])+"\n")
			drag.write(str(dct['time'])+" "+str(fp[0]+fv[0])+"\n")
			mp = dct['pressureMoment']
			mv = dct['viscousMoment']
			moment.write(str(dct['time'])+" "+str(mp[2]+mv[2])+"\n")
		lift.close()
		drag.close()
		moment.close()
		os.system("./plotForces")
	if PLOTMODE=="c":
		#get velocity
		velocity = readVelocity("0/U")
		if velocity == None:
			print "Velocity was not read! Exiting."
			sys.exit()
		#get density
		density = 1.18 # readDensity("constant/transportProperties")
		if density == None:
			print "Density was not read! Exiting."
			sys.exit()
		#get kinematic viscosity
		nu = readKinematicViscosity("constant/transportProperties")
		if nu == None:
			print "Kinematic vsicosity was not read! Exiting."
			sys.exit()
		dynamicPressure = 0.5*density*velocity**2
		referenceArea = CHORD*DEPTH
		print "Density: "+str(density)
		print "Velocity: "+str(velocity)
		# print "Dynamic Pressure: "+str(dynamicPressure)
		print "Reference Area: "+str(referenceArea)
		norm = 1.0/(dynamicPressure*referenceArea)
		# print "Normalization Quantity: "+str(norm)
		print "Reynolds number: "+str(velocity*CHORD/nu)
		# Now write
		if not os.path.exists("coefficients"):
 			os.makedirs("coefficients")
		liftCoeff = open("coefficients/cl","w")
		dragCoeff = open("coefficients/cd","w")
		momentCoeff = open("coefficients/cm","w")
		for dct in data:
			fp = dct['pressureForce']
			fv = dct['viscousForce']
			cl = (fp[1]+fv[1])*norm
			cd = (fp[0]+fv[0])*norm
			liftCoeff.write(str(dct['time'])+" "+str(cl)+"\n")
			dragCoeff.write(str(dct['time'])+" "+str(cd)+"\n")
			mp = dct['pressureMoment']
			mv = dct['viscousMoment']
			cm = (mp[2]+mv[2])*norm/CHORD
			momentCoeff.write(str(dct['time'])+" "+str(cm)+"\n")
		liftCoeff.close()
		dragCoeff.close()
		momentCoeff.close()
		os.system("./plotCoefficients")
else:
	print "Choose a valid plot option! Exiting."
	sys.exit()
