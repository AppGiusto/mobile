//
//  GITable+GIModelRelation.m
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GITable+GIModelRelation.h"
#import "GIUserProfile.h"

@implementation GITable (GIModelRelation)

- (void) userProfilesWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        PFRelation *userProfilesRelation = self.parseObject[@"userProfiles"];
        
        userProfilesRelation.query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        [userProfilesRelation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSArray *strongUserProfiles = _.arrayMap(objects,^(PFObject *parseObject) {
                return [GIUserProfile parseModelWithParseObject:parseObject];
            });
            
            if (completion) {
                completion(self,YES,nil,strongUserProfiles);
            }
        }];
    }];
}

- (void) userProfilesIncludingFoodItemsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        PFRelation *userProfilesRelation = self.parseObject[@"userProfiles"];
        
        userProfilesRelation.query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        [userProfilesRelation.query includeKey:@"cannotHaveFoodItems"];
        [userProfilesRelation.query includeKey:@"dislikedFoodItems "];
        [userProfilesRelation.query includeKey:@"likedFoodItems "];
        
        [userProfilesRelation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSArray *strongUserProfiles = _.arrayMap(objects,^(PFObject *parseObject) {
                return [GIUserProfile parseModelWithParseObject:parseObject];
            });
            
            if (completion) {
                completion(self,YES,nil,strongUserProfiles);
            }
        }];
    }];
}

@end
