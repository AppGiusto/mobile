//
//  GIUserTableViewCellBase.m
//  Giusto
//
//  Created by Elinam Hini on 2014-10-02.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserTableViewCellBase.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIUserTableViewCellBase ()
@property (strong, nonatomic) GIUserProfile *userProfile;
@end

@implementation GIUserTableViewCellBase

- (void)setUser:(GIUser *)user
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(user))];
    _user = user;
    [self willChangeValueForKey:NSStringFromSelector(@selector(user))];
    self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:@"..."
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:12.0],}];
    self.profileImageView.image = [UIImage imageNamed:@"AvatarImagePlaceholder"];
    [self.profileImageView setRoundCorners];
    
    [_user userProfileWithBlock:^(id sender, BOOL success, NSError *error, GIUserProfile *userProfile) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureContentsWithUserProfile:userProfile];
        });
    }];
}

- (void)configureContentsWithUserProfile:(GIUserProfile*)userProfile
{
    if (self.userProfile == nil)
    {
        self.userProfile = userProfile;
        if (_user == nil)
        {
            PFUser *user = self.userProfile.parseObject[@"user"];
            [user fetchIfNeeded];
            _user = [GIUser parseModelUserWithParseUser:user];
        }
    }
    
    self.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:[userProfile valueForKey:@"fullName"]
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                 NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                                                     size:18]
                                                                                 }];
    if (self.profileImageView && userProfile.photoURL)
    {
        [self.profileImageView setImageWithURL:userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    }
}
@end
