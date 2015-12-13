//
//  GIDietItem.m
//  Giusto
//
//  Created by Nielson Rolim on 7/20/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIDietItem.h"

@implementation GIDietItem

@dynamic name;
@dynamic photoURL;
@dynamic objectId;

//- (NSString*) objectId {
//    return self.parseObject.objectId;
//}

+ (NSString *)parseModelClass
{
    return @"DietItem";
}

@end
