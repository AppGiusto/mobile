//
//  GIAddAConnectionTableViewCell.h
//  Giusto
//
//  Created by Elinam Hini on 2014-10-02.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserTableViewCellBase.h"

@protocol GIAddAConnectionTableViewCellDelegate;

@interface GIAddAConnectionTableViewCell : GIUserTableViewCellBase
@property (nonatomic,weak) IBOutlet id<GIAddAConnectionTableViewCellDelegate>delegate;
@property (nonatomic,strong) IBOutlet UIButton *sendConnectionRequestButton;
- (IBAction)sendConnectionRequest:(id)sender;
@end

@protocol GIAddAConnectionTableViewCellDelegate <NSObject>
- (void) sendConnectionRequestForTableviewCell:(GIAddAConnectionTableViewCell*)tableViewCell;
@end