//
//  GIModelUtilTests.m
//  Giusto
//
//  Created by Vincil Bishop on 9/14/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "GIModel.h"

@interface GIModelUtilTests : XCTAsyncTestCase

@end

@implementation GIModelUtilTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Make sure we set up parse...
    [GIModel sharedModel];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/*
- (void)testSeedModel
{
    [self prepare];
    
    [GIModelUtil seedModelWithCompletion:^(id sender, BOOL success, NSError *error, id result) {
        
        if (success) {
            [self notify:kXCTUnitWaitStatusSuccess];
        } else {
            [self notify:kXCTUnitWaitStatusFailure];
        }
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:3];
}
 */

@end
