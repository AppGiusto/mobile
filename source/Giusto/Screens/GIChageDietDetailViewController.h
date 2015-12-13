//
//  GIChageDietDetailViewController.h
//  Giusto
//
//  Created by Nielson Rolim on 7/26/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIChangeDietDetailViewControllerBase.h"
#import "GIDietItem.h"

@interface GIChageDietDetailViewController : GIChangeDietDetailViewControllerBase <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary* userDietItems;

@end
