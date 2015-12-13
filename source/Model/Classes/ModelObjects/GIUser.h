//
//  GIUser.h
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "ParseModelUser.h"

@interface GIUser : ParseModelUser

@property (nonatomic,strong) NSString* username;
@property (nonatomic,strong) NSString* email;
@property (nonatomic,strong) NSString* password;
@property (nonatomic,strong) NSString* objectId;
@property (nonatomic,strong) NSString* facebookId;

@property (assign)           NSUInteger masterIndex;
// connections
// dependents


@end
