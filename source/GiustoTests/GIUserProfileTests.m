//
//  GIUserProfileTests.m
//  Giusto
//
//  Created by Vincil Bishop on 9/14/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"

@interface GIUserProfileTests : XCTAsyncTestCase

@end

@implementation GIUserProfileTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [GIModel sharedModel];
    
    [[GIUserStore sharedStore] loginWithUsername:@"test@test.com" password:@"supersecret" error:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateUserProfile
{
    [self prepare];
    
    [[GIUserProfileStore sharedStore] createUserProfileWithUser:[GIUserStore sharedStore].currentUser firstName:@"TestFirstName" lastName:@"TestLastName" city:@"Austin" state:@"TX" completion:^(id sender, BOOL success, NSError *error, id result) {
        
        XCTAssertTrue(result, @"result cannot be nil");
        
        [self notify:kXCTUnitWaitStatusSuccess];
        
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5];
}

@end
