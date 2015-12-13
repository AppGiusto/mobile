//
//  PFObject+GISimpleEquality.m
//  Pods
//
//  Created by Eli Hini on 2014-10-26.
//
//

#import "PFObject+GISimpleEquality.h"

@implementation PFObject (GISimpleEquality)

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[PFObject class]])
    {
        PFObject* pfObject = object;
        return [self.objectId isEqualToString:pfObject.objectId];
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return self.objectId.hash;
}

@end

@implementation PFUser (GISimpleEquality)

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[PFUser class]])
    {
        PFUser* pfUser = object;
        return [self.objectId isEqualToString:pfUser.objectId];
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return self.objectId.hash;
}

@end