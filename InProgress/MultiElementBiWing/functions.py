"""

"""
import os
import sys

def properChdir(mydir):
	if (os.path.isdir(mydir)):
		os.chdir(mydir)
	else:
		print "Directory not found ("+mydir+")! Exiting."
		sys.exit()

def is_integer(string):
    try:
        float(string)
        return True
    except ValueError:
        return False
def getLinesFromFile(filePath):
	myFile = open(filePath,"r") # First read in the current boundary file.
	lines = myFile.readlines()
	myFile.close()
	return lines
def indentLines(lst):
	# Adds indentation to a list of strings (lines).
	for i in range(len(lst)):
		lst[i]="\t"+lst[i]
	return lst
def writeToFile(myPath,myLines):
	myFile = open(myPath,"w")
	for line in myLines:
		myFile.write(line)
	myFile.close()

def addBoundary(boundaryFilePath,bname,btype,bphysicaltype,startface,nfaces):
	"""
	Adds a boundary entry to the constant/polyMesh/boundary file.
	Returns a list of the new lines.
	Assumes the following file format (for a file with N boundaries):
	N
	(
		myBoundary
		{
			type	myType;
			...
		}
		...
	)
	"""
	#First create the boundary to insert.
	entry = []
	entry.append(bname+"\n")
	entry.append("{\n")
	entry.append("\ttype\t\t"+btype+";\n")
	entry.append("\tphysicalType\t"+bphysicaltype+";\n")
	entry.append("\tnFaces\t\t"+str(nfaces)+";\n")
	entry.append("\tstartFace\t"+str(startface)+";\n")
	entry.append("}\n")
	entry = indentLines(entry)

	lines = getLinesFromFile(boundaryFilePath)
	for i in range(len(lines)):
		if is_integer(lines[i].strip()):
			lines[i] = str(int(lines[i].strip())+1)+"\n"
		if lines[i].strip() == "(":
			for newline in reversed(entry):
				lines.insert(i+1,newline)
			break

	writeToFile(boundaryFilePath,lines)

def changeBoundaryType(boundaryFilePath,bname,btype,bphysicaltype):
	"""
	Changes the type and physical type fields for a given field.
	Assumes the following file format (for a file with N boundaries):
	N
	(
		myBoundary
		{
			type	myType;
			...
		}
		...
	)
	"""

	lines = getLinesFromFile(boundaryFilePath)
	changed = 0
	for i in range(len(lines)):
		words = lines[i].split()
		if len(words) > 0:
			if words[0] == bname:
				k=1
				while lines[i+k].count("}")==0:
					entry = lines[i+k].split()
					if len(entry)>0:
						if entry[0]=="type":
							lines[i+k] = "\ttype\t\t"+btype+";\n"
							changed+=1
						if entry[0]=="physicalType":
							lines[i+k] = "\tphysicalType\t"+bphysicaltype+";\n"
							changed+=1
					if changed >= 2:
						break
					k+=1
		if changed>=2:
			break

	writeToFile(boundaryFilePath,lines)


def getNumberOfFaces(casePath):
	nfaces = -1

	# Run checkmesh to get output
	tmpout = casePath+"/"+"checkMeshLogTemp"
	os.system("checkMesh -case "+casePath+" -constant > "+tmpout)

	# Go through lines and get the faces count.
	lines = getLinesFromFile(tmpout)
	for line in lines:
		if line.count("internal faces:") > 0:
			words = line.split()
			nfaces = int(words[2])
			break
	else:
		print "Could not find number of faces! Exiting."
		sys.exit()
	
	os.remove(tmpout)
	return nfaces



def readVelocity(path):
	"""
	path: the file path of the U file.
	"""
	lines = getLinesFromFile(path)
	velocity = None
	for line in lines:
		if line.count("internalField") > 0:
			line = line.replace("(","")
			line = line.replace(")","")
			line = line.replace(";","")
			words = line.split()
			velocity = float(words[2])
			break
	return velocity

def readDensity(path):
	"""
	path: the file path of the transportProperties file.
	"""
	lines = getLinesFromFile(path)
	density = None
	for line in lines:
		if line.count("rho") > 0:
			line = line.replace(";","")
			density = float(line.split()[-1])
			break
	return density

def readKinematicViscosity(path):
	"""
	path: the file path of the transportProperties file.
	"""
	lines = getLinesFromFile(path)
	nu = None
	for line in lines:
		if line.count("nu") > 0 and line.count("nu0") == 0:
			line = line.replace(";","")
			nu = float(line.split()[-1])
			break
	return nu