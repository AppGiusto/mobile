//
//  GIUserProfile.m
//  Pods
//
//  Created by Vincil Bishop on 8/31/14.
//
//

#import "GIUserProfile.h"

@implementation GIUserProfile

@dynamic fullName;
@dynamic location;
@dynamic photoURL;
@dynamic birthDate;

@dynamic cannotHaveFoodItems;
@dynamic dislikedFoodItems;
@dynamic likedFoodItems;

@synthesize masterIndex;

+ (NSString *)parseModelClass
{
    return @"UserProfile";
}

@end
