//
//  GIHomeViewControllerBaseViewController.m
//  Giusto
//
//  Created by Nielson Rolim on 6/22/15.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import "GIHomeViewControllerBase.h"

@interface GIHomeViewControllerBase ()

@end

@implementation GIHomeViewControllerBase

- (void) configureWithModelObject:(GIUserProfile*)modelObject
{
    self.userProfile = modelObject;
    [super configureWithModelObject:modelObject];
}


@end
