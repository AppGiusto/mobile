//
//  GIUserProfileViewControllerBase.m
//  Giusto
//
//  Created by Vincil Bishop on 9/3/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserProfileViewControllerBase.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface GIUserProfileViewControllerBase ()

@end

@implementation GIUserProfileViewControllerBase

- (void) configureWithModelObject:(GIUserProfile*)modelObject
{
    self.userProfile = modelObject;
    [super configureWithModelObject:modelObject];
    [self.view hideProgressHUD];
}


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view showProgressHUD];
    
    if (!self.userProfile) {
        [self configureWithModelObject:[GIUserStore sharedStore].currentUser.userProfile];
    } else {
        [self.view hideProgressHUD];
    }
    [self configureViews];
}


#pragma mark - Private Methods

- (void)configureViews
{
    if (self.profileImageView && self.userProfile.photoURL) {
        [self.profileImageView setImageWithURL:self.userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    }
    
    if (self.nameLabel && self.userProfile.fullName) {
        self.nameLabel.text = self.userProfile.fullName;
    }
}

-(void)setRoundedView:(UIView *)roundedView toDiameter:(float)newSize;
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
}

@end
