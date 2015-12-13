//
//  GIUser.m
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIUser.h"

@implementation GIUser
@dynamic username;
@dynamic email;
@dynamic password;
@dynamic objectId;
@dynamic facebookId;

@synthesize masterIndex;

+ (NSString*) parseModelClass
{
    return @"User";
}

@end
