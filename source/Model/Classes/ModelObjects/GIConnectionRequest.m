//
//  GIConnectionRequest.m
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIConnectionRequest.h"

@implementation GIConnectionRequest
@dynamic requestor;
@dynamic requestee;
@dynamic status;


+ (NSString *)parseModelClass
{
    return @"ConnectionRequest";
}

@end
