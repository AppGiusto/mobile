//
//  GIFoodItemCollectionViewCell.m
//  Giusto
//
//  Created by John Gabelmann on 10/8/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIFoodItemCollectionViewCell.h"

@implementation GIFoodItemCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.itemImageView.layer.borderColor = GIColorImageViewBorderColor.CGColor;
    self.itemImageView.layer.borderWidth = 1;
}

@end
