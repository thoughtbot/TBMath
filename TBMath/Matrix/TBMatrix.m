//
//  TBMatrix.c
//  TBMath
//
//  Created by Theodore Calmes on 7/10/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "TBMatrix.h"

#pragma mark - Misc

TBMatrixIndex TBMatrixIndexMake(int i, int j)
{
    TBMatrixIndex index; index.i = i; index.j = j; return index;
}

TBDimension TBDimensionMake(unsigned int rows, unsigned int cols)
{
    TBDimension d; d.rows = rows; d.cols = cols; return d;
}

#pragma mark - Setters and Getters

double TBMatrixDoubleValueAt(TBMatrix matrix, TBMatrixIndex index)
{
    return matrix.array.doubleArray[index.i * matrix.dimension.cols + index.j];
}

float TBMatrixFloatValueAt(TBMatrix matrix, TBMatrixIndex index)
{
    return matrix.array.floatArray[index.i * matrix.dimension.cols + index.j];
}

void TBSetMatrixDoubleValueAtIndex(TBMatrix *matrix, TBMatrixIndex index, double value)
{
    matrix->array.doubleArray[index.i * matrix->dimension.cols + index.j] = value;
}

void TBSetMatrixFloatValueAtIndex(TBMatrix *matrix, TBMatrixIndex index, float value)
{
    matrix->array.floatArray[index.i * matrix->dimension.cols + index.j] = value;
}

#pragma mark - Dealloc

void TBFreeMatrix(TBMatrix matrix)
{
    if (matrix.type == TBNumberTypeDouble) {
        free(matrix.array.doubleArray);
    } else {
        free(matrix.array.floatArray);
    }
}

#pragma mark - Matrix Creation

TBMatrix TBMatrixMakeWithDimension(TBDimension dimension, TBNumberType type, bool autoRelease)
{
    TBMatrix matrix;
    matrix.type = type;
    matrix.dimension = dimension;
    matrix.autoRelease = autoRelease;

    switch (type) {
        case TBNumberTypeDouble:
            matrix.array.doubleArray = (double *)calloc(dimension.cols * dimension.rows, sizeof(double));
            break;
        case TBNumberTypeFloat:
            matrix.array.floatArray = (float *)calloc(dimension.cols * dimension.rows, sizeof(float));
            break;
    }

    return matrix;
}

TBMatrix TBMatrixMakeIdentity(int dimension, TBNumberType type, bool autoRelease)
{
    TBMatrix matrix = TBMatrixMakeWithDimension(TBDimensionMake(dimension, dimension), type, autoRelease);

    for (int i = 0; i < dimension; i++) {
        if (type == TBNumberTypeDouble) {
            matrix.array.doubleArray[i * dimension + i] = 1.0;
        }
        else {
            matrix.array.floatArray[i * dimension + i] = 1.0;
        }
    }

    return matrix;
}

TBMatrix TBMatrixCopy(TBMatrix matrix, bool autoRelease)
{
    TBMatrix copy = TBMatrixMakeWithDimension(matrix.dimension, matrix.type, autoRelease);

    switch (matrix.type) {
        case TBNumberTypeDouble:
            vDSP_vaddD(copy.array.doubleArray, 1, matrix.array.doubleArray, 1, copy.array.doubleArray, 1, copy.dimension.rows * copy.dimension.cols);
            break;
        case TBNumberTypeFloat:
            vDSP_vadd(copy.array.floatArray, 1, matrix.array.floatArray, 1, copy.array.floatArray, 1, copy.dimension.rows * copy.dimension.cols);
            break;
    }

    return copy;
}

#pragma mark - Methods which transform by reference a matrix

void TBMatrixSetToMatrix(TBMatrix *A, TBMatrix B)
{
    int rows = A->dimension.rows;
    int cols = A->dimension.cols;

    assert(rows == B.dimension.rows && cols == B.dimension.cols);

    switch (A->type) {
        case TBNumberTypeDouble:
            for (int i = 0; i < rows * cols; i++) {
                A->array.doubleArray[i] = B.array.doubleArray[i];
            }
            break;
        case TBNumberTypeFloat:
            for (int i = 0; i < rows * cols; i++) {
                A->array.floatArray[i] = B.array.floatArray[i];
            }
            break;
    }

    if (B.autoRelease) {
        TBFreeMatrix(B);
    }
}

void TBMatrixTranspose(TBMatrix *m)
{
    switch (m->type) {
        case TBNumberTypeDouble:
            vDSP_mtransD(m->array.doubleArray, 1, m->array.doubleArray, 1, m->dimension.cols, m->dimension.rows);
            break;
        case TBNumberTypeFloat:
            vDSP_mtrans(m->array.floatArray, 1, m->array.floatArray, 1, m->dimension.cols, m->dimension.rows);
            break;
    }
}

void TBMatrixInvert(TBMatrix *matrix)
{
    TBMatrix copy = TBMatrixCopy(*matrix, true);
    TBMatrix inverse = TBMatrixByInvertingMatrix(copy);

    for (int i = 0; i < (int)powf(inverse.dimension.rows, 2); i++) {
        if (matrix->type == TBNumberTypeDouble) {
            matrix->array.doubleArray[i] = inverse.array.doubleArray[i];
        }
        else {
            matrix->array.floatArray[i] = inverse.array.floatArray[i];
        }
    }

    TBFreeMatrix(inverse);
}

void TBAddMatrix(TBMatrix *A, TBMatrix B)
{
    assert(A->dimension.cols == B.dimension.cols && A->dimension.rows == B.dimension.rows);

    int N = B.dimension.cols;
    int M = B.dimension.rows;

    switch (A->type) {
        case TBNumberTypeDouble:
            vDSP_vaddD(A->array.doubleArray, 1, B.array.doubleArray, 1, A->array.doubleArray, 1, N * M);
            break;
        case TBNumberTypeFloat:
            vDSP_vadd(A->array.floatArray, 1, B.array.floatArray, 1, A->array.floatArray, 1, N * M);
            break;
    }

    if (B.autoRelease) {
        TBFreeMatrix(B);
    }
}

void TBSubtractMatrix(TBMatrix *A, TBMatrix B)
{
    assert(A->dimension.cols == B.dimension.cols && A->dimension.rows == B.dimension.rows);

    int N = B.dimension.cols;
    int M = B.dimension.rows;

    switch (A->type) {
        case TBNumberTypeDouble:
            vDSP_vsubD(B.array.doubleArray, 1, A->array.doubleArray, 1, A->array.doubleArray, 1, N * M);
            break;
        case TBNumberTypeFloat:
            vDSP_vsub(B.array.floatArray, 1, A->array.floatArray, 1, A->array.floatArray, 1, N * M);
            break;
    }

    if (B.autoRelease) {
        TBFreeMatrix(B);
    }
}

void TBScaleMatrix(TBMatrix *A, double scale)
{
    float fscale = (float)scale;
    switch (A->type) {
        case TBNumberTypeDouble:
            vDSP_vsmulD(A->array.doubleArray, 1, &scale, A->array.doubleArray, 1, A->dimension.rows * A->dimension.cols);
            break;
        case TBNumberTypeFloat:
            vDSP_vsmul(A->array.floatArray, 1, &fscale, A->array.floatArray, 1, A->dimension.rows * A->dimension.cols);
            break;
    }
}

#pragma mark - Methods which make new matrices

TBMatrix TBMatrixByTransposingMatrix(TBMatrix m)
{
    TBMatrix mt = TBMatrixMakeWithDimension(TBDimensionMake(m.dimension.cols, m.dimension.rows), m.type, true);
    switch (m.type) {
        case TBNumberTypeDouble:
            vDSP_mtransD(m.array.doubleArray, 1, mt.array.doubleArray, 1, m.dimension.cols, m.dimension.rows);
            break;
        case TBNumberTypeFloat:
            vDSP_mtrans(m.array.floatArray, 1, mt.array.floatArray, 1, m.dimension.cols, m.dimension.rows);
            break;
    }

    if (m.autoRelease) {
        TBFreeMatrix(m);
    }

    return mt;
}

TBMatrix TBMatrixByInvertingMatrix(TBMatrix matrix)
{
    assert(matrix.dimension.rows == matrix.dimension.cols);

    // sgelss solves for the least squares equation using singular value decomposition. By passing b = Identity(dimmentions) to |Ax - b| we get back the inverse of A.

    long N = (long)matrix.dimension.rows;
    TBMatrix A = TBMatrixCopy(matrix, true);

    long ERR;
    long LDWORK = -1;
    long IRANK = -1;
    long NRHS = N;
    long LDA = N;
    long LDB = N;

    TBMatrix sing = TBMatrixMakeWithDimension(TBDimensionMake(N, N), matrix.type, true);
    TBMatrix B = TBMatrixMakeIdentity(N, matrix.type, true);

    switch (matrix.type) {
        case TBNumberTypeDouble:
        {
            double *WORK = calloc(1, sizeof(double));
            double RCOND = -1.0f;

            dgelss_(&N, &N, &NRHS, A.array.doubleArray, &LDA, B.array.doubleArray, &LDB, sing.array.doubleArray, &RCOND, &IRANK, WORK, &LDWORK, &ERR);

            LDWORK = WORK[0];
            free(WORK);
            WORK = calloc(LDWORK, sizeof(double));

            dgelss_(&N, &N, &NRHS, A.array.doubleArray, &LDA, B.array.doubleArray, &LDB, sing.array.doubleArray, &RCOND, &IRANK, WORK, &LDWORK, &ERR);

            free(WORK);

            break;
        }

        case TBNumberTypeFloat:
        {
            float *WORK = calloc(1, sizeof(float));
            float RCOND = -1.0f;

            sgelss_(&N, &N, &NRHS, A.array.floatArray, &LDA, B.array.floatArray, &LDB, sing.array.floatArray, &RCOND, &IRANK, WORK, &LDWORK, &ERR);

            LDWORK = WORK[0];
            free(WORK);
            WORK = calloc(LDWORK, sizeof(float));

            sgelss_(&N, &N, &NRHS, A.array.floatArray, &LDA, B.array.floatArray, &LDB, sing.array.floatArray, &RCOND, &IRANK, WORK, &LDWORK, &ERR);

            free(WORK);

            break;
        }
    }
    
    TBFreeMatrix(A);
    TBFreeMatrix(sing);

    if (matrix.autoRelease) {
        TBFreeMatrix(matrix);
    }
    
    return B;
}

TBMatrix TBMatrixByMultiplingMatricies(TBMatrix A, TBMatrix B)
{
    assert(A.dimension.cols == B.dimension.rows);

    int M = A.dimension.rows;
    int N = B.dimension.cols;
    int P = B.dimension.rows;

    TBMatrix C = TBMatrixMakeWithDimension(TBDimensionMake(M, N), A.type, true);

    switch (A.type) {
        case TBNumberTypeDouble:
            vDSP_mmulD(A.array.doubleArray, 1, B.array.doubleArray, 1, C.array.doubleArray, 1, M, N, P);
            break;
        case TBNumberTypeFloat:
            vDSP_mmul(A.array.floatArray, 1, B.array.floatArray, 1, C.array.floatArray, 1, M, N, P);
            break;
    }

    if (A.autoRelease) {
        TBFreeMatrix(A);
    }
    if (B.autoRelease) {
        TBFreeMatrix(B);
    }

    return C;
}

TBMatrix TBMatrixByAddingMatricies(TBMatrix A, TBMatrix B)
{
    assert(A.dimension.cols == B.dimension.cols && A.dimension.rows == B.dimension.rows);

    int N = B.dimension.cols;
    int M = B.dimension.rows;

    TBMatrix C = TBMatrixMakeWithDimension(TBDimensionMake(M, N), A.type, true);

    switch (A.type) {
        case TBNumberTypeDouble:
            vDSP_vaddD(A.array.doubleArray, 1, B.array.doubleArray, 1, C.array.doubleArray, 1, N * M);
            break;
        case TBNumberTypeFloat:
            vDSP_vadd(A.array.floatArray, 1, B.array.floatArray, 1, C.array.floatArray, 1, N * M);
            break;
    }

    if (A.autoRelease) {
        TBFreeMatrix(A);
    }
    if (B.autoRelease) {
        TBFreeMatrix(B);
    }

    return C;
}

TBMatrix TBMatrixBySubtractingMatrices(TBMatrix A, TBMatrix B)
{
    assert(A.dimension.cols == B.dimension.cols && A.dimension.rows == B.dimension.rows);

    int N = B.dimension.cols;
    int M = B.dimension.rows;

    TBMatrix C = TBMatrixMakeWithDimension(TBDimensionMake(M, N), A.type, true);

    switch (A.type) {
        case TBNumberTypeDouble:
            vDSP_vsubD(B.array.doubleArray, 1, A.array.doubleArray, 1, C.array.doubleArray, 1, N * M);
            break;
        case TBNumberTypeFloat:
            vDSP_vsub(B.array.floatArray, 1, A.array.floatArray, 1, C.array.floatArray, 1, N * M);
            break;
    }

    if (A.autoRelease) {
        TBFreeMatrix(A);
    }
    if (B.autoRelease) {
        TBFreeMatrix(B);
    }
    
    return C;
}

TBMatrix TBMatrixByScalingMatrix(TBMatrix A, double scale)
{
    TBMatrix sA = TBMatrixMakeWithDimension(A.dimension, A.type, true);
    float fscale = (float)scale;

    switch (A.type) {
        case TBNumberTypeDouble:
            vDSP_vsmulD(A.array.doubleArray, 1, &scale, sA.array.doubleArray, 1, A.dimension.rows * A.dimension.cols);
            break;
        case TBNumberTypeFloat:
            vDSP_vsmul(A.array.floatArray, 1, &fscale, sA.array.floatArray, 1, A.dimension.rows * A.dimension.cols);
            break;
    }

    if (A.autoRelease) {
        TBFreeMatrix(A);
    }

    return sA;
}

#pragma mark - Debug

void TBPrintMatrix(TBMatrix matrix, const char *format)
{
    for (int i = 0; i < matrix.dimension.rows; i++) {
        for (int j = 0; j < matrix.dimension.cols; j++) {
            printf(format, mTB_v(matrix, i, j));
        }
        printf("\n");
    }
    printf("\n");
}

void TBPrintMatrixMathematica(TBMatrix matrix, const char *format)
{
    int rows = matrix.dimension.rows;
    int cols = matrix.dimension.cols;

    printf("\n{");
    for (int i = 0; i < rows; i++) {
        printf("{");
        for (int j = 0; j < cols; j++) {

            printf(format, mTB_v(matrix, i, j));
            
            if (j != cols - 1) {
                printf(",");
            }
        }
        printf("}");
        if (i != rows - 1) {
            printf(",");
        }
    }
    printf("}\n");
}





