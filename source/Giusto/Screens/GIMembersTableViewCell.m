//
//  GIMembersTableViewCell.m
//  Giusto
//
//  Created by Timothy Raveling on 15-05-07.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import "GIMembersTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation GIMembersTableViewCell

- (void)configureContentsWithUserProfile:(GIUserProfile*)userProfile
{
    /*
    if (self.userProfile == nil)
    {
        self.userProfile = userProfile;
        if (self.attachedUser == nil)
        {
            PFUser *user = self.userProfile.parseObject[@"user"];
            [user fetchIfNeeded];
            self.attachedUser = [GIUser parseModelUserWithParseUser:user];
        }
    }
     */
    
    self.lbName.attributedText = [[NSAttributedString alloc] initWithString:[userProfile valueForKey:@"fullName"]
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                 NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                                                     size:18]
                                                                                 }];
    if (self.ivProfile && userProfile.photoURL)
    {
        [self.ivProfile setImageWithURL:userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    }
}


- (void)setUser:(GIUserProfile*)user
{
    self.userProfile = user;
    [self configureContentsWithUserProfile:self.userProfile];
    
    /*
    PFQuery *numberOfDependentsQuery = [[self.attachedUser.parseUser relationForKey:@"dependents"] query];
    numberOfDependentsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [numberOfDependentsQuery countObjectsInBackgroundWithBlock:^(int numberOfDependents, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (numberOfDependents > 0)
            {
                self.btDependents.hidden = NO;
                if (numberOfDependents == 1)
                    [self.btDependents setTitle:[NSString stringWithFormat:@"%i %@", numberOfDependents, NSLocalizedString(@"Dependent", @"Dependent")] forState:UIControlStateNormal];
                else
                    [self.btDependents setTitle:[NSString stringWithFormat:@"%i %@", numberOfDependents, NSLocalizedString(@"Dependents", @"Dependents")] forState:UIControlStateNormal];
            }
            else
            {
                self.btDependents.hidden = YES;
            }
        });
    }];
     */
}

@end
