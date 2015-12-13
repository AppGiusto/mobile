//
//  GIFoodItemsTableViewController.h
//  Giusto
//
//  Created by Timothy Raveling on 15-05-20.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFoodTableTypeLikes         0
#define kFoodTableTypeDislikes      1
#define kFoodTableTypeCannotHaves   2

@interface GIFoodItemsTableViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *aFoodItems;
@property (assign)            int tableType;

@end
