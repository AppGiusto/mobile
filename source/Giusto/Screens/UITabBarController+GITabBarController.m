//
//  UITabBarController+GITabBarController.m
//  Giusto
//
//  Created by Vincil Bishop on 9/14/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "UITabBarController+GITabBarController.h"
#import "GIProfileTabBarController.h"

@implementation UITabBarController (GITabBarController)

+ (GIProfileTabBarController*) profileTabBarController
{
    return [GIProfileTabBarController sharedInstance];
}

@end
