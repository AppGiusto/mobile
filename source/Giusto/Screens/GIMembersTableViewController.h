//
//  GIMembersTableViewController.h
//  Giusto
//
//  Created by Timothy Raveling on 15-05-20.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIMembersTableViewController : UITableViewController

@property (nonatomic, retain) NSArray *userList;
@property (nonatomic, retain) NSString *viewTitle;

-(IBAction)hitDependents:(id)sender;
- (void)setUserProfiles:(NSArray*)users;

@end
