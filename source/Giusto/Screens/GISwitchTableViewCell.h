//
//  GISwitchTableViewCell.h
//  Giusto
//
//  Created by John Gabelmann on 9/18/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GISwitchTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *switchLabel;
@property (nonatomic, weak) IBOutlet UISwitch *cellSwitch;

@end
