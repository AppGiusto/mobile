/*
 *	GIFoodItemTypeStore.m
 *	Pods
 *
 *	Created by Vincil Bishop on 9/3/14.
 *
 */

#import "GIFoodItemTypeStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"

@interface GIFoodItemTypeStore()

@end

@implementation GIFoodItemTypeStore

+ (GIFoodItemTypeStore *) sharedStore
{
    static GIFoodItemTypeStore *_sharedStore = nil;
    
    if (!_sharedStore)
    {
        _sharedStore = [[GIFoodItemTypeStore alloc] initSingleton];
    }
    
    return _sharedStore;
}

- (id) initSingleton
{
    if ((self = [super init]))
    {
        // Initialization code here.
        self.modelObjectType = [GIFoodItemType class];
    }
    
    return self;
}

- (void)getFoodItemsTypesWithCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        PFQuery *foodItemTypeQuery = [PFQuery queryWithClassName:@"FoodItemType"];
        foodItemTypeQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        NSArray *parseFoodItemTypes = [foodItemTypeQuery findObjects];
        NSArray *foodItemsTypes = _.arrayMap(parseFoodItemTypes, ^(PFObject *parseObject) {
            return [GIFoodItemType parseModelWithParseObject:parseObject];
        });
        
        if (completion) {
            completion(self,YES,nil,foodItemsTypes);
        }
    }];
}

- (void)getFoodItemForName:(NSString*)name withCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        PFQuery *foodItemTypeQuery = [PFQuery queryWithClassName:@"FoodItemType"];
        [foodItemTypeQuery whereKey:@"name" containsString:name];
        foodItemTypeQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        NSArray *parseFoodItemTypes = [foodItemTypeQuery findObjects];
        NSArray *foodItemsTypes = _.arrayMap(parseFoodItemTypes, ^(PFObject *parseObject) {
            return [GIFoodItemType parseModelWithParseObject:parseObject];
        });
        
        if (completion) {
            completion(self,YES,nil,foodItemsTypes);
        }
    }];
}

@end
