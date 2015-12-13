//
//  GIChangeDietDetailViewControllerBase.m
//  Giusto
//
//  Created by Nielson Rolim on 7/26/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIChangeDietDetailViewControllerBase.h"

@interface GIChangeDietDetailViewControllerBase ()

@end

@implementation GIChangeDietDetailViewControllerBase

- (void) configureWithModelObject:(GIUserProfile*)modelObject
{
    self.userProfile = modelObject;
    [super configureWithModelObject:modelObject];
}

@end
