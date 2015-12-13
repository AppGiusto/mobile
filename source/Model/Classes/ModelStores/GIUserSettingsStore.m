/*
 *	GIUserSettingsStore.m
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import "GIUserSettingsStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"

@interface GIUserSettingsStore()

@end

@implementation GIUserSettingsStore

+ (GIUserSettingsStore *) sharedStore
{
	static GIUserSettingsStore *_sharedStore = nil;
	
	if (!_sharedStore)
	{
		_sharedStore = [[GIUserSettingsStore alloc] initSingleton];
	}
	
	return _sharedStore;
}

- (id) initSingleton
{
	if ((self = [super init]))
	{
		// Initialization code here.
        self.modelObjectType = [GIUserSettings class];
        
        // refresh on login
	}
	
	return self;
}


#pragma mark - Store Verbds -

- (void) createUserSettingsWithUser:(GIUser *)user completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        GIUserSettings *userSettings = [GIUserSettings parseModel];
        userSettings.profilePrivacy = [NSNumber numberWithUnsignedInteger:GIUserPrivacySettingEveryone];
        userSettings.dependentPrivacy = [NSNumber numberWithUnsignedInteger:GIUserPrivacySettingEveryone];
        userSettings.sentConnectionRequestNotificationsEnabled = YES;
        userSettings.connectionRequestAcceptedNotificationsEnabled = YES;
        
        NSError *error = nil;
        
        [userSettings.parseObject save:&error];
        
        NSAssert(!error,@"error in user settings creation!");
        
        [GIUserStore sharedStore].currentUser.parseUser[@"userSettings"] = userSettings.parseObject;
        
        NSAssert([GIUserStore sharedStore].currentUser,@"must have a current user...");
        
        [[GIUserStore sharedStore].currentUser.parseUser save:&error];
        
        NSAssert(!error,@"error in associating user settings with user!");
        
        if (completion) {
            completion(self, error == nil, error, userSettings);
        }
    }];
}

- (void) deleteUserSetting:(GIUserSettings *)userSettings completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        [userSettings.parseObject deleteInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                if (completion) {
                    completion(self, error == nil, error, nil);
                }
            }else{
                NSAssert(!error,@"error deleting profile!");
                if (completion) {
                    completion(self, error == nil, error, nil);
                }
            }
        }];
        
        
        
        
    }];
}

@end
