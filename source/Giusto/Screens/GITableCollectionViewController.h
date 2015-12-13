//
//  GITableCollectionViewController.h
//  Giusto
//
//  Created by John Gabelmann on 10/20/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GIGroupsOfTablesDelegate;

@interface GITableCollectionViewController : UICollectionViewController
@property (nonatomic,weak) id<GIGroupsOfTablesDelegate>modelDataUpdateDelegate;
@end

@protocol GIGroupsOfTablesDelegate <NSObject>
- (void)tableCollectionViewController:(GITableCollectionViewController*)collectionViewController didUpdateModelWithCount:(NSInteger)count;

- (void)tableCollectionViewControllerWillUpdateDataModel;

@end