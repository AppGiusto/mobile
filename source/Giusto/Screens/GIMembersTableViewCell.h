//
//  GIMembersTableViewCell.h
//  Giusto
//
//  Created by Timothy Raveling on 15-05-07.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GIMembersTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *ivProfile;
@property (nonatomic, retain) IBOutlet UILabel *lbName;
@property (nonatomic, retain) IBOutlet UIButton *btDependents,*btCheckbox;

@property (strong, nonatomic) GIUserProfile *userProfile;

- (void)setUser:(GIUserProfile*)user;

@end
