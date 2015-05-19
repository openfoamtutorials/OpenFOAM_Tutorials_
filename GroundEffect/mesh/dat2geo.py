#!/usr/bin/python

import os

dat_file_name = "NACA2412.dat"
geo_file_name = "NACA2412.geo"
skip_lines = 1
coordinates_per_line = 5

coordinates = []
with open(dat_file_name) as opened_file:
	skipped_lines = 0
	for line in opened_file:
		if skipped_lines < skip_lines:
			skipped_lines = skipped_lines + 1
			continue
		else:
			coordinates += [line.split()]

geo_file = open(geo_file_name,'w')

geo_file.write("airfoil_points = "+str(len(coordinates))+";\n")

geo_file.write("airfoil_x[] = {\n")
point_number = 0
for point in coordinates:
	point_number = point_number + 1
	geo_file.write("\t"+point[0])
	if point_number < len(coordinates):
		geo_file.write(",")
	if point_number % coordinates_per_line == 0:
		geo_file.write("\n")
geo_file.write(" };\n")

geo_file.write("airfoil_y[] = {\n")
point_number = 0
for point in coordinates:
	point_number = point_number + 1
	geo_file.write("\t"+point[1])
	if point_number < len(coordinates):
		geo_file.write(",")
	if point_number % coordinates_per_line == 0:
		geo_file.write("\n")
geo_file.write(" };\n")

geo_file.close()