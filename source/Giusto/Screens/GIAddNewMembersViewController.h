//
//  GIAddNewMembersViewController.h
//  Giusto
//
//  Created by John Gabelmann on 10/27/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserViewControllerBase.h"

@interface GIAddNewMembersViewController : GIUserViewControllerBase

@property (nonatomic, strong) NSArray *tableProfiles;
@property (nonatomic, strong) NSMutableArray *addedProfiles;
@property (nonatomic, strong) NSMutableArray *removedProfiles;

@end
