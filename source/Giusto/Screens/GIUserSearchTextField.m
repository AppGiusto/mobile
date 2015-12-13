//
//  GIUserSearchTableViewCell.m
//  Giusto
//
//  Created by Elinam Hini on 2014-10-09.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserSearchTextField.h"

@implementation GIUserSearchTextField
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.clipsToBounds = YES;
    self.rightViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 18)];
    self.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 15, 15)];
    leftImageView.image = [UIImage imageNamed:@"SearchGlass"];
    leftImageView.contentMode = UIViewContentModeCenter;
    [leftView addSubview:leftImageView];
    self.leftView = leftView;
    return self;
}
@end