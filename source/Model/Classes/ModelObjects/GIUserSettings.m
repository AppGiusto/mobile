//
//  GIUserSettings.m
//  Pods
//
//  Created by Vincil Bishop on 8/31/14.
//
//

#import "GIUserSettings.h"

@implementation GIUserSettings

@dynamic profilePrivacy;
@dynamic dependentPrivacy;
@dynamic sentConnectionRequestNotificationsEnabled;
@dynamic connectionRequestAcceptedNotificationsEnabled;


+ (NSString *)parseModelClass
{
    return @"UserSettings";
}

@end
