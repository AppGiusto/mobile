/*
 *	GIConnectionRequestStore.m
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import "GIConnectionRequestStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"
#import "PFObject+GISimpleEquality.h"

@interface GIConnectionRequestStore()

@end

@implementation GIConnectionRequestStore

+ (GIConnectionRequestStore *) sharedStore
{
	static GIConnectionRequestStore *_sharedStore = nil;
	
	if (!_sharedStore)
	{
		_sharedStore = [[GIConnectionRequestStore alloc] initSingleton];
	}
	
	return _sharedStore;
}

- (id) initSingleton
{
	if ((self = [super init]))
	{
		// Initialization code here.
        self.modelObjectType = [GIConnectionRequest class];
	}
	
	return self;
}

- (void) processConnectionRequest:(GIConnectionRequest*)connectionRequest withStatus:(GIConnectionRequestStatus)status andCompletionBlock:(MYCompletionBlock)completionBlock
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        if (status == GIConnectionRequestStatusRejected)
        {
            [connectionRequest.parseObject delete:&error];
        }
        else
        {
            connectionRequest.status = @(status);
            
            [connectionRequest.parseObject save:&error];
        }
        if (completionBlock)
        {
            completionBlock(self,(error == nil),error,connectionRequest);
        }
    }];
}

- (void) sendConnectionRequest:(GIConnectionRequest*)connectionRequest withCompletionBlock:(MYCompletionBlock)completionBlock
{
    [self processConnectionRequest:connectionRequest withStatus:GIConnectionRequestStatusPending andCompletionBlock:completionBlock];
}

- (void) rejectConnectionRequest:(GIConnectionRequest*)connectionRequest withCompletionBlock:(MYCompletionBlock)completionBlock
{
    [self processConnectionRequest:connectionRequest withStatus:GIConnectionRequestStatusRejected andCompletionBlock:completionBlock];
}

- (void) connectionRequestsWithCompletetionBlock:(MYCompletionBlock)completionBlock
{
    PFQuery *connectionRequestQuery = [PFQuery queryWithClassName:@"ConnectionRequest"];
    [self updateModelObjectsWithQuery:connectionRequestQuery completion:completionBlock];
}

- (void) acceptConnectionRequest:(GIConnectionRequest*)connectionRequest withCompletionBlock:(MYCompletionBlock)completionBlock
{
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        PFUser *currentUser = [GIUserStore sharedStore].currentUser.parseUser;
        PFRelation *connectionsRelation = [currentUser relationForKey:@"connections"];
        PFQuery *connectionsQuery = [connectionsRelation query];
        [connectionsQuery whereKey:@"objectId" equalTo:connectionRequest.requestor.objectId];
        connectionsQuery.cachePolicy = kPFCachePolicyNetworkOnly;
        
        NSError *error = nil;
        NSArray *possibleConnections = [connectionsQuery findObjects:&error];
        
        if (possibleConnections == nil || possibleConnections.count == 0)
        {
            error = nil;
            connectionRequest.status = @(GIConnectionRequestStatusAccepted);
            [connectionsRelation addObject:connectionRequest.requestor];
            
            if ([currentUser save:&error])
            {
                error = nil;
                [connectionRequest.parseObject save:&error];
                [[NSNotificationCenter defaultCenter] postNotificationName:kGIConnectionRequestStoreDidAcceptConnectionRequest object:self userInfo:@{}];
            }
        }
        else
        {
            connectionRequest.status = @(GIConnectionRequestStatusAccepted);
            [connectionRequest.parseObject save:&error];
        }
        
        if (completionBlock)
        {
            completionBlock(self,(error == nil),error,connectionRequest);
        }
    }];
}	

- (void) pendingConnectionRequestsReceivedWithCompletionBlock:(MYCompletionBlock)completionBlock
{
    PFQuery *connectionRequestQuery = [PFQuery queryWithClassName:@"ConnectionRequest"];
    [connectionRequestQuery whereKey:@"status" equalTo:@(GIConnectionRequestStatusPending)];
    [connectionRequestQuery whereKey:@"requestee" equalTo:[GIUserStore sharedStore].currentUser.parseUser];
    connectionRequestQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        NSArray *connections = [connectionRequestQuery findObjects:&error];
        
        if (completionBlock)
        {
            completionBlock(self,(error == nil),error,connections);
        }
    }];
}

- (void) evaluateAndFinalizeSentConnectionRequestsWithCompletionBlock:(MYCompletionBlock)completionBlock
{
    if (completionBlock != NULL)
    {
        [[GIUserStore sharedStore].currentUser connectionRequestsSentAndAccepted:^(id sender, BOOL success, NSError *error, NSArray *fulfilledConnectionRequests) {
            NSMutableArray *fulfilledConnections = [@[] mutableCopy];
            if (fulfilledConnectionRequests != nil && fulfilledConnectionRequests.count > 0)
            {
                PFUser *currentUser = [GIUserStore sharedStore].currentUser.parseUser;
                PFRelation *connectionsRelation = [currentUser relationForKey:@"connections"];
                PFQuery *connectionsQuery = [connectionsRelation query];
                connectionsQuery.cachePolicy = kPFCachePolicyNetworkOnly;
                
                NSError *error = nil;
                NSArray *existingConnections = [connectionsQuery findObjects:&error];
                
                [fulfilledConnectionRequests enumerateObjectsUsingBlock:^(PFObject *aConnectionRequest, NSUInteger idx, BOOL *stop) {
                    PFUser *aFulfilledConnection = aConnectionRequest[@"requestee"];
                    NSString *objectId = aFulfilledConnection.objectId;
                    
                    if (![existingConnections containsObject:aFulfilledConnection])
                    {
                        [connectionsRelation addObject:aFulfilledConnection];
                        [fulfilledConnections addObject:aFulfilledConnection];
                    }
                }];
                
                if ([fulfilledConnections count] > 0)
                {
                    [currentUser save];
                }
                
                // delete all the fulfilled connection requests
                //[fulfilledConnectionRequests makeObjectsPerformSelector:@selector(delete)];
                [fulfilledConnectionRequests enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
                    NSError *error = nil;
                    [obj delete:&error];
                    NSLog(@"error %@:",error);
                }];
            }
            
            completionBlock(self, error == nil, error, fulfilledConnections);
        }];
    }
}
@end
