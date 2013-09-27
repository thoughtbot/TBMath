//
//  TBEnums.h
//  TBMath
//
//  Created by Theodore Calmes on 7/15/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#ifndef TBMath_TBEnums_h
#define TBMath_TBEnums_h

typedef enum { TBNumberTypeFloat, TBNumberTypeDouble } TBNumberType;
typedef union { float *floatArray; double *doubleArray; } TBNumberArray;

#endif
