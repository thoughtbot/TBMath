//
//  TBVector.m
//  TBMath
//
//  Created by Theodore Calmes on 7/15/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBVector.h"
#import <Accelerate/Accelerate.h>

TBVector TBVectorMakeWithLength(int length, TBNumberType type, bool autoRelease)
{
    TBVector vector;
    vector.type = type;
    vector.length = length;
    vector.autoRelease = autoRelease;

    switch (type) {
        case TBNumberTypeDouble:
            vector.array.doubleArray = (double *)calloc(length, sizeof(double));
            break;
        case TBNumberTypeFloat:
            vector.array.floatArray = (float *)calloc(length, sizeof(float));
            break;
    }

    return vector;
}