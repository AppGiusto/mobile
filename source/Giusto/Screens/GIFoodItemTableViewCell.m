//
//  GIFoodItemTableViewCell.m
//  Giusto
//
//  Created by John Gabelmann on 10/7/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIFoodItemTableViewCell.h"

@implementation GIFoodItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.itemImageView.layer.borderColor = GIColorImageViewBorderColor.CGColor;
    self.itemImageView.layer.borderWidth = 1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
