//Gmsh
Function autoLineLoop
	//put in lines[], change lines[], get line loop ce
	points[]=Boundary{Line{lines[0]};};
	currentEnd=points[1];
	ogStart=points[0];
	newEnd=-1;
	//Printf("Line %g: %g %g",lines[0],points[0],points[1]);
	For kk In {0:#lines[]-2}
		points[]=Boundary{Line{lines[kk+1]};};
		end=points[1];
		start=points[0];
		If(currentEnd==start)
			newEnd=end;
		EndIf
		If(currentEnd==end)
			lines[kk+1]=-lines[kk+1];
			newEnd=start;
		EndIf
		If(newEnd==-1)
			lines[kk]=-lines[kk];
			currentEnd=ogStart;
			If(currentEnd==start)
				newEnd=end;
			EndIf
			If(currentEnd==end)
				lines[kk+1]=-lines[kk+1];
				newEnd=start;
			EndIf
		EndIf
		currentEnd=newEnd;
	EndFor
	Line Loop(ce++)=lines[];
	//Printf("%g,%g,%g,%g",lines[0],lines[1],lines[2],lines[3]);
Return
Function PSS
	Plane Surface(ce++)=ce-1;
	Recombine Surface{ce};
	Transfinite Surface{ce};
Return
Function RSS
	Ruled Surface(ce++)=ce-1;
	Recombine Surface{ce};
	Transfinite Surface{ce};
Return
Function PSU
	Plane Surface(ce++)=ce-1;
	Recombine Surface{ce};
Return
Function RSU
	Ruled Surface(ce++)=ce-1;
	Recombine Surface{ce};
Return
Function TV
	Surface Loop(ce++)=surf[];
	Volume(ce++)=ce-1;
	Transfinite Volume{ce};
Return
Function pt//from tmp[]
	Printf("Printing tmp[]:");
	For tmpk In {0:#tmp[]-1}
		Printf("Entry %g: %g",tmpk,tmp[tmpk]);
	EndFor
Return
Function prepTrig
	cs=Cos(angle*Pi/180);
	sn=Sin(angle*Pi/180);
Return
