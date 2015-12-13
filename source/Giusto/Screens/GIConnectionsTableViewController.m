//
//  GIConnectionsTableViewController.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-01.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionsTableViewController.h"
#import "GIConnectionsTableViewCell.h"
#import "GIUserStore.h"
#import "GIConnectionDependentsTableViewController.h"
#import "GIUserProfileViewController.h"

@interface GIConnectionsTableViewController ()<GIConnectionsTableViewCellDelegate>
@property (strong,nonatomic) NSDictionary *groupOfconnections;
@property (strong,nonatomic) NSDictionary *searchResults;
@property (assign,nonatomic) BOOL isSearching;
@end

@implementation GIConnectionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // observe the connections
    [[NSNotificationCenter defaultCenter] addObserverForName:kGIConnectionRequestStoreDidAcceptConnectionRequest object:[GIConnectionRequestStore sharedStore] queue:nil usingBlock:^(NSNotification *note) {
        [self reloadDataConnections];
    }];
    
    [self reloadDataConnections];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GIConnectionRequestStore sharedStore] evaluateAndFinalizeSentConnectionRequestsWithCompletionBlock:^(id sender, BOOL success, NSError *error, NSArray *fulfilledConnections) {
        if (fulfilledConnections.count > 0)
        {
            [self reloadDataConnections];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"DependentsSegue"])
    {
        CGPoint center = [(UIButton *)sender center];
        CGPoint rootViewPoint = [[(UIButton *)sender superview] convertPoint:center toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:rootViewPoint];
        
        GIUser *selectedUser = [[self connectionsInSection:[[self connectionSections] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
        if (selectedUser)
        {
            GIConnectionDependentsTableViewController *dependentsTableViewController = segue.destinationViewController;
            dependentsTableViewController.user = selectedUser;
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.currentTableViewData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self connectionSections];
    NSInteger numberOfRowsInSection = [self connectionsInSection:[sections objectAtIndex:section]].count;
    return numberOfRowsInSection;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    
    GIConnectionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIConnections"];
    cell.user = [self connectionAtIndexpath:indexPath];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[[NSBundle mainBundle] loadNibNamed:@"GIConnectionsTableViewSectionView" owner:nil options:nil] firstObject];
    
    NSArray *sections = [self connectionSections];
    headerLabel.text = @"";
    
    if (section < sections.count)
    {
        headerLabel.text = [NSString stringWithFormat:@"   %@",sections[section]];
        headerLabel.layer.borderWidth = 0.26;
        headerLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }

    return headerLabel;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.modelUpdateDelegate willUpdateDataModelconnectionsTableViewController:self];
        [[GIUserStore sharedStore] removeConnection:[self connectionAtIndexpath:indexPath] withCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
            if (success)
            {
                [self reloadDataConnections];
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.modelUpdateDelegate didUpdateDataModelconnectionsTableViewController:self];
                });
            }
        }];
    }
}

#pragma mark UITableViewDelegate

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    NSArray *sections = [self connectionSections];
    if (sections.count > sectionIndex)
    {
        NSArray *connections = [self connectionsInSection:sections[sectionIndex]];
        
        if ( connections.count > rowIndex)
        {
            GIUser *connection = [connections objectAtIndex:rowIndex];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            GIUserProfileViewController *userProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"GIUserProfileViewController"];
            userProfileViewController.isReadOnlyMode = YES;
            userProfileViewController.hidesBottomBarWhenPushed = YES;
            userProfileViewController.extendedLayoutIncludesOpaqueBars = YES;
//            userProfileViewController.userProfile = connection.userProfile;
            
            [userProfileViewController configureWithModelObject:connection.userProfile];
            
            [self.navigationController pushViewController:userProfileViewController animated:YES];
        }
    }
}

- (NSDictionary*)currentTableViewData
{
    NSDictionary *currentTableViewData = nil;
    if (self.isSearching)
    {
        if (self.searchResults == nil)
        {
            self.searchResults = @{};
        }
        currentTableViewData = self.searchResults;
    }
    else
    {
        if (self.groupOfconnections == nil)
        {
            self.groupOfconnections = @{};
        }
        currentTableViewData = self.groupOfconnections;
    }
    
    return currentTableViewData;
}

#pragma mark --

- (GIUser*)connectionAtIndexpath:(NSIndexPath*)indexPath
{
    GIUser *connection = nil;
    NSInteger sectionIndex = indexPath.section;
    NSInteger rowIndex = indexPath.row;
    NSArray *sections = [self connectionSections];
    
    if (sections.count > sectionIndex)
    {
        NSArray *connections = [self connectionsInSection:sections[sectionIndex]];
        
        if ( connections.count > rowIndex)
        {
            connection = [connections objectAtIndex:rowIndex];
        }
    }
    
    return connection;
}

- (NSArray*)connectionsInSection:(NSString*)section
{
    NSArray *connections = nil;
    connections = self.currentTableViewData[section];
    return connections;
}

- (NSArray*)connectionSections
{
    return [[self.currentTableViewData allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
       return [key1 compare:key2];
    }];
}

- (void)updateConnectionGroupWithConnections:(NSArray*)connections
{

    NSMutableDictionary *connectionGroup = [self.currentTableViewData mutableCopy];
    [connectionGroup removeAllObjects];
    
    [connections enumerateObjectsUsingBlock:^(GIUser *user, NSUInteger idx, BOOL *stop) {

        GIUserProfile *aUserProfile = user.userProfile;
        
        if (aUserProfile != NULL)
        {
            NSString *fullName = aUserProfile.fullName;
            NSString *groupKey = [[fullName substringToIndex:1] capitalizedString];
            NSMutableArray *users = connectionGroup[groupKey];
            
            if (users == nil)
            {
                users = [@[] mutableCopy];
                connectionGroup[groupKey] = users;
            }
            
            [users addObject:user];
        }
    }];
    
    if (self.isSearching)
    {
        self.searchResults = [NSDictionary dictionaryWithDictionary:connectionGroup];
    }
    else
    {
        self.groupOfconnections = [NSDictionary dictionaryWithDictionary:connectionGroup];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.isSearching == NO)
        {
            [self.modelUpdateDelegate connectionsTableViewController:self didUpdateModelWithNumberOfConnections:self.groupOfconnections.count];
        }
    });
}

- (void)reloadDataConnections
{
    [self.modelUpdateDelegate willUpdateDataModelconnectionsTableViewController:self];
    [[GIUser sharedStore] connectionsWithCompletionBlock:^(id sender, BOOL success, NSError *error, NSArray *connections) {
        
        NSArray *sortedConnections = nil;
        if (success)
        {
            sortedConnections = [connections sortedArrayUsingComparator:^NSComparisonResult(GIUser *obj1, GIUser *obj2) {
                NSString *fullName1 = obj1.userProfile.fullName;
                NSString *fullName2 = obj2.userProfile.fullName;
                
                if (fullName1 != nil && fullName2 != nil)
                {
                    return [fullName1 compare:fullName2];
                }
                else
                {
                    return NSOrderedSame;
                }
            }];
        }
        
        [self updateConnectionGroupWithConnections:sortedConnections];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.modelUpdateDelegate didUpdateDataModelconnectionsTableViewController:self];
        });
    }];
}

- (void)performSearchForString:(NSString*)searchString withResultCountUpdateBlock:(GIConnectionsSearchResultCountUpdateBlock)resultBlock
{
    self.isSearching = YES;
    if (self.searchResults == nil)
    {
        self.searchResults = [NSDictionary dictionaryWithDictionary:self.groupOfconnections];
    }
    
    if ([searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
            NSMutableArray *filteredConnections = [@[] mutableCopy];
            [[self.currentTableViewData allValues] enumerateObjectsUsingBlock:^(NSArray *aGroupOfConnections, NSUInteger idx, BOOL *stop) {
                [aGroupOfConnections enumerateObjectsUsingBlock:^(GIUser *aConnection, NSUInteger idx, BOOL *stop) {
                    if ([[aConnection.parseUser[@"userProfile"] fetchIfNeeded][@"fullName"] rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound)
                    {
                        [filteredConnections addObject:aConnection];
                    }
                }];
            }];
            
            resultBlock(self,(int)filteredConnections.count);
            [self updateConnectionGroupWithConnections:filteredConnections];
        }];
    }
    else
    {
        resultBlock(self,0);
    }
}

- (void)cancelSearch
{
    self.isSearching = NO;
    self.searchResults = nil;
    [self.tableView reloadData];
}

#pragma mark GIConnectionsTableViewCellDelegate
- (void)showDependentsForUserRepresentedInConnectionsTableViewCell:(GIConnectionsTableViewCell*)tableViewCell
{
}
@end