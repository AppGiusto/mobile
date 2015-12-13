//
//  GIAddAConnectionTableViewCell.m
//  Giusto
//
//  Created by Elinam Hini on 2014-10-02.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIAddAConnectionTableViewCell.h"


@implementation GIAddAConnectionTableViewCell
- (IBAction)sendConnectionRequest:(id)sender
{
    [self.delegate sendConnectionRequestForTableviewCell:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
