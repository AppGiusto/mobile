//
//  GIUserProfile+GIModelRelation.h
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIUserProfile.h"

@interface GIUserProfile (GIModelRelation)

/**
 *  Cannot Have Food Items: Asynchronous
 *
 *  @return An array of food items that the user profile cannot have.
 */
- (void) cannotHaveFoodItemsWithCompletion:(MYCompletionBlock)completion;

/**
 *  Liked Food Items
 *
 *  @return An array of food items that the user likes.
 */
- (void) likedFoodItemsWithCompletion:(MYCompletionBlock)completion;

/**
 *  Disliked Food Items
 *
 *  @return An array of food items that the user does not like.
 */
- (void) dislikedFoodItemsWithCompletion:(MYCompletionBlock)completion;

/**
 *  Disliked Food Items
 *
 *  @return An array of food items that the user does not like.
 */
- (void) dietItemsWithCompletion:(MYCompletionBlock)completion;

/**
 *  Cannot Have Food Items
 *
 *  @return An array of food items that the user profile cannot have.
 */
- (NSArray*) cannotHaveFoodItems;
- (NSArray*) cannotHaveFoodItemsWithLimit:(int)limit;
- (NSArray*) cannotHaveFoodItemsWithLimit:(int)limit andType:(NSString*)type;

/**
 *  Liked Food Items
 *
 *  @return An array of food items that the user profile likes.
 */
- (NSArray*) likedFoodItems;
- (NSArray*) likedFoodItemsWithLimit:(int)limit;
- (NSArray*) likedFoodItemsWithLimit:(int)limit andType:(NSString*)type;

/**
 *  Disliked Food Items
 *
 *  @return An array of food items that the user profile dislikes.
 */
- (NSArray*) dislikedFoodItems;
- (NSArray*) dislikedFoodItemsWithLimit:(int)limit;
- (NSArray*) dislikedFoodItemsWithLimit:(int)limit andType:(NSString*)type;

/**
 *  Diet Items
 *
 *  @return An array of diet items that the user profile have.
 */
- (NSDictionary*) dietItems;

- (void) dependentsWithCompletion:(MYCompletionBlock)completion;

- (void) userWithCompletion:(MYCompletionBlock)completion;

- (NSUInteger) countLikedFoodItems;
- (void) countLikedFoodItemsWithCompletion:(MYCompletionBlock)completion;

- (NSUInteger) countDislikedFoodItems;
- (void) countDislikedFoodItemsWithCompletion:(MYCompletionBlock)completion;

- (NSUInteger) countCannotHaveFoodItems;
- (void) countCannotHaveFoodItemsWithCompletion:(MYCompletionBlock)completion;

- (NSArray*) likedIngredients;
- (NSArray*) dislikedIngredients;
- (NSArray*) cannotHaveIngredients;

@end
