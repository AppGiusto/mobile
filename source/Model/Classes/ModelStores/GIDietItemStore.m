//
//  GIDietItemStore.m
//  Giusto
//
//  Created by Nielson Rolim on 7/25/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIDietItemStore.h"
#import "GIModelLogic.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"


@implementation GIDietItemStore

+ (GIDietItemStore *) sharedStore
{
    static GIDietItemStore *_sharedStore = nil;
    
    if (!_sharedStore)
    {
        _sharedStore = [[GIDietItemStore alloc] initSingleton];
    }
    
    return _sharedStore;
}

- (id) initSingleton
{
    if ((self = [super init]))
    {
        // Initialization code here.
        self.modelObjectType = [GIDietItem class];
    }
    
    return self;
}

- (NSArray *) getDietItems {
    PFQuery *dietItemQuery = [PFQuery queryWithClassName:[GIDietItem parseModelClass]];
    dietItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [dietItemQuery orderByAscending:@"name"];
    
    NSArray *parseDietItems = [dietItemQuery findObjects];
    NSArray *dietItems = _.arrayMap(parseDietItems, ^(PFObject *parseObject) {
        return [GIDietItem parseModelWithParseObject:parseObject];
    });
    return dietItems;
}

- (void) getDietItemsWithCompletion:(MYCompletionBlock)completion {
    
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{

        NSArray *dietItems = [self getDietItems];

        //(^MYCompletionBlock)(id sender, BOOL success, NSError *error, id result);
        if (completion) {
            completion(self,YES,nil,dietItems);
        }
    }];
}

- (void) getDietItemForName:(NSString*)name withCompletion:(MYCompletionBlock)completion {
    
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        PFQuery *dietItemQuery = [PFQuery queryWithClassName:[GIDietItem parseModelClass]];
        [dietItemQuery whereKey:@"name" containsString:name];
        dietItemQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        NSArray *parseDietItems = [dietItemQuery findObjects];
        NSArray *dietItems = _.arrayMap(parseDietItems, ^(PFObject *parseObject) {
            return [GIFoodItemType parseModelWithParseObject:parseObject];
        });
        
        if (completion) {
            completion(self,YES,nil,dietItems);
        }
    }];
}

- (NSError*) addDietItems:(NSArray *)dietItems toProfile:(GIUserProfile *)profile {
    NSError *error = nil;
    for (GIDietItem* dietItem in dietItems) {
        [[profile.parseObject relationForKey:@"dietItems"] addObject:dietItem.parseObject];
    }
    [profile.parseObject save:&error];
    NSAssert(!error, @"error in associating food item with profile!");
    return error;
}

- (NSError*) addDietItem:(GIDietItem *)dietItem toProfile:(GIUserProfile *)profile {
    NSError *error = nil;
    [[profile.parseObject relationForKey:@"dietItems"] addObject:dietItem.parseObject];
    [profile.parseObject save:&error];
    NSAssert(!error, @"error in associating food item with profile!");
    return error;
}

- (void) addDietItem:(GIDietItem *)dietItem toProfile:(GIUserProfile *)profile completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = [self addDietItem:dietItem toProfile:profile];

        if (completion) {
            completion(self, error == nil, error, dietItem);
        }
    }];
}

- (NSError*)removeDietItems:(NSArray *)dietItems FromProfile:(GIUserProfile *)profile {
    NSError *error = nil;
    for (GIDietItem* dietItem in dietItems) {
        [[profile.parseObject relationForKey:@"dietItems"] removeObject:dietItem.parseObject];
    }
    [profile.parseObject save:&error];
    NSAssert(!error, @"error in removing association between food item and profile!");
    return error;
}

- (NSError*)removeDietItem:(GIDietItem *)dietItem FromProfile:(GIUserProfile *)profile {
    NSError *error = nil;
    [[profile.parseObject relationForKey:@"dietItems"] removeObject:dietItem.parseObject];
    [profile.parseObject save:&error];
    NSAssert(!error, @"error in removing association between food item and profile!");
    return error;
}

- (void)removeDietItem:(GIDietItem *)dietItem FromProfile:(GIUserProfile *)profile completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        NSError *error = [self removeDietItem:dietItem FromProfile:profile];
        if (completion) {
            completion(self, error == nil, error, dietItem);
        }
    }];
}


- (void)addFoodItem:(GIFoodItem *)foodItem toDiet:(GIDietItem *)diet completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        [[diet.parseObject relationForKey:@"foodItems"] addObject:foodItem.parseObject];
        [diet.parseObject save:&error];
        NSAssert(!error, @"error in associating food item with profile!");
        
        if (completion) {
            completion(self, error == nil, error, foodItem);
        }
    }];
}

@end
