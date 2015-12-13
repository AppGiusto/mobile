//
//  GIDietItem.h
//  Giusto
//
//  Created by Nielson Rolim on 7/20/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIModelObjectBase.h"

@interface GIDietItem : GIModelObjectBase

@property (nonatomic,strong) NSString* objectId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *photoURL;

+ (NSString *)parseModelClass;

// foodItems

@end
