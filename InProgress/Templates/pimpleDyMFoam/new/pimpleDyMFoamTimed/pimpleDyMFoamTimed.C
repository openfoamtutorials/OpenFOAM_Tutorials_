/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     |
    \\  /    A nd           | Copyright (C) 2011-2013 OpenFOAM Foundation
     \\/     M anipulation  |
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

Application
    pimpleDyMFoam.C

Description
    Transient solver for incompressible, flow of Newtonian fluids
    on a moving mesh using the PIMPLE (merged PISO-SIMPLE) algorithm.

    Turbulence modelling is generic, i.e. laminar, RAS or LES may be selected.

\*---------------------------------------------------------------------------*/

#include "fvCFD.H"
#include "dynamicFvMesh.H"
#include "singlePhaseTransportModel.H"
#include "turbulenceModel.H"
#include "pimpleControl.H"
#include "fvIOoptionList.H"

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

int main(int argc, char *argv[])
{
    #include "setRootCase.H"
    #include "createTime.H"
    #include "createDynamicFvMesh.H"
    #include "initContinuityErrs.H"

    pimpleControl pimple(mesh);

    #include "createFields.H"
    #include "createUf.H"
    #include "createFvOptions.H"
    #include "readTimeControls.H"
    #include "createPcorrTypes.H"
    #include "CourantNo.H"
    #include "setInitialDeltaT.H"

    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

    Info<< "\nStarting time loop\n" << endl;

    //Added code
    #include "StopWatch.H"
    StopWatch totalTime;
    StopWatch mainLoopTime;
    StopWatch readControlsTime;
    StopWatch CourantNoTime;
    StopWatch setDeltaTTime;
    StopWatch meshUpdateTime;
    StopWatch absoluteFluxTime;
    StopWatch correctPhiTime;
    StopWatch relativeFluxTime;
    StopWatch meshCourantNoTime;
    StopWatch pimpleTime;
        StopWatch UEqnTime;
        StopWatch pEqnTime;
        StopWatch turbEqnTime;
    StopWatch writeTime;
    StopWatch infoTime;
    //end

    //Added code
    totalTime.start();
    //end

    while (runTime.run())
    {
        mainLoopTime.start();

        readControlsTime.start();//Added code
        #include "readControls.H"
        readControlsTime.stop();//Added code
        CourantNoTime.start();//Added code
        #include "CourantNo.H"
        CourantNoTime.stop();//Added code

        setDeltaTTime.start();//Added code
        #include "setDeltaT.H"
        setDeltaTTime.stop();//Added code

        runTime++;

        infoTime.start();
        Info<< "Time = " << runTime.timeName() << nl << endl;
        infoTime.stop();

        meshUpdateTime.start();//Added code
        mesh.update();
        meshUpdateTime.stop();//Added code

        absoluteFluxTime.start();//Added code
        // Calculate absolute flux from the mapped surface velocity
        phi = mesh.Sf() & Uf;
        absoluteFluxTime.stop();//Added code

        correctPhiTime.start();//Added code
        if (mesh.changing() && correctPhi)
        {
            #include "correctPhi.H"
        }
        correctPhiTime.stop();//Added code

        relativeFluxTime.start();//Added code
        // Make the flux relative to the mesh motion
        fvc::makeRelative(phi, U);
        relativeFluxTime.stop();//Added code

        meshCourantNoTime.start();//Added code
        if (mesh.changing() && checkMeshCourantNo)
        {
            #include "meshCourantNo.H"
        }
        meshCourantNoTime.stop();//Added code

        pimpleTime.start();//Added code
        // --- Pressure-velocity PIMPLE corrector loop
        while (pimple.loop())
        {
            UEqnTime.start();//Added code
            #include "UEqn.H"
            UEqnTime.stop();//Added code

            pEqnTime.start();//Added code
            // --- Pressure corrector loop
            while (pimple.correct())
            {
                #include "pEqn.H"
            }
            pEqnTime.stop();//Added code

            turbEqnTime.start();//Added code
            if (pimple.turbCorr())
            {
                turbulence->correct();
            }
            turbEqnTime.stop();//Added code
        }
        pimpleTime.stop();//Added code

        writeTime.start();//Added code
        runTime.write();
        writeTime.stop();//Added code

        infoTime.start();
        Info<< "ExecutionTime = " << runTime.elapsedCpuTime() << " s"
            << "  ClockTime = " << runTime.elapsedClockTime() << " s"
            << nl << endl;
        infoTime.stop();

        mainLoopTime.stop();
    }

    //Added code
    totalTime.stop();
    Info<<"Time Profile: "
        <<"\n\tTotal Time (s): " << totalTime.getTotalTime()
        <<"\n\tMain Loop Time (%): " << mainLoopTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tRead Controls Time (%): " << readControlsTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tCourant Number Time (%): " << CourantNoTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tSet Delta T Time (%): " << setDeltaTTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tMesh Update Time (%): " << meshUpdateTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tAbsolute Flux Time (%): " << absoluteFluxTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tCorrect Phi Time (%): " << correctPhiTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tRelative Flux Time (%): " << relativeFluxTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tMesh Courant Number Time (%): " << meshCourantNoTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tPIMPLE Time (%): " << pimpleTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\t\tU Equation Time (%): " << UEqnTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\t\tp Equation Time (%): " << pEqnTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\t\tTurbulence Model Equation Time (%): " << turbEqnTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tWrite Time (%): " << writeTime.getTotalTime()/totalTime.getTotalTime()*100.0
        <<"\n\tInfo Time (%): " << infoTime.getTotalTime()/totalTime.getTotalTime()*100.0
    <<endl;
    //end

    Info<< "End\n" << endl;

    return 0;
}


// ************************************************************************* //
