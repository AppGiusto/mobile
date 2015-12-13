//
//  GIUser+GIModelRelation.h
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIUser.h"

@class GIUserProfile;
@class GIUserSettings;

@interface GIUser (GIModelRelation)

/**
 *  UserProfile
 *
 *  @return The user's UserProfile.
 */
- (GIUserProfile*) userProfile;

/**
 *  userProfileWithBlock
 *
 *  @return Fetches the user profile remotely if needed asynchronously to avoid blocking the calling thread.
 */
- (void)userProfileWithBlock:(MYCompletionBlock)completetionBlock;

/**
 *  Dependents
 *
 *  @param completion A block that returns the dependents for a user.
 */
- (void) dependentsWithCompletion:(MYCompletionBlock)completion;

- (void) tablesWithCompletion:(MYCompletionBlock)completion;

- (GIUserSettings*) userSettings;

- (void) connectionRequestsSentTo:(PFUser*)requestee withCompletionBlock:(MYCompletionBlock)completion;
- (void) connectionRequestsSentAndAccepted:(MYCompletionBlock)completion;

@end
