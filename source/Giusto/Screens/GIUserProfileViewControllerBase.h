//
//  GIUserProfileViewControllerBase.h
//  Giusto
//
//  Created by Vincil Bishop on 9/3/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "MYModelObjectViewControllerBase.h"

@interface GIUserProfileViewControllerBase : MYModelObjectViewControllerBase

@property (nonatomic,strong) GIUserProfile *userProfile;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, assign) BOOL isReadOnlyMode;


- (void)configureViews;
- (void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;

@end
