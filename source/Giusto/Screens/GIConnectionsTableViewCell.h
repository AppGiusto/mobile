//
//  GIConnectionsTableViewCell.h
//  Giusto
//
//  Created by Eli Hini on 2014-10-23.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIUserTableViewCellBase.h"

@protocol GIConnectionsTableViewCellDelegate;
@interface GIConnectionsTableViewCell : GIUserTableViewCellBase
@property (nonatomic,strong) IBOutlet UIButton *showDependentsButton;
@property (nonatomic,assign) id<GIConnectionsTableViewCellDelegate>delegate;

- (IBAction)showDependents:(id)sender;
@end

@protocol GIConnectionsTableViewCellDelegate <NSObject>

- (void)showDependentsForUserRepresentedInConnectionsTableViewCell:(GIConnectionsTableViewCell*)tableViewCell;

@end