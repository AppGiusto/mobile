//
//  GIFoodItem+GIModelRelation.h
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIFoodItem.h"

@class GIFoodItemType;

@interface GIFoodItem (GIModelRelation)

/**
 *  FoodItemType
 *
 *  @return The associated FoodItemType.
 */
- (GIFoodItemType*) foodItemType;

@end
