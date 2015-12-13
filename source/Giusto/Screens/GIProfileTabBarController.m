//
//  GIProfileTabBarController.m
//  Giusto
//
//  Created by Vincil Bishop on 9/14/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIProfileTabBarController.h"
#import "Helpshift.h"

@interface GIProfileTabBarController ()<UITabBarControllerDelegate>

@end

@implementation GIProfileTabBarController


static GIProfileTabBarController *_sharedInstance;

+ (GIProfileTabBarController*) sharedInstance
{
    return _sharedInstance;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _sharedInstance = self;
        self.delegate = self;
    }
    
    return self;
}

-(UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
    return [self.selectedViewController viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Orange hightlight color
    self.tabBar.tintColor = [UIColor colorWithRed:241.0/255.0 green:122.0/255.0 blue:58.0/255.0 alpha:1];
}

// Go to tables

// Go to connections

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:NSClassFromString(@"Giusto.GIHelpAndSupportNavigationController")])
    {
        [[Helpshift sharedInstance] showFAQs:viewController withOptions:nil];
        return NO;
    }
    return YES;
}
@end
