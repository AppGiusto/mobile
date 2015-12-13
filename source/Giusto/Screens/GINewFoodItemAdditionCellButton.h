//
//  GINewFoodItemAdditionCellButton.h
//  Giusto
//
//  Created by Mark Dubouzet on 10/23/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GINewFoodItemAdditionCellButton : UIControl

@property(nonatomic,strong) GIFoodItem * foodItem;
@property(nonatomic,strong) UIImageView * btnImageView;
@property(nonatomic, assign) BOOL deletionMode;
@property(nonatomic, assign) GIFoodItemCategory category;

@end
