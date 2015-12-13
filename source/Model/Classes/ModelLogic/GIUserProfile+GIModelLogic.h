//
//  GIUserProfile+GIModelLogic.h
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIUserProfile.h"
#import "GIModel.h"

@interface GIUserProfile (GIModelLogic)
- (void)associateUser:(GIUser *)user;
- (void)associateUser:(GIUser *)user inBackgroundWithCompletion:(MYCompletionBlock)completion;
- (void)associateUser:(GIUser*)user completion:(MYCompletionBlock)completion queue:(NSOperationQueue*)queue;
@end
