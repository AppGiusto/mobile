//
//  GIConnectionRequestsTableViewController.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-22.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionRequestsTableViewController.h"
#import "GIConnectionRequestTableViewCell.h"

@interface GIConnectionRequestsTableViewController ()<GIConnectionRequestTableViewCellDelegate>
@property (nonatomic,strong) NSArray *connectionRequests;
@end

@implementation GIConnectionRequestsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view showProgressHUD];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[GIConnectionRequestStore sharedStore] pendingConnectionRequestsReceivedWithCompletionBlock:^(id sender, BOOL success, NSError *error, id result){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connectionRequests = result;
            [self.view hideProgressHUD];
            [self.tableView reloadData];
        });
    }];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - GIConnectionRequestTableViewCellDelegate
- (void) acceptConnectionRequestForTableviewCell:(GIConnectionRequestTableViewCell*)tableViewCell
{
    [self.view showProgressHUD];
    [[GIConnectionRequestStore sharedStore] acceptConnectionRequest:tableViewCell.connectionRequest withCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
        
        [[GIConnectionRequestStore sharedStore] pendingConnectionRequestsReceivedWithCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connectionRequests = result;
                [self.view hideProgressHUD];
                [self.tableView reloadData];
            });
        }];
    }];
}

- (void) rejectConnectionRequestForTableviewCell:(GIConnectionRequestTableViewCell*)tableViewCell
{
    [self.view showProgressHUD];
    [[GIConnectionRequestStore sharedStore] rejectConnectionRequest:tableViewCell.connectionRequest withCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
        
        [[GIConnectionRequestStore sharedStore] pendingConnectionRequestsReceivedWithCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connectionRequests = result;
                [self.view hideProgressHUD];
                [self.tableView reloadData];
            });
        }];
    }];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.connectionRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIConnectionRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIConnectionRequestTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.connectionRequests.count)
    {
        cell.connectionRequest = [GIConnectionRequest parseModelWithParseObject:[self.connectionRequests objectAtIndex:indexPath.row]];
        cell.delegate = self;
    }

    return cell;
}

#pragma mark UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


@end
