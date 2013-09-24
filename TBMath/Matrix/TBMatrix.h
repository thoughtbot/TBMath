//
//  TCMatrix.h
//  TBMath
//
//  Created by Theodore Calmes on 7/10/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBEnums.h"

#ifndef TBMath_TBMatrix_h
#define TBMath_TBMatrix_h

#define mTB_ij(i,j) TBMatrixIndexMake(i, j)
#define mTB_v(m,i,j) (m.type == TBNumberTypeDouble) ? TBMatrixDoubleValueAt(m, TBMatrixIndexMake(i, j)) : TBMatrixFloatValueAt(m, TBMatrixIndexMake(i, j))
#define mTB_sv(m,index,v) (m.type == TBNumberTypeDouble) ? TBSetMatrixDoubleValueAtIndex(&m, index, v) : TBSetMatrixFloatValueAtIndex(&m, index, v)

typedef struct TBMatrixIndex { int i; int j; } TBMatrixIndex;
TBMatrixIndex TBMatrixIndexMake(int i, int j);

typedef struct TBDimension { unsigned int rows; unsigned int cols; } TBDimension;
TBDimension TBDimensionMake(unsigned int rows, unsigned int cols);

/** 
 
 Note about autoRelease:
 
 When a matrix is set to autoRelease it will be freed upon use in an operation.

 EX:
    TBAddMatrix(TBMatrix *matrix, TBMatrix toAdd) will release toAdd if it is set to autoRelease.
    TBMatrixByAddingMatricies(TBMatrix A, TBMatrix B) will release A and B if they are set to autoRelease.
 
 Any function which returns a matrix will set the return matrix to be autoReleased.
 If you would like to keep that matrix in future operations, make sure to set its autoRelease property to false.
 
 The reason for this autoRelease funk is so that you can safely perfom compound operations without leaks.
 It enables the following: 
    TBMatrix I = TBMatrixByMultiplyingMatrices(A, TBMatrixByInvertingMatrix(A));
 
*/

typedef struct TBMatrix
{
    TBDimension dimension;

    TBNumberType type;
    union typeArray {
        float *floatArray;
        double *doubleArray;
    } array;

    bool autoRelease;

} TBMatrix;

#pragma mark - Set and get matrix elements

double TBMatrixDoubleValueAt(TBMatrix matrix, TBMatrixIndex index);
float TBMatrixFloatValueAt(TBMatrix matrix, TBMatrixIndex index);
void TBSetMatrixDoubleValueAtIndex(TBMatrix *matrix, TBMatrixIndex index, double value);
void TBSetMatrixFloatValueAtIndex(TBMatrix *matrix, TBMatrixIndex index, float value);

#pragma mark - Dealloc

void TBFreeMatrix(TBMatrix matrix);

#pragma mark - Matrix creation and copy

#define mTB_mk(d,t,a) TBMatrixMakeWithDimension(d,t,a)
TBMatrix TBMatrixMakeWithDimension(TBDimension dimension, TBNumberType type, bool autoRelease);

#define mTB_mkI(d,t,a) TBMatrixMakeIdentity(d,t,a)
TBMatrix TBMatrixMakeIdentity(int dimension, TBNumberType type, bool autoRelease);

#define mTB_cpy(m,a) TBMatrixCopy(m,a)
TBMatrix TBMatrixCopy(TBMatrix matrix, bool autoRelease);

#pragma mark - Matrix operations on matrix ref

void TBMatrixSetToMatrix(TBMatrix *A, TBMatrix B);
void TBMatrixTranspose(TBMatrix *matrix);
void TBMatrixInvert(TBMatrix *matrix);
void TBAddMatrix(TBMatrix *matrix, TBMatrix toAdd);
void TBSubtractMatrix(TBMatrix *matrix, TBMatrix toSubtract);
void TBScaleMatrix(TBMatrix *matrix, double scale);

#pragma mark - Matrix operations

/** C = M^T */
#define mTB_tr(m) TBMatrixByTransposingMatrix(m)
TBMatrix TBMatrixByTransposingMatrix(TBMatrix matrix);

/** C = M^-1 */
#define mTB_inv(m) TBMatrixByInvertingMatrix(m)
TBMatrix TBMatrixByInvertingMatrix(TBMatrix matrix);

/** C = A * B */
#define mTB_mul(A,B) TBMatrixByMultiplingMatricies(A,B)
TBMatrix TBMatrixByMultiplingMatricies(TBMatrix A, TBMatrix B);

/** C = A + B */
#define mTB_add(A,B) TBMatrixByAddingMatricies(A,B)
TBMatrix TBMatrixByAddingMatricies(TBMatrix A, TBMatrix B);

/** C = A - B */
#define mTB_sub(A,B) TBMatrixBySubtractingMatrices(A,B)
TBMatrix TBMatrixBySubtractingMatrices(TBMatrix A, TBMatrix B);

/** C = s * A */
#define mTB_smul(A,s) TBMatrixByScalingMatrix(A,s)
TBMatrix TBMatrixByScalingMatrix(TBMatrix A, double s);

#pragma mark - Printing

void TBPrintMatrix(TBMatrix matrix, const char *format);
void TBPrintMatrixMathematica(TBMatrix matrix, const char *format);

#pragma mark - Common Operations macros

/** C = A*B*A^T */
#define mTB_ABAT(A,B) mTB_mul(mTB_mul(A,B), mTB_tr(A))

/** C = A*B^T */
#define mTB_ABT(A,B) mTB_mul(A, mTB_tr(B))

#endif
