//
//  GITableDetailsTableViewController.h
//  Giusto
//
//  Created by Eli Hini on 2014-10-30.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GITableDetailsTableViewController : UITableViewController

@property (nonatomic, strong) GITable *table;

- (void) configureWithModelObject:(id<MYParseableModelObject>)modelObject;

@end
