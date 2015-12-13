//
//  GIFoodItem.h
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIModelObjectBase.h"

@interface GIFoodItem : GIModelObjectBase

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *photoURL;
@property (nonatomic,strong) NSString *type;

@property (nonatomic, assign) float memberPercentage;
@property (nonatomic, assign) int memberCount;

@property (nonatomic, retain) NSMutableArray *memberArray;

// foodItemType

@end
