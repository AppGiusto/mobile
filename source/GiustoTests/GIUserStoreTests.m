//
//  GIUserStoreTests.m
//  Giusto
//
//  Created by Vincil Bishop on 9/14/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XCTAsyncTestCase.h"
#import "GIModel.h"

@interface GIUserStoreTests : XCTAsyncTestCase

@end

@implementation GIUserStoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    /*
    NSError *error = nil;
    [PFUser logInWithUsername:@"DevUser" password:@"supersecret" error:&error];
    
    if (error) {
        XCTFail(@"error: %@\n%@",[error localizedDescription],error.userInfo);
    }
     */
    [GIModel sharedModel];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoginUser
{
    [self prepare];
    
    [[GIUserStore sharedStore] loginInBackgroundWithUsername:@"DevUser" password:@"supersecret" completion:^(id sender, BOOL success, NSError *error, id result) {
        
        XCTAssertTrue(error == nil, @"login error");
        XCTAssertTrue([PFUser currentUser] != nil, @"current parse user can't be nil");
        XCTAssertTrue([GIUserStore sharedStore].currentUser != nil, @"current GIUser can't be nil");
        XCTAssertTrue([GIUserStore sharedStore].authenticated, @"must be authenticated!");
        
        [self notify:kXCTUnitWaitStatusSuccess];
        
    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5];
}


- (void)testCreateUser
{
    [self prepare];
    
    [[GIUserStore sharedStore] signUpWithFirstName:@"TestFirstName2" lastName:@"TestLastName2" email:@"test2@test.com" city:@"Austin" state:@"TX" password:@"supersecret" completion:^(id sender, BOOL success, NSError *error, id result) {
        
        XCTAssertTrue(error == nil, @"login error");
        XCTAssertTrue([PFUser currentUser] != nil, @"current parse user can't be nil");
        XCTAssertTrue([GIUserStore sharedStore].currentUser != nil, @"current GIUser can't be nil");
        XCTAssertTrue([GIUserStore sharedStore].authenticated, @"must be authenticated!");
        
        // Test for a profile
        [self notify:kXCTUnitWaitStatusSuccess];

    }];
    
    [self waitForStatus:kXCTUnitWaitStatusSuccess timeout:5];
}

@end
