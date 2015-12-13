/*
 *	GIUserStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"

@class GIUser;

@interface GIUserStore : GIModelStoreBase

@property (nonatomic,strong) GIUser *currentUser;

+ (GIUserStore *) sharedStore;

- (BOOL) authenticated;

- (NSString*) defaultUsername;

- (void) setDefaultUsername:(NSString*)defaultUsername;

- (NSString*) defaultPassword;

- (void) setDefaultPassword:(NSString*)defaultPassword;

- (BOOL) hasDefaultCredentials;

- (void) clearDefaultCredentials;

- (void) deleteUserWithCompletion:(MYCompletionBlock)completion;

- (void) signUpWithFullName:(NSString*)fullName email:(NSString*)email location:(NSString*)location password:(NSString*)password photo:(UIImage *)photo completion:(MYCompletionBlock)completion;

- (GIUser*) loginWithUsername:(NSString*)username password:(NSString*)password error:(NSError **)error;

- (void) loginInBackgroundWithUsername:(NSString*)username password:(NSString*)password completion:(MYCompletionBlock)completion;

- (void) loginInBackgroundWithFacebookAndCompletion:(MYCompletionBlock)completion;

- (BOOL) loginWithDefaultCredentialsAndError:(NSError **)error;

- (void) logout;

- (void) resetPasswordForEmail:(NSString *)emailAddress;

- (void) changePasswordFrom:(NSString *)currentPassword to:(NSString *)changedPassword completion:(MYCompletionBlock)completion;

- (void) findUsersWithProfile:(id)userProfile completion:(MYCompletionBlock)completion;

- (void) findConnectionsWithFullNamesArray:(NSArray*)fullNames completion:(MYCompletionBlock)completion;
- (void) findConnectionsWithFullName:(NSString*)fullName completion:(MYCompletionBlock)completion;

- (void)findConnectionsWithEmailsArray:(NSArray *)emails completion:(MYCompletionBlock)completion;
- (void) findConnectionsWithEmail:(NSString *)email completion:(MYCompletionBlock)completion;

- (void) connectionsWithCompletionBlock:(MYCompletionBlock)completionBlock;
- (void) removeConnection:(GIUser*)connection withCompletionBlock:(MYCompletionBlock)completionBlock;

- (NSArray*) findConnectionsWithFullName:(NSString*)fullName;

- (void)findConnectionsByEmail:(NSString *)email completion:(MYCompletionBlock)completion;

@end