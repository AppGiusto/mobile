//
//  GIUserProfileViewController.h
//  Giusto
//
//  Created by Vincil Bishop on 9/3/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserProfileViewControllerBase.h"

@protocol GIUserProfileViewControllerDelegate <NSObject>
@optional
-(void)refreshProfileDataSource;
@end


@interface GIUserProfileViewController : GIUserProfileViewControllerBase<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) GIUserProfile *selectedDependent;
@property (nonatomic, strong) GIUserProfile *dependentsUser;

@end