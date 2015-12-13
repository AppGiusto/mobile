//
//  GIQuizQuestionCollectionViewCell.h
//  Giusto
//
//  Created by Nielson Rolim on 6/29/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIQuizButton.h"

@interface GIQuizQuestionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionNumberLabel;
@property (weak, nonatomic) IBOutlet GIQuizButton *likeButton;
@property (weak, nonatomic) IBOutlet GIQuizButton *dislikeButton;
@property (weak, nonatomic) IBOutlet GIQuizButton *cannotHaveButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end
