//
//  GIChangeDietViewControllerBase.m
//  Giusto
//
//  Created by Nielson Rolim on 7/20/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIChangeDietViewControllerBase.h"

@interface GIChangeDietViewControllerBase ()

@end

@implementation GIChangeDietViewControllerBase

- (void) configureWithModelObject:(GIUserProfile*)modelObject
{
    self.userProfile = modelObject;
    [super configureWithModelObject:modelObject];
}

@end
