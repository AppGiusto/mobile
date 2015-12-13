//
//  GIUserTableViewCellBase.h
//  Giusto
//
//  Created by Elinam Hini on 2014-10-02.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "MYModelObjectTableViewCellBase.h"

@interface GIUserTableViewCellBase : UITableViewCell
@property (strong, nonatomic) GIUser *user;
@property (strong, nonatomic, readonly) GIUserProfile *userProfile; // only resolved if user is nil and cell is configured with a profile
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *connectionRequestButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;

// only to be called by subclasses
- (void)configureContentsWithUserProfile:(GIUserProfile*)userProfile;
@end
