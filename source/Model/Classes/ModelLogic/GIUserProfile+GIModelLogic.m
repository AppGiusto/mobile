//
//  GIUserProfile+GIModelLogic.m
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIUserProfile+GIModelLogic.h"

@implementation GIUserProfile (GIModelLogic)

- (void)associateUser:(GIUser *)user
{
    [self associateUser:user completion:NULL queue:nil];
}

- (void)associateUser:(GIUser *)user inBackgroundWithCompletion:(MYCompletionBlock)completion
{
    [self associateUser:user completion:completion queue:[NSOperationQueue backgroundQueue]];
}

- (void)associateUser:(GIUser*)user completion:(MYCompletionBlock)completion queue:(NSOperationQueue*)queue
{
    if (user)
    {
        if (!queue)
        {
            queue = [NSOperationQueue currentQueue];
        }
        
        self.parseObject[@"user"] = user.parseUser;
        [queue addOperationWithBlock:^{
            NSError *error = nil;
            
            if (![self.parseObject save:&error])
            {
                NSLog(@"association error: %@",[error localizedDescription]);
            }
            
            if (completion)
            {
                completion(self, (error==nil) ,error,self);
            }
        }];
    }
    else
    {
        if (completion)
        {
            completion(self,NO,nil,nil);
        }
    }
}

@end
