//
//  GIDietItemStore.h
//  Giusto
//
//  Created by Nielson Rolim on 7/25/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIModelStoreBase.h"

@interface GIDietItemStore : GIModelStoreBase

+ (GIDietItemStore *) sharedStore;
- (NSArray *) getDietItems;
- (void) getDietItemsWithCompletion:(MYCompletionBlock)completion;
- (void) getDietItemForName:(NSString*)name withCompletion:(MYCompletionBlock)completion;
- (NSError*) addDietItems:(NSArray *)dietItems toProfile:(GIUserProfile *)profile;
- (NSError*) addDietItem:(GIDietItem *)dietItem toProfile:(GIUserProfile *)profile;
- (void) addDietItem:(GIDietItem *)dietItem toProfile:(GIUserProfile *)profile completion:(MYCompletionBlock)completion;
- (NSError*)removeDietItems:(NSArray *)dietItems FromProfile:(GIUserProfile *)profile;
- (NSError*)removeDietItem:(GIDietItem *)dietItem FromProfile:(GIUserProfile *)profile;
- (void) removeDietItem:(GIDietItem *)dietItem FromProfile:(GIUserProfile *)profile completion:(MYCompletionBlock)completion;

- (void)addFoodItem:(GIFoodItem *)foodItem toDiet:(GIDietItem *)diet completion:(MYCompletionBlock)completion;

@end
