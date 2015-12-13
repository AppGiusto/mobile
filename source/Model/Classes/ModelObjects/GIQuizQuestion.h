//
//  GIQuizQuestion.h
//  Giusto
//
//  Created by Nielson Rolim on 7/6/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIQuizQuestion : NSObject

@property (nonatomic, strong) GIFoodItem* foodItem;
@property (nonatomic, assign) NSUInteger questionNumber;

@end
