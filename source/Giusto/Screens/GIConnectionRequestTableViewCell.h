//
//  GIConnectionRequestTableViewCell.h
//  Giusto
//
//  Created by Eli Hini on 2014-10-22.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIUserTableViewCellBase.h"
#import "GIConnectionRequest.h"

@protocol GIConnectionRequestTableViewCellDelegate;

@interface GIConnectionRequestTableViewCell : GIUserTableViewCellBase
@property (nonatomic,strong) GIConnectionRequest *connectionRequest;
@property (nonatomic,weak) IBOutlet id<GIConnectionRequestTableViewCellDelegate>delegate;
- (IBAction)forActionForAcceptConnectionRequest:(id)sender;
- (IBAction)forActionForRejectConnectionRequest:(id)sender;

@end

@protocol GIConnectionRequestTableViewCellDelegate <NSObject>
- (void) acceptConnectionRequestForTableviewCell:(GIConnectionRequestTableViewCell*)tableViewCell;
- (void) rejectConnectionRequestForTableviewCell:(GIConnectionRequestTableViewCell*)tableViewCell;
@end