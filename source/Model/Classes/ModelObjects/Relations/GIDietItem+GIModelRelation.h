//
//  GIDietItem+GIModelRelation.h
//  Giusto
//
//  Created by Nielson Rolim on 7/20/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIDietItem.h"

@class GIFoodItem;

@interface GIDietItem (GIModelRelation)

/**
 *  FoodItems
 *
 *  @return Associated Food Items.
 */
- (NSArray*) foodItems;

@end
