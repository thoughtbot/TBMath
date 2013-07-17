//
//  TBMatrixTest.m
//  TBMath
//
//  Created by Theodore Calmes on 7/11/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TBMatrix.h"

@interface TBMatrixTest : XCTestCase

@end

@implementation TBMatrixTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    TBMatrix I = TBMatrixMakeIdentity(4, TBNumberTypeFloat, false);
    TBPrintMatrix(I, " %.1f ");
    NSLog(@"HERE");
}

@end
