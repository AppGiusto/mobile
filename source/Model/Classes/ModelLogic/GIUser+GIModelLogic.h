//
//  GIUser+GIModelLogic.h
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIUser.h"

@class GIUserStore;

@interface GIUser (GIModelLogic)

+ (GIUserStore*) sharedStore;

- (void) sendConnectionRequestToUser:(GIUser*)receivingUser withCompletion:(MYCompletionBlock)completion;
@end
