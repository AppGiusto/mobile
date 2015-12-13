//
//  GIUserProfileTableViewCell.h
//  Giusto
//
//  Created by John Gabelmann on 10/20/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIUserProfileTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profilePhoto;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *selectedButton;
@property (nonatomic, weak) IBOutlet UIButton *dependentsButton;

@end
