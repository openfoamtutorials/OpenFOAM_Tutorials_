/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     |
    \\  /    A nd           | Copyright (C) 2012 OpenFOAM Foundation
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

\*---------------------------------------------------------------------------*/

#include "rampedAxisRotationMotion.H"
#include "addToRunTimeSelectionTable.H"
#include "unitConversion.H"

using namespace Foam::constant::mathematical;

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

namespace Foam
{
namespace solidBodyMotionFunctions
{
    defineTypeNameAndDebug(rampedAxisRotationMotion, 0);
    addToRunTimeSelectionTable
    (
        solidBodyMotionFunction,
        rampedAxisRotationMotion,
        dictionary
    );
}
}


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

Foam::solidBodyMotionFunctions::rampedAxisRotationMotion::rampedAxisRotationMotion
(
    const dictionary& SBMFCoeffs,
    const Time& runTime
)
:
    solidBodyMotionFunction(SBMFCoeffs, runTime)
{
    read(SBMFCoeffs);
}


// * * * * * * * * * * * * * * * * Destructors * * * * * * * * * * * * * * * //

Foam::solidBodyMotionFunctions::rampedAxisRotationMotion::~rampedAxisRotationMotion()
{}


// * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * * //

Foam::septernion
Foam::solidBodyMotionFunctions::rampedAxisRotationMotion::transformation() const
{
    scalar t = time_.value();
    // Rotation around centre of gravity (in radians)
    vector theta(0,0,0);

    vector baseTheta
    (
        t*(radialVelocity0_.x()),
        t*(radialVelocity0_.y()),
        t*(radialVelocity0_.z())
    );
    vector thetaDot0
    (
        (radialVelocity0_.x()),
        (radialVelocity0_.y()),
        (radialVelocity0_.z())
    );
    vector thetaDotf
    (
        (radialVelocityf_.x()),
        (radialVelocityf_.y()),
        (radialVelocityf_.z())
    );
    vector dThetaDot=thetaDotf-thetaDot0;
    
    theta+=baseTheta;
    if(t>tf_){
	theta+=(tf_-t0_)*dThetaDot/2+(t-tf_)*thetaDotf;
    } else if (t>t0_) {
	vector thetaDotDiff=(t-t0_)/(tf_-t0_)*dThetaDot;
	theta+=(t-t0_)*thetaDotDiff/2;
    }
    //scalar magTheta = mag(theta);
    //quaternion R(theta/magTheta, magTheta);
    quaternion R(theta.x(),theta.y(),theta.z());
    septernion TR(septernion(CofG_)*R*septernion(-CofG_));

    Info<< "solidBodyMotionFunctions::rampedAxisRotationMotion::transformation(): "
        << "Time = " << t << " transformation: " << TR << endl;

    return TR;
}


bool Foam::solidBodyMotionFunctions::rampedAxisRotationMotion::read
(
    const dictionary& SBMFCoeffs
)
{
    solidBodyMotionFunction::read(SBMFCoeffs);

    SBMFCoeffs_.lookup("COFR") >> CofG_;
    SBMFCoeffs_.lookup("OMEGA0") >> radialVelocity0_;
    SBMFCoeffs_.lookup("OMEGAF") >> radialVelocityf_;
    SBMFCoeffs_.lookup("T0") >> t0_;
    SBMFCoeffs_.lookup("TF") >> tf_;

    return true;
}

// ************************************************************************* //
