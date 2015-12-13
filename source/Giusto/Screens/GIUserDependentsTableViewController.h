//
//  GIUserDependentsTableViewController.h
//  Giusto
//
//  Created by John Gabelmann on 10/21/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GIUserDependentsTableViewController : UITableViewController

@property (nonatomic, strong) GIUser *selectedUser;
@property (nonatomic, strong) GIUserProfile *selectedUserProfile;
@property (nonatomic, strong) NSMutableArray *selectedProfiles;

@property (nonatomic, strong) NSArray *userProfiles;
@property (nonatomic, strong) NSMutableArray *removedProfiles;
@property (nonatomic, strong) NSMutableArray *addedProfiles;

@end
