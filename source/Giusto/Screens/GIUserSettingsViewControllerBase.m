//
//  GIUserSettingsViewControllerBase.m
//  Giusto
//
//  Created by John Gabelmann on 9/17/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserSettingsViewControllerBase.h"

@interface GIUserSettingsViewControllerBase ()

@end

@implementation GIUserSettingsViewControllerBase

- (void) configureWithModelObject:(id<MYParseableModelObject>)modelObject
{
    self.userSettings = modelObject;
    [super configureWithModelObject:modelObject];
}
@end
