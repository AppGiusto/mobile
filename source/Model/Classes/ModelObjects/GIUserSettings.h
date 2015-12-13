//
//  GIUserSettings.h
//  Pods
//
//  Created by Vincil Bishop on 8/31/14.
//
//

#import "GIModelObjectBase.h"

typedef NS_ENUM(NSUInteger, GIUserPrivacySetting) {
    GIUserPrivacySettingEveryone,
    GIUserPrivacySettingFriends,
    GIUserPrivacySettingEmailOnly,
};

@interface GIUserSettings : GIModelObjectBase

@property (nonatomic, strong) NSNumber *profilePrivacy;
@property (nonatomic, strong) NSNumber *dependentPrivacy;

@property (nonatomic, assign) BOOL sentConnectionRequestNotificationsEnabled;
@property (nonatomic, assign) BOOL connectionRequestAcceptedNotificationsEnabled;

// userId

@end
