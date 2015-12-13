/*
 *	GIUserProfileStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"

@class GIUser;
@class GIUserProfile;

@interface GIUserProfileStore : GIModelStoreBase

+ (GIUserProfileStore *) sharedStore;

- (BOOL) createUserProfileWithUser:(GIUser*)user fullName:(NSString*)fullName location:(NSString*)location photo:(UIImage *)photo;
- (void) createUserProfileWithUser:(GIUser*)user fullName:(NSString*)fullName location:(NSString*)location photo:(UIImage *)photo completion:(MYCompletionBlock)completion;
- (void) saveUserProfile:(GIUserProfile *)userProfile fullName:(NSString *)fullName location:(NSString *)location photo:(UIImage *)photo birthday:(NSDate *)birthday completion:(MYCompletionBlock)completion;
- (void) saveUserProfileWithEmail:(GIUserProfile *)userProfile fullName:(NSString *)fullName email:(NSString*)email location:(NSString *)location photo:(UIImage *)photo birthday:(NSDate *)birthday completion:(MYCompletionBlock)completion;
- (void) deleteUserProfile:(GIUserProfile *)userProfile completion:(MYCompletionBlock)completion;

// Dependents convenience meothds
- (void) createDependentForUser:(GIUser *)user name:(NSString *)name birthday:(NSDate *)birthday photo:(UIImage *)photo completion:(MYCompletionBlock)completion;
- (void) saveDependent:(GIUserProfile *)dependent name:(NSString *)name birthday:(NSDate *)birthday photo:(UIImage *)photo completion:(MYCompletionBlock)completion;
- (void) deleteDependent:(GIUserProfile *)dependent completion:(MYCompletionBlock)completion;

@end