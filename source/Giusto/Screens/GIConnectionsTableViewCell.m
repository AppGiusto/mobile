//
//  GIConnectionsTableViewCell.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-23.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionsTableViewCell.h"

@implementation GIConnectionsTableViewCell
- (IBAction)showDependents:(id)sender
{
    [self.delegate showDependentsForUserRepresentedInConnectionsTableViewCell:self];
}

- (void)configureContentsWithUserProfile:(GIUserProfile*)userProfile
{
    [super configureContentsWithUserProfile:userProfile];
    
    PFQuery *numberOfDependentsQuery = [[self.user.parseUser relationForKey:@"dependents"] query];
    numberOfDependentsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [numberOfDependentsQuery countObjectsInBackgroundWithBlock:^(int numberOfDependents, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (numberOfDependents > 0)
            {
                self.showDependentsButton.hidden = NO;
                if (numberOfDependents == 1)
                    [self.showDependentsButton setTitle:[NSString stringWithFormat:@"%i %@", numberOfDependents, NSLocalizedString(@"Dependent", @"Dependent")] forState:UIControlStateNormal];
                else
                    [self.showDependentsButton setTitle:[NSString stringWithFormat:@"%i %@", numberOfDependents, NSLocalizedString(@"Dependents", @"Dependents")] forState:UIControlStateNormal];
            }
            else
            {
                self.showDependentsButton.hidden = YES;
            }
        });
    }];
}
@end
