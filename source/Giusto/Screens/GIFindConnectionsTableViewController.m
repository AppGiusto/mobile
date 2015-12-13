//
//  GIFindConnectionsTableViewController.m
//  Giusto
//
//  Created by Elinam Hini on 2014-10-10.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIFindConnectionsTableViewController.h"
#import "GIAddAConnectionTableViewCell.h"

@interface PFObject (GISimpleEquality)
@end

@interface PFUser (GISimpleEquality)
@end

@interface GIFindConnectionsTableViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>
@end

@implementation GIFindConnectionsTableViewController

- (BOOL)isValidEmail:(NSString *)email
{
    NSString *regex1 = @"\\A[a-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,}\\z";
    NSString *regex2 = @"^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*";
    NSPredicate *test1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [test1 evaluateWithObject:email] && [test2 evaluateWithObject:email];
}
- (void)removeDuplicatesAndFinalizeSearchResult:(NSArray*)users withResultCountUpdateBlock:(GIConnectionsSearchResultCountUpdateBlock)resultBlock
{
    [[GIUserStore sharedStore] connectionsWithCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
        NSMutableArray *connections = [NSMutableArray array];
        [users enumerateObjectsUsingBlock:^(GIUser *user, NSUInteger idx, BOOL *stop) {
            if (![result containsObject:[user parseUser]])
            {
                [connections addObject:user];
            }
            resultBlock(self,(int)connections.count);
            self.users = connections;
        }];
    }];
}

- (void)performSearchForString:(NSString*)searchString withResultCountUpdateBlock:(GIConnectionsSearchResultCountUpdateBlock)resultBlock
{
    if ([searchString rangeOfString:@"@"].location != NSNotFound)
    {
        if ([self isValidEmail:searchString])
        {
            [[GIUserStore sharedStore] findConnectionsWithEmail:searchString completion:^(id sender, BOOL success, NSError *error, NSArray *users) {
                if (users.count > 0)
                {
                    [self removeDuplicatesAndFinalizeSearchResult:users withResultCountUpdateBlock:resultBlock];
                }
                else
                {
                    resultBlock(self,(int)users.count);
                    self.users = users;
                }
            }];
        }
        else
        {
            resultBlock(self,0);
            self.users = @[];
        }
    }
    else if ([searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [[GIUserStore sharedStore] findConnectionsWithFullName:searchString completion:^(id sender, BOOL success, NSError *error, NSArray *users) {
            if (users.count > 0)
            {
                [self removeDuplicatesAndFinalizeSearchResult:users withResultCountUpdateBlock:resultBlock];
            }
            else
            {
                resultBlock(self,(int)users.count);
                self.users = users;
            }
        }];
    }
    else
    {
        resultBlock(self,0);
        self.users = @[];
    }
}

- (void)cancelSearch
{
    self.users = @[];
}

- (void)updateControlElementsForTableViewCell:(GIAddAConnectionTableViewCell*)cell forRequestSent:(BOOL)isRequestSent
{
    [cell.sendConnectionRequestButton setEnabled:!isRequestSent];
    [cell.sendConnectionRequestButton setImage:(isRequestSent) ? [UIImage imageNamed:@"connectionRequestSent"] : [UIImage imageNamed:@"SendConnectionRequest"] forState:UIControlStateDisabled];
}
#pragma mark - GIAddAConnectionTableViewCellDelegate
- (void) sendConnectionRequestForTableviewCell:(GIAddAConnectionTableViewCell*)tableViewCell
{
    GIConnectionRequest *connectionRequest = [[GIConnectionRequest alloc] initWithParseObject:[[PFObject alloc] initWithClassName:@"ConnectionRequest"]];
    connectionRequest.parseObject[@"requestor"] = [GIUserStore sharedStore].currentUser.parseUser;
    connectionRequest.parseObject[@"requestee"] = tableViewCell.user.parseUser;

    [self.view showProgressHUD];
    [[GIConnectionRequestStore sharedStore] sendConnectionRequest:connectionRequest withCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
        
        if (success)
        {
            NSLog(@"Did Send connection Request");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideProgressHUD];
            [self updateControlElementsForTableViewCell:tableViewCell forRequestSent:YES];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = self.users.count;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GIAddAConnectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIUserCell" forIndexPath:indexPath];
    if (indexPath.row < self.users.count)
    {
        cell.user = [self.users objectAtIndex:indexPath.row];
        cell.delegate = self;
        [[GIUserStore sharedStore].currentUser connectionRequestsSentTo:cell.user.parseUser withCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result count] == 1)
                {
                    [self updateControlElementsForTableViewCell:cell forRequestSent:YES];
                }
                else
                {
                    [self updateControlElementsForTableViewCell:cell forRequestSent:NO];
                }
            });
        }];
    }
    return cell;
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

#pragma mark UITableView Delegate
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

// TODO: Resolve in POD or find another way to include these categories
@implementation PFObject (GISimpleEquality)

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[PFObject class]])
    {
        PFObject* pfObject = object;
        return [self.objectId isEqualToString:pfObject.objectId];
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return self.objectId.hash;
}

@end

@implementation PFUser (GISimpleEquality)

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass:[PFUser class]])
    {
        PFUser* pfUser = object;
        return [self.objectId isEqualToString:pfUser.objectId];
    }
    
    return NO;
}

- (NSUInteger) hash
{
    return self.objectId.hash;
}

@end
