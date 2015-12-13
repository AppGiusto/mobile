//
//  GIConnectionRequest+GIModelRelation.h
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIConnectionRequest.h"

@class GIUser;

@interface GIConnectionRequest (GIModelRelation)

/**
 *  User1
 *
 *  @return The user initiating the connection request.
 */
- (GIUser*) user1;

/**
 *  User2
 *
 *  @return The user that might accept the connection request.
 */
- (GIUser*) user2;

@end
