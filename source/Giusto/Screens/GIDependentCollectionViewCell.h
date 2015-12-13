//
//  GIDependentCollectionViewCell.h
//  Giusto
//
//  Created by John Gabelmann on 9/19/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIDependentCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *dependentImageView;
@property (nonatomic, weak) IBOutlet UILabel *dependentNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *depententAgeLabel;

@end
