/*
Acronyms:
	LE: leading edge
	AOA: angle of attack
*/

Function calculate_quarter_chord
	/*
	Gives dx and dy such that the quarter chord position is at 0,0.
	Assumes we are starting with a 0-AOA chord line. 
	Inputs:
		target_aoa: the AOA of the chord line of the airfoil.
		target_chord: chord length. 
	Outputs:
		dx, dy: LE displacement to get the desired quarter-chord placement. 
	*/
	dx = -0.25*target_chord*Cos(target_aoa);
	dy = 0.25*target_chord*Sin(target_aoa);
Return