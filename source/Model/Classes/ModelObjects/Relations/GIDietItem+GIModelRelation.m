//
//  GIDietItem+GIModelRelation.m
//  Giusto
//
//  Created by Nielson Rolim on 7/20/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIDietItem+GIModelRelation.h"

@implementation GIDietItem (GIModelRelation)

- (NSArray*) foodItems
{
    PFRelation *dietFoodItemsRelation = self.parseObject[@"foodItems"];
    dietFoodItemsRelation.query.cachePolicy = kPFCachePolicyCacheOnly;
    NSArray *parseDietFoodItems = [dietFoodItemsRelation.query findObjects];
    NSArray *dietFoodItems = _.arrayMap(parseDietFoodItems,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return dietFoodItems;
}

@end
