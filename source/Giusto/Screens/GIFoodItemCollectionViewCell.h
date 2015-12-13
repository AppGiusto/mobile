//
//  GIFoodItemCollectionViewCell.h
//  Giusto
//
//  Created by John Gabelmann on 10/8/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFoodItemCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *itemImageView;
@property (nonatomic, weak) IBOutlet UILabel *itemTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemCountLabel;

@end
