//
//  GITable+GIModelRelation.h
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GITable.h"

@interface GITable (GIModelRelation)

/**
 *  UserProfiles
 *
 *  @return UserProfiles associated with this table.
 */
- (void) userProfilesWithCompletion:(MYCompletionBlock)completion;
- (void) userProfilesIncludingFoodItemsWithCompletion:(MYCompletionBlock)completion;

@end
