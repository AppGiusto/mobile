//
//  GIUser+GIModelRelation.m
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIUser+GIModelRelation.h"
#import "GIUserProfile.h"
#import "GITable.h"
#import "GIUserSettings.h"
#import "GIConnectionRequest.h"

@implementation GIUser (GIModelRelation)

- (GIUserProfile*) userProfile
{
    PFObject *userProfile = self.parseUser[@"userProfile"];
    
    [userProfile fetchIfNeeded];
    
    return [GIUserProfile parseModelWithParseObject:userProfile];
}

- (void)userProfileWithBlock:(MYCompletionBlock)completetionBlock
{
    if (completetionBlock)
    {
        [self.parseUser fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
           
            PFObject *userProfile = object[@"userProfile"];
            
            [userProfile fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error)
             {
                 GIUserProfile *userProfile = [GIUserProfile parseModelWithParseObject:object];
                 completetionBlock(self, (error == nil), error, userProfile);
             }];
        }];
    }
    
}


- (void) dependentsWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        PFRelation *dependentsRelation = self.parseUser[@"dependents"];
        
        dependentsRelation.query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        
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


- (void) tablesWithCompletion:(MYCompletionBlock)completion
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        PFRelation *tablesRelation = self.parseUser[@"tables"];
        
        tablesRelation.query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        
        [tablesRelation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            NSArray *strongTables = _.arrayMap(objects,^(PFObject *parseObject){
                return [GITable parseModelWithParseObject:parseObject];
            });
            
            if (completion) {
                completion(self,YES,nil,strongTables);
            }
        }];
    }];
}


- (GIUserSettings*) userSettings
{
    PFObject *userSettings = self.parseUser[@"userSettings"];
    
    [userSettings fetchIfNeeded];
    
    return [GIUserSettings parseModelWithParseObject:userSettings];
}

- (void) connectionRequestsSentTo:(PFUser*)requestee withCompletionBlock:(MYCompletionBlock)completion
{
    PFQuery *connectionRequestQuery = [PFQuery queryWithClassName:@"ConnectionRequest"];
    [connectionRequestQuery whereKey:@"requestor" equalTo:self.parseUser];
    [connectionRequestQuery whereKey:@"requestee" equalTo:requestee];
    connectionRequestQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        NSArray *connections = [connectionRequestQuery findObjects:&error];
        
        if (completion)
        {
            completion(self,(error == nil),error,connections);
        }
    }];
}

- (void) connectionRequestsSentAndAccepted:(MYCompletionBlock)completion
{
    PFQuery *connectionRequestQuery = [PFQuery queryWithClassName:@"ConnectionRequest"];
    [connectionRequestQuery whereKey:@"requestor" equalTo:self.parseUser];
    [connectionRequestQuery whereKey:@"status" equalTo:@(GIConnectionRequestStatusAccepted)];
    
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        NSArray *connections = [connectionRequestQuery findObjects:&error];
        
        if (completion)
        {
            completion(self,(error == nil),error,connections);
        }
    }];
}
@end
