/*
 *	GIUserSettingsStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"

@class GIUser;
@class GIUserSettings;
@interface GIUserSettingsStore : GIModelStoreBase

+ (GIUserSettingsStore *) sharedStore;

- (void) createUserSettingsWithUser:(GIUser *)user completion:(MYCompletionBlock)completion;
- (void) deleteUserSetting:(GIUserSettings *)userSettings completion:(MYCompletionBlock)completion;

@end