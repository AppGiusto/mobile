//
//  GIValidationBD.m
//  Giusto
//
//  Created by John Gabelmann on 10/21/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIValidationBD.h"

@implementation GIValidationBD

+ (BOOL)isEmailValid:(NSString *)email
{
    NSString *regex1 = @"\\A[a-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,}\\z";
    NSString *regex2 = @"^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*";
    NSPredicate *test1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [test1 evaluateWithObject:email] && [test2 evaluateWithObject:email];
}


@end
