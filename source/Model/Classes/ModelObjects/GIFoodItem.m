//
//  GIFoodItem.m
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIFoodItem.h"

@implementation GIFoodItem

@dynamic name;
@dynamic photoURL;
@dynamic type;

+ (NSString *)parseModelClass
{
    return @"FoodItem";
}

- (NSMutableArray*) memberArray {
    if (_memberArray == nil) {
        _memberArray = [NSMutableArray new];
    }
    return _memberArray;
}

- (BOOL) isEqual:(GIFoodItem*)aFoodItem
{
    if ([aFoodItem isKindOfClass:[GIFoodItem class]])
    {
        return [self.name isEqualToString:aFoodItem.name];
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return self.objectId.hash;
}

@end
