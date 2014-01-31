//
//  TBKalmanFilter.c
//  TBMath
//
//  Created by Theodore Calmes on 7/12/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "TBKalmanFilter.h"

void TBFreeKalmanFilter(TBKalmanFilter f)
{
    TBFreeMatrix(f.Q);
    TBFreeMatrix(f.R);
    TBFreeMatrix(f.A);
    TBFreeMatrix(f.H);
    TBFreeMatrix(f.P);
    TBFreeMatrix(f.x);
}

TBKalmanFilter TBKalmanFilterMake(int sd, int od, TBNumberType type)
{
    TBKalmanFilter filter;

    filter.type = type;
    filter.stateDimensions = sd;
    filter.observableDimensions = od;

    filter.R = TBMatrixMakeWithDimension(TBDimensionMake(od, od), type, false);
    filter.Q = TBMatrixMakeWithDimension(TBDimensionMake(sd, sd), type, false);

    filter.A = TBMatrixMakeWithDimension(TBDimensionMake(sd, sd), type, false);
    filter.H = TBMatrixMakeWithDimension(TBDimensionMake(od, sd), type, false);

    filter.P = TBMatrixMakeWithDimension(TBDimensionMake(sd, sd), type, false);
    filter.x = TBMatrixMakeWithDimension(TBDimensionMake(sd,  1), type, false);

    return filter;
}

TBKalmanFilter TBKalmanFilterMakeForGPS(double gpsError, double noise)
{
    TBKalmanFilter filter = TBKalmanFilterMake(4, 2, TBNumberTypeDouble);

    /** Setup the model */

    double d = 1.0;
    double A[16] = {
        1, 0, d, 0,
        0, 1, 0, d,
        0, 0, 1, 0,
        0, 0, 0, 1
    };

    double H[8] = {
        1, 0, 0, 0,
        0, 1, 0, 0
    };

    /** Setup the model error */

    double sig = gpsError * gpsError;
    double Q[16] = {
        sig, 0.0, 0.0, 0.0,
        0.0, sig, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    };

    double obs = sig * noise;
    double R[4] = {
        obs, 0.0,
        0.0, obs
    };

    /** Initial Guess */

    double inf = 1E12;
    double P[16] = {
        inf, 0.0, 0.0, 0.0,
        0.0, inf, 0.0, 0.0,
        0.0, 0.0, inf, 0.0,
        0.0, 0.0, 0.0, inf
    };

    vDSP_vaddD(&A[0], 1, filter.A.array.doubleArray, 1, filter.A.array.doubleArray, 1, 16);
    vDSP_vaddD(&H[0], 1, filter.H.array.doubleArray, 1, filter.H.array.doubleArray, 1, 8);
    vDSP_vaddD(&Q[0], 1, filter.Q.array.doubleArray, 1, filter.Q.array.doubleArray, 1, 16);
    vDSP_vaddD(&R[0], 1, filter.R.array.doubleArray, 1, filter.R.array.doubleArray, 1, 4);
    vDSP_vaddD(&P[0], 1, filter.P.array.doubleArray, 1, filter.P.array.doubleArray, 1, 16);

    return filter;
}

void TBKalmanFilterUpdate(TBKalmanFilter *f, TBMatrix z)
{
    /* Time Update */

    // Priori state estimate: x_ = Ax
    TBMatrix x_ = mTB_mul(f->A, f->x);
    x_.autoRelease = false;

    // Priori estimate error covariance: P_ = APA^T + Q
    TBMatrix P_ = mTB_add(mTB_ABAT(f->A, f->P), f->Q);
    P_.autoRelease = false;

    /* Measurement update */

    // Gain K = P_H^T(HP_H^T + R)^-1
    TBMatrix K = mTB_mul(mTB_mul(P_, mTB_tr(f->H)), mTB_inv(mTB_add(mTB_ABAT(f->H, P_), f->R)));
    K.autoRelease = false;

    // Postiori estimate: x = x_ + K(z - H x_)
    TBMatrix x = mTB_add(x_, mTB_mul(K, mTB_sub(z, mTB_mul(f->H, x_))));

    // Postiori error convergence: P = P_ - K H P_
    TBMatrix P = mTB_sub(P_, mTB_mul(mTB_mul(K, f->H), P_));

    TBMatrixSetToMatrix(&(f->x), x);
    TBMatrixSetToMatrix(&(f->P), P);

    /* Free Memory */

    TBFreeMatrix(x_);
    TBFreeMatrix(P_);
    TBFreeMatrix(K);
}

TBMatrix TBKalmanFilterPredict(TBKalmanFilter f)
{
    return mTB_mul(f.H, f.x);
}

