/*
 *	GITableStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"

@class GIUser;
@class GITable;
@class GIUserProfile;

@interface GITableStore : GIModelStoreBase

+ (GITableStore *) sharedStore;

- (void) createTableForUser:(GIUser *)user name:(NSString *)name withUserProfiles:(NSArray *)userProfiles completion:(MYCompletionBlock)completion;
- (void) saveTable:(GITable *)table name:(NSString *)name withAddedProfiles:(NSArray *)addedProfiles andRemovedProfiles:(NSArray *)removedProfiles completion:(MYCompletionBlock)completion;
- (void) deleteTable:(GITable *)table completion:(MYCompletionBlock)completion;

@end