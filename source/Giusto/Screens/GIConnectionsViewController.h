//
//  GIConnectionsViewController.h
//  Giusto
//
//  Created by Elinam Hini on 2014-10-10.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIConnectionsTableViewController.h"


@interface GIConnectionsViewController : UIViewController <UITextFieldDelegate,UISearchBarDelegate>
@property (nonatomic,assign) GIConnectionsDisplayMode displayMode;
@property (nonatomic,weak) IBOutlet GIConnectionsTableViewController *connectionsTableViewController;
@property (nonatomic,weak) IBOutlet UILabel *searchResultsLabel;
@property (nonatomic,weak) IBOutlet UISearchBar *connectionsSearchBar;
@property (nonatomic,weak) IBOutlet UIView *instructionView;
@end