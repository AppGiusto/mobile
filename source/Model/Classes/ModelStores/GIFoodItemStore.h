/*
 *	GIFoodItemStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"

typedef enum GIFoodItemCategory {
    
    GIFoodItemCategoryLikes,
    GIFoodItemCategoryDislikes,
    GIFoodItemCategoryCannotHaves,
    
} GIFoodItemCategory;

@class GIUserProfile;
@class GIFoodItem;
@class GIFoodItemType;

@interface GIFoodItemStore : GIModelStoreBase

+ (GIFoodItemStore *) sharedStore;

- (NSArray *) getFoodItems;
- (void) getFoodItemsWithCompletion:(MYCompletionBlock)completion;
- (void) getFoodItemsDictionaryWithCompletion:(MYCompletionBlock)completion;
- (void) getFoodItemsForType:(GIFoodItemType*)foodItemType withCompletion:(MYCompletionBlock)completion;
- (void) getFoodItemsDictionaryForType:(GIFoodItemType*)foodItemType withCompletion:(MYCompletionBlock)completion;
- (void) getFoodItemsForSearchPhrase:(NSString*)phrase andType:(NSString*)type withCompletion:(MYCompletionBlock)completion;
- (NSError *)addFoodItems:(NSArray *)foodItems toProfile:(GIUserProfile *)profile itemCategory:(GIFoodItemCategory)category;
- (NSError *)addFoodItem:(GIFoodItem *)foodItem toProfile:(GIUserProfile *)profile itemCategory:(GIFoodItemCategory)category;
- (void) addFoodItem:(GIFoodItem *)foodItem toProfile:(GIUserProfile *)profile itemCategory:(GIFoodItemCategory)category completion:(MYCompletionBlock)completion;
- (NSError *)removeFoodItems:(NSArray *)foodItems FromProfile:(GIUserProfile *)profile category:(GIFoodItemCategory)category;
- (NSError *)removeFoodItem:(GIFoodItem *)foodItem FromProfile:(GIUserProfile *)profile category:(GIFoodItemCategory)category;
- (void) removeFoodItem:(GIFoodItem *)foodItem FromProfile:(GIUserProfile *)profile category:(GIFoodItemCategory)category completion:(MYCompletionBlock)completion;
- (void)getFoodItemsForQuizForType:(GIFoodItemType*)foodItemType withCompletion:(MYCompletionBlock)completion;

@end