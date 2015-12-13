//
//  GIUser+GIModelLogic.m
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIUser+GIModelLogic.h"
#import "GIUserStore.h"
#import "GIConnectionRequest.h"
#import "GIModel.h"

@implementation GIUser (GIModelLogic)

+ (GIUserStore*) sharedStore
{
    return [GIUserStore sharedStore];
}

- (void) sendConnectionRequestToUser:(GIUser*)receivingUser withCompletion:(MYCompletionBlock)completion
{
    if (receivingUser)
    {
        PFObject *object = [[PFObject alloc] initWithClassName:@"ConnectionRequest"];
        GIConnectionRequest *connectionRequest = [[GIConnectionRequest alloc] initWithParseObject:object];
        connectionRequest.parseObject[@"requestor"] = self.parseUser;
        connectionRequest.parseObject[@"requestee"] = receivingUser.parseUser;
        
        [[GIConnectionRequestStore sharedStore] sendConnectionRequest:connectionRequest withCompletionBlock:completion];
    }
}

@end
