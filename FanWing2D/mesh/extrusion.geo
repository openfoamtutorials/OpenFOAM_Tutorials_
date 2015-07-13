//Extrusions
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
Function myExtrusion//From b=;l=;c=;p=; Get surf[];vol;newbase;
	n=c;
	Call generateArray;
	a[]=series[];
	s[]=a[];
	If(p!=1)
		r=p;n=c;lt=l;Call generateGeometricSeries;
		s[]=series[];
	EndIf
	If(p==1)
		ids[]=Extrude {0, 0, l} {
		   	Surface{b};
		   	Layers{c};
		 	Recombine;
		};
	EndIf
	If(p!=1)
		ids[]=Extrude {0, 0, l} {
			Surface{b};
			Layers{a[],s[]};
		   	Recombine;
		};
	EndIf
	//extremeLengths[]={s[1]-s[0],s[#s[]-1]-s[#s[]-2]};
	//maxLength=extremeLengths[1];
	//minLength=extremeLengths[0];
	//If(extremeLengths[0]>extremeLengths[1])
	//	maxLength=extremeLengths[0];
	//	minLength=extremeLengths[1];
	//EndIf
	//Printf("extremeLengths: %g %g",extremeLengths[0],extremeLengths[1]);
	newbase=ids[0];
	vol=ids[1];
	surf[]=ids[{2:#ids[]-1}];
	ce+=10000;
Return
Function extrude2d//from l,b, get surf[],vol
	ids[]=Extrude {0, 0, l} {
    		Surface{b};
    		Layers{1};
    		Recombine;
  	};
	vol=ids[1];
	surf[]=ids[{2:#ids[]-1}];
	ce+=1000;
Return
