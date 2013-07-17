//
//  TBVector.h
//  TBMath
//
//  Created by Theodore Calmes on 7/15/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBEnums.h"

#ifndef TBMath_TBVector_h
#define TBMath_TBVector_h

typedef struct
{
    int length;

    TBNumberType type;
    union typeArray {
        float *floatArray;
        double *doubleArray;
    } array;

    bool autoRelease;

} TBVector;

TBVector TBVectorMakeWithLength(int length, TBNumberType type, bool autoRelease);


#endif
