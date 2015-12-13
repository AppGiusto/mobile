//
//  UIImage+MyAdditions.h
//  Giusto
//
//  Created by Fredrick Gabelmann on 9/14/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MyAdditions)

+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end