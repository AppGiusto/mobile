//
//  GIUserTableViewControllerBase.h
//  Giusto
//
//  Created by Elinam Hini on 2014-10-02.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "MYModelObjectTableViewControllerBase.h"
#import "GIAddAConnectionTableViewCell.h"

typedef enum GIConnectionsDisplayMode
{
    GIConnectionsDisplayModeDefault,
    GIConnectionsDisplayModeFindConnections,
    GIConnectionsDisplayModeUnknown
}GIConnectionsDisplayMode;

typedef void (^GIConnectionsSearchResultCountUpdateBlock)(id sender, int numberOfItemsFound);

@protocol GIUserTableViewControllerBaseDelegate;

@interface GIUserTableViewControllerBase : UITableViewController
@property (nonatomic,strong) NSArray *users;
@property (nonatomic,weak) id<GIUserTableViewControllerBaseDelegate>modelUpdateDelegate;
- (void)performSearchForString:(NSString*)searchString withResultCountUpdateBlock:(GIConnectionsSearchResultCountUpdateBlock)resultBlock;
- (void)cancelSearch;
@end

@protocol GIUserTableViewControllerBaseDelegate <NSObject>
- (void)connectionsTableViewController:(GIUserTableViewControllerBase*)connectionsTableViewController didUpdateModelWithNumberOfConnections:(NSInteger)numberOfConnections;
- (void)willUpdateDataModelconnectionsTableViewController:(GIUserTableViewControllerBase *)connectionsTableViewController;
- (void)didUpdateDataModelconnectionsTableViewController:(GIUserTableViewControllerBase *)connectionsTableViewController;
- (void)didBeginToInteractWithTableViewController:(GIUserTableViewControllerBase *)connectionsTableViewController;
@end