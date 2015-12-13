//
//  GIUserTableViewControllerBase.m
//  Giusto
//
//  Created by Elinam Hini on 2014-10-02.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserTableViewControllerBase.h"

@interface GIUserTableViewControllerBase ()
@property (nonatomic,strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation GIUserTableViewControllerBase

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setModelUpdateDelegate:(id<GIUserTableViewControllerBaseDelegate>)modelUpdateDelegate
{
    _modelUpdateDelegate = modelUpdateDelegate;
    if (self.tapGestureRecognizer == nil && _modelUpdateDelegate != nil)
    {
        [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)]];
    }
}

- (void)setUsers:(NSArray *)users
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(users))];
    _users = users;
    [self didChangeValueForKey:NSStringFromSelector(@selector(users))];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //if (self.isSearching)
    {
        [self.modelUpdateDelegate didBeginToInteractWithTableViewController:self];
    }
}

#pragma mark --
- (void)didTapOnTableView:(UITapGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint touchLocation = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchLocation];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];

        if (cell)
        {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            
            if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
            {
                [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            }
        }
        else
        {
            [self.modelUpdateDelegate didBeginToInteractWithTableViewController:self];
        }
    }
}

- (void)performSearchForString:(NSString*)searchString withResultCountUpdateBlock:(GIConnectionsSearchResultCountUpdateBlock)resultBlock
{
}

- (void)cancelSearch
{
}
@end
