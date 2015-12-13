//
//  GIAppDelegate.h
//  Giusto
//
//  Created by Vincil Bishop on 8/21/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIAppDelegate : UIResponder <UIApplicationDelegate>

#pragma mark - Properties

@property (strong, nonatomic) UIWindow *window;


#pragma mark - Class Methods

+ (GIAppDelegate *)sharedDelegate;

@end
