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

Class
    Foam::solidBodyMotionFunctions::rampedAxisRotationMotion

Description
    Constant velocity rotation around CoG. Similar to rotatingMotion but
    motion specified as rotation vector.

SourceFiles
    rampedAxisRotationMotion.C

\*---------------------------------------------------------------------------*/

#ifndef rampedAxisRotationMotion_H
#define rampedAxisRotationMotion_H

#include "solidBodyMotionFunction.H"
#include "primitiveFields.H"
#include "point.H"

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{
namespace solidBodyMotionFunctions
{

/*---------------------------------------------------------------------------*\
                          Class rampedAxisRotationMotion Declaration
\*---------------------------------------------------------------------------*/

class rampedAxisRotationMotion
:
    public solidBodyMotionFunction
{
    // Private data

        //- Centre of gravity
        point CofG_;

        //- Rotational velocity (deg/s)
        vector radialVelocity0_;
        vector radialVelocityf_;
	scalar t0_,tf_;


    // Private Member Functions

        //- Disallow copy construct
        rampedAxisRotationMotion(const rampedAxisRotationMotion&);

        //- Disallow default bitwise assignment
        void operator=(const rampedAxisRotationMotion&);


public:

    //- Runtime type information
    TypeName("rampedAxisRotationMotion");


    // Constructors

        //- Construct from components
        rampedAxisRotationMotion
        (
            const dictionary& SBMFCoeffs,
            const Time& runTime
        );


    //- Destructor
    virtual ~rampedAxisRotationMotion();


    // Member Functions

        //- Return the solid-body motion transformation septernion
        virtual septernion transformation() const;

        //- Update properties from given dictionary
        virtual bool read(const dictionary& SBMFCoeffs);
};


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace solidBodyMotionFunctions
} // End namespace Foam

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

#endif

// ************************************************************************* //
