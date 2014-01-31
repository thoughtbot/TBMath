//
//  TBKalmanFilter.h
//  TBMath
//
//  Created by Theodore Calmes on 7/12/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#ifndef TBMath_TBKalmanFilter_h
#define TBMath_TBKalmanFilter_h

#import "TBMatrix.h"

typedef struct
{
    TBNumberType type;

    TBMatrix Q;
    TBMatrix R;
    TBMatrix A;
    TBMatrix H;
    TBMatrix P;
    TBMatrix x;

    int stateDimensions;
    int observableDimensions;

} TBKalmanFilter;

void TBFreeKalmanFilter(TBKalmanFilter f);

TBKalmanFilter TBKalmanFilterMake(int stateDimensions, int observableDimensions, TBNumberType type);
TBKalmanFilter TBKalmanFilterMakeForGPS(double gpsError, double noise);

void TBKalmanFilterUpdate(TBKalmanFilter *f, TBMatrix z);
TBMatrix TBKalmanFilterPredict(TBKalmanFilter f);

#endif
