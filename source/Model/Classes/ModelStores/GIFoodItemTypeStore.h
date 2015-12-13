/*
 *	GIFoodItemTypeStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"

@interface GIFoodItemTypeStore : GIModelStoreBase

+ (GIFoodItemTypeStore *) sharedStore;

- (void)getFoodItemsTypesWithCompletion:(MYCompletionBlock)completion;
- (void)getFoodItemForName:(NSString*)name withCompletion:(MYCompletionBlock)completion;

@end