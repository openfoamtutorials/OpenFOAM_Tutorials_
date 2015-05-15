#!/bin/bash

gnuplot -persist > /dev/null 2>&1 << EOF
	set title "Forces vs. Time"
	set xlabel "Time / Iteration"
	set ylabel "Force (N) or Moment (N*m)"
	
	plot	"forces.txt" using 1:2 title 'Lift' with linespoints,\
			"forces.txt" using 1:3 title 'Drag' with linespoints,\
			"forces.txt" using 1:4 title 'Moment' with linespoints
EOF