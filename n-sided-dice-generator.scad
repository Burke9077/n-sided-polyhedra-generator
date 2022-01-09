
//
// N-sided dice generator
//

numberOfFacesToGenerate = 18;
diceHeightInMm = 50;
diceDiameterInMm = 20;


/*
    SharpPyramid:
        Range: 6-∞ (even numbered dice only!)
*/
//Dice_SharpPyramid(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm);
module Dice_SharpPyramid(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm) {
    PyramidDice_Raw(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm);
}



/*
    SmoothedPyramid:
        Range: 6-∞ (even and odd numbers)
*/
Dice_SmoothedPyramid(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm);
module Dice_SmoothedPyramid(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm) {
    // Start with the sharp pyrmid
    roundingAmount = 5;//TODO !!!! needs to be var!!!
    $fn=100;

    union() {
        minkowski() {
            PyramidDice_Raw(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm);
            translate([0,0,diceHeightInMm/2/*-roundingAmount/2*/]) {
                //sphere(d = roundingAmount);
            }
        }
    }
}

module PyramidDice_Raw(numberOfFacesToGenerate, diceHeightInMm, diceDiameterInMm) {
    difference() {
        union() {
            PyramidDice_Component_Half(numberOfFacesToGenerate, floor(numberOfFacesToGenerate/2), true, diceHeightInMm, diceDiameterInMm);
            PyramidDice_Component_Half(numberOfFacesToGenerate, ceil(numberOfFacesToGenerate/2), false, diceHeightInMm, diceDiameterInMm);
        }

        // If the number of sides is odd we will need to trim the dice
        if (numberOfFacesToGenerate%2) {
            union() {
                // Top
                union() {
                    facesThisSide = floor(numberOfFacesToGenerate/2);
                    incrementDegTop = 360/facesThisSide;
                    startDegTop = incrementDegTop/2;
                    endDegTop = ((facesThisSide-1)*incrementDegTop)+startDegTop;
                    remainingAngle = 90 - startDegTop;
                    rotateAmount = facesThisSide%2 ? 0 : -startDegTop;

                    for (topDeg = [startDegTop : incrementDegTop : endDegTop]) {
                        rotate([0,0,topDeg]) {
                            translate([((sin(remainingAngle)*(diceDiameterInMm/2))/(sin(90)))*2,0,0]) {
                                rotate([180,0,rotateAmount]) {
                                    PyramidDice_Component_Half(numberOfFacesToGenerate, facesThisSide, true, diceHeightInMm, diceDiameterInMm);
                                }
                            }
                        }
                    }
                }

                // Bottom
                union () {
                    facesThisSide = floor(numberOfFacesToGenerate/2);
                    incrementDegBtm = 360/ceil(numberOfFacesToGenerate/2);
                    startDegBtm = incrementDegBtm/2;
                    endDegBtm = ((ceil(numberOfFacesToGenerate/2)-1)*incrementDegBtm)+startDegBtm;
                    remainingAngle = 90 - startDegBtm;
                    rotateAmount = facesThisSide%2 ? startDegBtm : -startDegBtm ;

                    rotate([0,0,180]) {
                        for (btmDeg = [startDegBtm : incrementDegBtm : endDegBtm]) {
                            rotate([0,0,btmDeg]) {
                                translate([((sin(remainingAngle)*(diceDiameterInMm/2))/(sin(90)))*2,0,0]) {
                                    rotate([180,0,rotateAmount]) {
                                        PyramidDice_Component_Half(numberOfFacesToGenerate, ceil(numberOfFacesToGenerate/2), false, diceHeightInMm, diceDiameterInMm);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


module PyramidDice_Component_Half(totalNumberOfFaces, fn, isTheTopSide, diceHeightInMm, diceDiameterInMm) {
    // r1/r2 values set the top or bottom diameter depending on which side we are building
    r1Val = 0;
    r2Val = 0;
    if (isTheTopSide) {
        translate([0, 0, diceHeightInMm/4]) {
            r1Val = diceDiameterInMm/2;
            cylinder($fn = fn, h = diceHeightInMm/2, r1 = r1Val, r2 = r2Val, center = true);
        }
    } else {
        translate([0, 0, -diceHeightInMm/4]) {
            r2Val = diceDiameterInMm/2;
            // If we have an even number of sides, don't rotate the bottom half. Otherwise
            // we'll rotate the bottom part so it's more evenly balanced.
            if (totalNumberOfFaces%2) {
                // Odd, rotate the part
                rotate([0,0,180]) {
                    cylinder($fn = fn, h = diceHeightInMm/2, r1 = r1Val, r2 = r2Val, center = true);
                }
            } else {
                // Even, don't rotate the part
                cylinder($fn = fn, h = diceHeightInMm/2, r1 = r1Val, r2 = r2Val, center = true);
            }
        }
    }
}
