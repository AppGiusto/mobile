//
//  GIFoodItemsTableViewCell.h
//  Giusto
//
//  Created by Timothy Raveling on 15-05-20.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFoodItemsTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *ivIcon;
@property (nonatomic, retain) IBOutlet UILabel *lbItemLabel;
@property (nonatomic, retain) IBOutlet UILabel *lbPercentage;

@end
