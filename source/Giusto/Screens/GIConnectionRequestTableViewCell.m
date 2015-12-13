//
//  GIConnectionRequestTableViewCell.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-22.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionRequestTableViewCell.h"

@implementation GIConnectionRequestTableViewCell

- (void)setConnectionRequest:(GIConnectionRequest *)connectionRequest
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(user))];
    _connectionRequest = connectionRequest;
    [self willChangeValueForKey:NSStringFromSelector(@selector(user))];
    self.user = [GIUser parseModelUserWithParseUser:connectionRequest.requestor];
}

- (IBAction)forActionForAcceptConnectionRequest:(id)sender
{
    [self.delegate acceptConnectionRequestForTableviewCell:self];
}

- (IBAction)forActionForRejectConnectionRequest:(id)sender
{
    [self.delegate rejectConnectionRequestForTableviewCell:self];
}
@end
