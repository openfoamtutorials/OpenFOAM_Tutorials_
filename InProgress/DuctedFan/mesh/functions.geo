//gmsh
Function makeCircle//in: RR
	pp[]={};
	Point(ce++)={0,RR,0};pp[]+=ce;
	Point(ce++)={RR,0,0};pp[]+=ce;
	Point(ce++)={0,-RR,0};pp[]+=ce;
	Point(ce++)={-RR,0,0};pp[]+=ce;

	ll[]={};
	For kk In {0:3}
		Circle(ce++)={pp[kk],origin,pp[(kk+1)%4]};
		ll[]+=ce;
	EndFor
Return
Function autoLineLoop
	//in: lines[]
	//out: ce (line loop), lines[] (signs changed)
	points[]=Boundary{Line{lines[0]};};
	currentEnd=points[1];
	ogStart=points[0];
	newEnd=-1;
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
Function PSU2
	Plane Surface(ce++)=ce-1;
	//Recombine Surface{ce};
Return
Function RSU
	Ruled Surface(ce++)=ce-1;
	Recombine Surface{ce};
Return
Function pt//in: tmp[]
	Printf("Printing tmp[]:");
	For tmpk In {0:#tmp[]-1}
		Printf("Entry %g: %g",tmpk,tmp[tmpk]);
	EndFor
Return
Function prepTrig//in: angle
	cs=Cos(angle);
	sn=Sin(angle);
Return
Function extrude2d//from l,b, get surf[],vol
	ids[]=Extrude {0, 0, l} {
    		Surface{b};
    		Layers{1};
    		Recombine;
  	};
  	newbase=ids[0];
	vol=ids[1];
	surf[]=ids[{2:#ids[]-1}];
	ce+=1000;
Return
Function revolve
	//dir[],ori[],angle,bb,cc
	//newbase,surf[],vol
	ids[] = Extrude {{dir[0],dir[1],dir[2]}, {ori[0],ori[1],ori[2]}, angle} { 
		Surface{bb};
		Recombine;
		Layers{cc};
	};
	newbase=ids[0];
	vol=ids[1];
	surf[]=ids[{2:#ids[]-1}];
	ce+=10000;
Return
Function generateArray//From n; Get series[];
	series[]={};
	For k In {0:n-1}
		series[k]=1;
	EndFor
Return
Function generateGeometricSeries//From r,n,lt; Get series[];
	series[]={};
	sum=0;
	For k In {0:n-1}
		sum+=r^k;
	EndFor
	//Printf("Series:");
	sum2=0;
	For k In {0:n-1}
		sum2+=r^k;
		series[k]=sum2/sum;
		//Printf("%g",series[k]);
	EndFor
Return
Function extrude//From b=;l[]=;c=;p=; Get surf[];vol;newbase;
	n=c;
	Call generateArray;
	a[]=series[];
	s[]=a[];
	If(p!=1)
		r=p;n=c;lt=l;Call generateGeometricSeries;
		s[]=series[];
	EndIf
	If(p==1)
		ids[]=Extrude {l[0], l[1], l[2]} {
		   	Surface{b};
		   	Layers{c};
		 	Recombine;
		};
	EndIf
	If(p!=1)
		ids[]=Extrude {l[0], l[1], l[2]} {
			Surface{b};
			Layers{a[],s[]};
		   	Recombine;
		};
	EndIf
	If(c>1)
		extremeLengths[]={s[1]-s[0],s[#s[]-1]-s[#s[]-2]};
		maxLength=extremeLengths[1];
		minLength=extremeLengths[0];
		If(extremeLengths[0]>extremeLengths[1])
			maxLength=extremeLengths[0];
			minLength=extremeLengths[1];
		EndIf
	EndIf
	//Printf("extremeLengths: %g %g",extremeLengths[0],extremeLengths[1]);
	newbase=ids[0];
	vol=ids[1];
	surf[]=ids[{2:#ids[]-1}];
	ce+=10000;
Return
