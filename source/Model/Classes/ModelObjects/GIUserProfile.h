//
//  GIUserProfile.h
//  Pods
//
//  Created by Vincil Bishop on 8/31/14.
//
//

#import "GIModelObjectBase.h"

@interface GIUserProfile : GIModelObjectBase

@property (nonatomic,strong) NSString *fullName;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSURL *photoURL;
@property (nonatomic,strong) NSDate *birthDate;

@property (nonatomic, strong) NSArray* cannotHaveFoodItems;
@property (nonatomic, strong) NSArray* dislikedFoodItems;
@property (nonatomic, strong) NSArray* likedFoodItems;

@property (assign)           NSUInteger masterIndex;



// userId
// cannotHaveFoodItems
// dislikedFoodItems
// likedFoodItems
// dependents
// dietItems

@end
