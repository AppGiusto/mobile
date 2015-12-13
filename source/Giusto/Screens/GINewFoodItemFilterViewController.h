//
//  GINewFoodItemFilterViewController.h
//  Giusto
//
//  Created by Mark Dubouzet on 10/16/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIUserProfileViewControllerBase.h"
#import "GIUserProfileViewController.h"

@interface GINewFoodItemFilterViewController : GIUserProfileViewControllerBase

@property (nonatomic, assign) GIFoodItemCategory foodItemCategory;
@property (nonatomic, weak) id <GIUserProfileViewControllerDelegate> delegate;


@end
