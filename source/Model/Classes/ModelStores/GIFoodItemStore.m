/*
 *	GIFoodItemStore.m
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import "GIFoodItemStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"
#import "GIUserProfile.h"

@interface GIFoodItemStore()

@end

@implementation GIFoodItemStore

+ (GIFoodItemStore *) sharedStore
{
	static GIFoodItemStore *_sharedStore = nil;
	
	if (!_sharedStore)
	{
		_sharedStore = [[GIFoodItemStore alloc] initSingleton];
	}
	
	return _sharedStore;
}

- (id) initSingleton
{
	if ((self = [super init]))
	{
		// Initialization code here.
        self.modelObjectType = [GIFoodItem class];
	}
	
	return self;
}

- (NSArray *) getFoodItems {
    PFQuery *foodItemQuery = [PFQuery queryWithClassName:@"FoodItem"];
    foodItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [foodItemQuery orderByAscending:@"name"];
    foodItemQuery.limit = 1000;
    NSArray *parseFoodItems = [foodItemQuery findObjects];
    NSArray *foodItems = _.arrayMap(parseFoodItems, ^(PFObject *parseObject) {
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    return foodItems;
}

- (void)getFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        NSArray *foodItems = [self getFoodItems];
        if (completion) {
            completion(self,YES,nil,foodItems);
        }
    }];
}

- (void)getFoodItemsDictionaryWithCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        PFQuery *foodItemQuery = [PFQuery queryWithClassName:@"FoodItem"];
        foodItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [foodItemQuery orderByAscending:@"name"];
        foodItemQuery.limit = 1000;
        NSArray *parseFoodItems = [foodItemQuery findObjects];
        __block NSMutableDictionary* foodItems = [NSMutableDictionary new];
        Underscore.arrayEach(parseFoodItems, ^(PFObject *parseObject) {
            GIFoodItem* item = [GIFoodItem parseModelWithParseObject:parseObject];
            [foodItems setObject:item forKey:item.objectId];
        });

        if (completion) {
            completion(self,YES,nil,foodItems);
        }
    }];
}


- (void)getFoodItemsForType:(GIFoodItemType*)foodItemType withCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        PFQuery *foodItemQuery = [PFQuery queryWithClassName:@"FoodItem"];
        [foodItemQuery whereKey:@"type" containsString:[foodItemType name]];
        foodItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [foodItemQuery orderByAscending:@"name"];
        foodItemQuery.limit = 1000;
        
        NSArray *parseFoodItems = [foodItemQuery findObjects];
        NSArray *foodItems = _.arrayMap(parseFoodItems, ^(PFObject *parseObject) {
            return [GIFoodItem parseModelWithParseObject:parseObject];
        });
        
        if (completion) {
            completion(self,YES,nil,foodItems);
        }
    }];
}

- (void)getFoodItemsDictionaryForType:(GIFoodItemType*)foodItemType withCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        PFQuery *foodItemQuery = [PFQuery queryWithClassName:@"FoodItem"];
        [foodItemQuery whereKey:@"type" containsString:[foodItemType name]];
        foodItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [foodItemQuery orderByAscending:@"name"];
        foodItemQuery.limit = 1000;
        
        NSArray *parseFoodItems = [foodItemQuery findObjects];
        __block NSMutableDictionary* foodItems = [NSMutableDictionary new];
        Underscore.arrayEach(parseFoodItems, ^(PFObject *parseObject) {
            GIFoodItem* item = [GIFoodItem parseModelWithParseObject:parseObject];
            [foodItems setObject:item forKey:item.objectId];
        });
        
        if (completion) {
            completion(self,YES,nil,foodItems);
        }
    }];
}

- (void)getFoodItemsForSearchPhrase:(NSString*)phrase andType:(NSString*)type withCompletion:(MYCompletionBlock)completion
{
    
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        PFQuery *query = [PFQuery queryWithClassName:@"FoodItem"]; //1
        [query whereKey:@"name" containsString:[phrase capitalizedString]];
        if (type) {
            [query whereKey:@"type" containsString:type];
        }
        
        NSArray *parseFoodItems = [query findObjects];
        NSArray *foodItems = _.arrayMap(parseFoodItems, ^(PFObject *parseObject) {
            return [GIFoodItem parseModelWithParseObject:parseObject];
        });
    
        [query findObjectsInBackgroundWithBlock:^(NSArray *parseFoodItems, NSError *error)  {
            NSArray *foodItems = _.arrayMap(parseFoodItems, ^(PFObject *parseObject) {
                return [GIFoodItem parseModelWithParseObject:parseObject];
            });
            if (completion) {
                completion(self,YES,error,foodItems);
            }
        }];
    }];
}

- (NSError *)addFoodItems:(NSArray *)foodItems toProfile:(GIUserProfile *)profile itemCategory:(GIFoodItemCategory)category {
    NSError *error = nil;
    
    for (GIFoodItem* foodItem in foodItems) {
        switch (category) {
            case GIFoodItemCategoryLikes:
                [[profile.parseObject relationForKey:@"likedFoodItems"] addObject:foodItem.parseObject];
                break;
            case GIFoodItemCategoryDislikes:
                [[profile.parseObject relationForKey:@"dislikedFoodItems"] addObject:foodItem.parseObject];
                break;
            case GIFoodItemCategoryCannotHaves:
                [[profile.parseObject relationForKey:@"cannotHaveFoodItems"] addObject:foodItem.parseObject];
                break;
            default:
                break;
        }
    }
    
    [profile.parseObject save:&error];
    
    NSAssert(!error, @"error in associating food item with profile!");
    
    return error;
}

- (NSError *)addFoodItem:(GIFoodItem *)foodItem toProfile:(GIUserProfile *)profile itemCategory:(GIFoodItemCategory)category {
    NSError *error = nil;
    
    switch (category) {
        case GIFoodItemCategoryLikes:
            [[profile.parseObject relationForKey:@"likedFoodItems"] addObject:foodItem.parseObject];
            break;
        case GIFoodItemCategoryDislikes:
            [[profile.parseObject relationForKey:@"dislikedFoodItems"] addObject:foodItem.parseObject];
            break;
        case GIFoodItemCategoryCannotHaves:
            [[profile.parseObject relationForKey:@"cannotHaveFoodItems"] addObject:foodItem.parseObject];
            break;
        default:
            break;
    }
    
    [profile.parseObject save:&error];
    
    NSAssert(!error, @"error in associating food item with profile!");
    
    return error;
}

- (void)addFoodItem:(GIFoodItem *)foodItem toProfile:(GIUserProfile *)profile itemCategory:(GIFoodItemCategory)category completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = [self addFoodItem:foodItem toProfile:profile itemCategory:category];
        
        if (completion) {
            completion(self, error == nil, error, foodItem);
        }
        
    }];
}

- (NSError *)removeFoodItems:(NSArray *)foodItems FromProfile:(GIUserProfile *)profile category:(GIFoodItemCategory)category {
    NSError *error = nil;
    
    for (GIFoodItem* foodItem in foodItems) {
        switch (category) {
            case GIFoodItemCategoryLikes:
                [[profile.parseObject relationForKey:@"likedFoodItems"] removeObject:foodItem.parseObject];
                break;
            case GIFoodItemCategoryDislikes:
                [[profile.parseObject relationForKey:@"dislikedFoodItems"] removeObject:foodItem.parseObject];
                break;
            case GIFoodItemCategoryCannotHaves:
                [[profile.parseObject relationForKey:@"cannotHaveFoodItems"] removeObject:foodItem.parseObject];
                break;
            default:
                break;
        }
    }
    
    [profile.parseObject save:&error];
    
    NSAssert(!error, @"error in removing association between food item and profile!");
    
    return error;
}


- (NSError *)removeFoodItem:(GIFoodItem *)foodItem FromProfile:(GIUserProfile *)profile category:(GIFoodItemCategory)category {
    NSError *error = nil;
    
    switch (category) {
        case GIFoodItemCategoryLikes:
            [[profile.parseObject relationForKey:@"likedFoodItems"] removeObject:foodItem.parseObject];
            break;
        case GIFoodItemCategoryDislikes:
            [[profile.parseObject relationForKey:@"dislikedFoodItems"] removeObject:foodItem.parseObject];
            break;
        case GIFoodItemCategoryCannotHaves:
            [[profile.parseObject relationForKey:@"cannotHaveFoodItems"] removeObject:foodItem.parseObject];
            break;
        default:
            break;
    }
    
    [profile.parseObject save:&error];
    
    NSAssert(!error, @"error in removing association between food item and profile!");
    
    return error;
}

- (void)removeFoodItem:(GIFoodItem *)foodItem FromProfile:(GIUserProfile *)profile category:(GIFoodItemCategory)category completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = [self removeFoodItem:foodItem FromProfile:profile category:category];
        
        if (completion) {
            completion(self, error == nil, error, foodItem);
        }
    }];
}

- (void)getFoodItemsForQuizForType:(GIFoodItemType*)foodItemType withCompletion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        PFQuery *foodItemQuery = [PFQuery queryWithClassName:@"FoodItem"];
        [foodItemQuery whereKey:@"type" containsString:[foodItemType name]];
        foodItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [foodItemQuery orderByAscending:@"name"];
        foodItemQuery.limit = 520;
        
        NSArray *parseFoodItems = [foodItemQuery findObjects];
        NSArray *foodItems = Underscore.arrayMap(parseFoodItems, ^(PFObject *parseObject) {
            return [GIFoodItem parseModelWithParseObject:parseObject];
        });
        
        if (completion) {
            completion(self,YES,nil,foodItems);
        }
    }];
}

@end
