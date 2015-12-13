//
//  GITableCollectionViewCell.h
//  Giusto
//
//  Created by John Gabelmann on 10/20/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GITableCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *tableNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *memberCountLabel;

@end
