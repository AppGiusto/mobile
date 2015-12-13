//
//  GIUserProfile+GIModelRelation.m
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIUserProfile+GIModelRelation.h"
#import "GIFoodItem.h"
#import "GIUser.h"

@implementation GIUserProfile (GIModelRelation)

- (NSArray*) cannotHaveFoodItemsWithLimit:(int)limit
{
    PFRelation *cannotHavesRelation = self.parseObject[@"cannotHaveFoodItems"];

    PFQuery *cannotHavesQuery = [cannotHavesRelation query];
    cannotHavesQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    cannotHavesQuery.limit = limit;

    NSArray *parseCannotHaves = [cannotHavesQuery findObjects];
    NSArray *strongCannotHaves = _.arrayMap(parseCannotHaves,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongCannotHaves;
}

- (NSArray*) cannotHaveFoodItemsWithLimit:(int)limit andType:(NSString*)type
{
    PFRelation *cannotHavesRelation = self.parseObject[@"cannotHaveFoodItems"];
    
    PFQuery *cannotHavesQuery = [cannotHavesRelation query];
    if (type != nil) {
        [cannotHavesQuery whereKey:@"type" containsString:type];
    }
    cannotHavesQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    cannotHavesQuery.limit = limit;
    
    NSArray *parseCannotHaves = [cannotHavesQuery findObjects];
    NSArray *strongCannotHaves = _.arrayMap(parseCannotHaves,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongCannotHaves;
}

- (NSArray*) cannotHaveFoodItems {
    return [self cannotHaveFoodItemsWithLimit:1000];
}

- (NSArray*) likedFoodItemsWithLimit:(int)limit
{
    PFRelation *likedRelation = self.parseObject[@"likedFoodItems"];
    
    PFQuery *likedQuery = [likedRelation query];
    likedQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    likedQuery.limit = limit;
    
    NSArray *parseLiked = [likedQuery findObjects];
    NSArray *strongLiked = _.arrayMap(parseLiked,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongLiked;
}

- (NSArray*) likedFoodItemsWithLimit:(int)limit andType:(NSString*)type
{
    PFRelation *likedRelation = self.parseObject[@"likedFoodItems"];
    
    PFQuery *likedQuery = [likedRelation query];
    if (type != nil) {
        [likedQuery whereKey:@"type" containsString:type];
    }
    likedQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    likedQuery.limit = limit;
    
    NSArray *parseLiked = [likedQuery findObjects];
    NSArray *strongLiked = _.arrayMap(parseLiked,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongLiked;
}

- (NSArray*) likedFoodItems {
    return [self likedFoodItemsWithLimit:1000];
}

- (NSArray*) dislikedFoodItemsWithLimit:(int)limit
{
    PFRelation *dislikedRelation = self.parseObject[@"dislikedFoodItems"];

    PFQuery *dislikedQuery = [dislikedRelation query];
    dislikedQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    dislikedQuery.limit = limit;
    
    NSArray *parseDisliked = [dislikedQuery findObjects];
    NSArray *strongDisliked = _.arrayMap(parseDisliked,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongDisliked;
}

- (NSArray*) dislikedFoodItemsWithLimit:(int)limit andType:(NSString*)type
{
    PFRelation *dislikedRelation = self.parseObject[@"dislikedFoodItems"];
    
    PFQuery *dislikedQuery = [dislikedRelation query];
    if (type != nil) {
        [dislikedQuery whereKey:@"type" containsString:type];
    }
    dislikedQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    dislikedQuery.limit = limit;
    
    NSArray *parseDisliked = [dislikedQuery findObjects];
    NSArray *strongDisliked = _.arrayMap(parseDisliked,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongDisliked;
}

- (NSArray*) dislikedFoodItems {
    return [self dislikedFoodItemsWithLimit:1000];
}

- (NSDictionary*) dietItems
{
    PFRelation *dietRelation = self.parseObject[@"dietItems"];
    dietRelation.query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    NSArray *parseDietItems = [dietRelation.query findObjects];
    __block NSMutableDictionary *dietItems = [NSMutableDictionary new];
    Underscore.arrayEach(parseDietItems,^(PFObject *parseObject) {
        GIDietItem* item = [GIDietItem parseModelWithParseObject:parseObject];
        [dietItems setObject:item forKey:item.objectId];
    });
    
    return [dietItems copy];
}

- (void) cannotHaveFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSArray *strongCannotHaves = [self cannotHaveFoodItems];
        
        if (completion) {
            completion(self,YES,nil,strongCannotHaves);
        }
    }];
}

- (void) likedFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSArray *strongLiked = [self likedFoodItems];
        
        if (completion) {
            completion(self,YES,nil,strongLiked);
        }
    }];
}

- (void) dislikedFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSArray *strongDisliked = [self dislikedFoodItems];
        
        if (completion) {
            completion(self,YES,nil,strongDisliked);
        }
    }];
}

- (void) dietItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSDictionary *dietItems = [self dietItems];
        
        if (completion) {
            completion(self,YES,nil,dietItems);
        }
    }];
}

- (void) dependentsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        PFQuery *userQuery = [PFUser query];
        userQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
        [userQuery whereKey:@"userProfile" equalTo:self.parseObject];
        
        PFUser *user = (PFUser *)[userQuery getFirstObject];
        [user fetchIfNeeded];
        
        PFRelation *dependentsRelation = user[@"dependents"];
        
        dependentsRelation.query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        [dependentsRelation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSArray *strongDependents = _.arrayMap(objects,^(PFObject *parseObject){
                
                return [GIUserProfile parseModelWithParseObject:parseObject];
                
            });
            
            if (completion) {
                completion(self,YES,nil,strongDependents);
            }
        }];
    }];
    
}

- (void) userWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        PFUser *user = self.parseObject[@"user"];
        [user fetchIfNeeded];
        GIUser *strongUser = [GIUser parseModelUserWithParseUser:user];
        
        if (completion) {
            completion(self,YES,nil,strongUser);
        }
    }];
}


- (NSUInteger) countLikedFoodItems
{
    PFRelation *likedRelation = self.parseObject[@"likedFoodItems"];
    NSUInteger countLiked = [likedRelation.query countObjects];
    return countLiked;
}

- (void) countLikedFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSNumber* countLiked = [NSNumber numberWithInteger:[self countLikedFoodItems]];
        
        if (completion) {
            completion(self,YES,nil,countLiked);
        }
    }];
}


- (NSUInteger) countDislikedFoodItems
{
    PFRelation *likedRelation = self.parseObject[@"dislikedFoodItems"];
    NSUInteger countLiked = [likedRelation.query countObjects];
    return countLiked;
}

- (void) countDislikedFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSNumber* countLiked = [NSNumber numberWithInteger:[self countDislikedFoodItems]];
        
        if (completion) {
            completion(self,YES,nil,countLiked);
        }
    }];
}


- (NSUInteger) countCannotHaveFoodItems
{
    PFRelation *likedRelation = self.parseObject[@"cannotHaveFoodItems"];
    NSUInteger countLiked = [likedRelation.query countObjects];
    return countLiked;
}

- (void) countCannotHaveFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSNumber* countLiked = [NSNumber numberWithInteger:[self countCannotHaveFoodItems]];
        
        if (completion) {
            completion(self,YES,nil,countLiked);
        }
    }];
}


- (NSArray*) likedIngredients
{
    PFRelation *likedRelation = self.parseObject[@"likedFoodItems"];
    
    PFQuery *likedQuery = [likedRelation query];
    [likedQuery whereKey:@"type" containsString:@"Ingredients"];
    likedQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    likedQuery.limit = 1000;
    
    NSArray *parseLiked = [likedQuery findObjects];
    NSLog(@"parseLiked: %d", (int) parseLiked.count);
    NSArray *strongLiked = _.arrayMap(parseLiked,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    return strongLiked;
}

- (NSArray*) cannotHaveIngredients
{
    PFRelation *cannotHavesRelation = self.parseObject[@"cannotHaveFoodItems"];
    
    PFQuery *cannotHavesQuery = [cannotHavesRelation query];
    [cannotHavesQuery whereKey:@"type" containsString:@"Ingredients"];
    cannotHavesQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    cannotHavesQuery.limit = 1000;
    
    NSArray *parseCannotHaves = [cannotHavesQuery findObjects];
    NSArray *strongCannotHaves = _.arrayMap(parseCannotHaves,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongCannotHaves;
}

- (NSArray*) dislikedIngredients
{
    PFRelation *dislikedRelation = self.parseObject[@"dislikedFoodItems"];
    
    PFQuery *dislikedQuery = [dislikedRelation query];
    [dislikedQuery whereKey:@"type" containsString:@"Ingredients"];
    dislikedQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    dislikedRelation.query.limit = 1000;
    
    NSArray *parseDisliked = [dislikedQuery findObjects];
    
    NSArray *strongDisliked = _.arrayMap(parseDisliked,^(PFObject *parseObject){
        return [GIFoodItem parseModelWithParseObject:parseObject];
    });
    
    return strongDisliked;
}

@end
