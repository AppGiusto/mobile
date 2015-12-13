//
//  GINewFoodItemViewController.h
//  Giusto
//
//  Created by John Gabelmann on 9/24/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserProfileViewControllerBase.h"
#import "GIUserProfileViewController.h"

@interface GINewFoodItemViewController : GIUserProfileViewControllerBase

@property (nonatomic, strong) GIFoodItemType *foodItemType;
@property (nonatomic, assign) GIFoodItemCategory foodItemCategory;
@property (nonatomic, weak) id <GIUserProfileViewControllerDelegate> delegate;
@end
