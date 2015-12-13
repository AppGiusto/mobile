//
//  GIAddNewTableViewController.m
//  Giusto
//
//  Created by John Gabelmann on 10/20/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIAddNewTableViewController.h"
#import "GIUserProfileTableViewCell.h"
#import "GIUserDependentsTableViewController.h"
#import "GIUserTableViewControllerBase.h"
#import <Underscore.m/Underscore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#define _ Underscore

@interface GIAddNewTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, weak) IBOutlet UITextField *nameField;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *userProfiles;
@property (nonatomic, strong) NSMutableArray *selectedProfiles;
@property (nonatomic, strong) NSArray *searchedProfiles;

@property (nonatomic, strong) NSDictionary *groupOfconnections;

@end

@implementation GIAddNewTableViewController

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)createButtonPressed:(id)sender
{
    if (self.nameField.text.length) {
        [[GITableStore sharedStore] createTableForUser:[GIUserStore sharedStore].currentUser name:self.nameField.text withUserProfiles:self.selectedProfiles completion:^(id sender, BOOL success, NSError *error, id result) {
            if (success) {
                
                [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
            }
        }];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You must have a title for the table", @"You must have a title for the table") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
    }
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *userProfileNib = [UINib nibWithNibName:@"GIUserProfileTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableview registerNib:userProfileNib forCellReuseIdentifier:@"UserProfileCell"];
    
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.selectedProfiles = [NSMutableArray array];
    self.searchedProfiles = [NSArray array];
    self.userProfiles = [NSArray array];
    
    // Add the user themselves to the table right away by default, they are going to be part of their own table yus?
    [self.selectedProfiles addObject:[GIUserStore sharedStore].currentUser.userProfile];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadDataConnections];
}


-(void)viewDidLayoutSubviews
{
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDatasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groupOfconnections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self connectionSections];
    NSInteger numberOfRowsInSection = [self connectionsInSection:[sections objectAtIndex:section]].count;
    return numberOfRowsInSection;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GIUserProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileCell" forIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GIUser *selectedUser;
    
    NSArray *sections = [self connectionSections];
    if (sections.count > indexPath.section)
    {
        NSArray *connections = [self connectionsInSection:sections[indexPath.section]];
        
        if ( connections.count > indexPath.row)
        {
            selectedUser = [connections objectAtIndex:indexPath.row];
        }
    }
    
    __block GIUserProfile *selectedProfile = selectedUser.userProfile;
    
    NSArray *filteredProfiles = [self.selectedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]];
    
    if (filteredProfiles.count > 0) {
        [self.selectedProfiles removeObject:filteredProfiles.firstObject];
        
        [selectedProfile dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
            if (dependents.count) {
                for (GIUserProfile *dependent in dependents) {
                    if ([[self.selectedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", dependent.parseObject.objectId]] count]) {
                        
                        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You cannot remove a user who has dependents in the table, remove them first", @"You cannot remove a user who has dependents in the table, remove them first") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
                        [self.selectedProfiles addObject:selectedProfile];
                        [self.tableview reloadData];
                    }
                }
            }
        }];
    }
    else
    {
        [self.selectedProfiles addObject:selectedProfile];
    }
    
    [self.tableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    CGPoint center = [(UIButton *)sender center];
    CGPoint rootViewPoint = [[(UIButton *)sender superview] convertPoint:center toView:self.tableview];
    NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
    
    GIUser *selectedUser;
    
    NSArray *sections = [self connectionSections];
    if (sections.count > indexPath.section)
    {
        NSArray *connections = [self connectionsInSection:sections[indexPath.section]];
        
        if ( connections.count > indexPath.row)
        {
            selectedUser = [connections objectAtIndex:indexPath.row];
        }
    }
    
    GIUserDependentsTableViewController *destination = segue.destinationViewController;
    destination.selectedProfiles = self.selectedProfiles;
    destination.selectedUser = selectedUser;
    
    destination.title = [NSString stringWithFormat:@"%@'s %@", selectedUser.userProfile.fullName, NSLocalizedString(@"Dependents", @"Dependents")];
}



#pragma mark - Private Methods

- (void)configureCell:(GIUserProfileTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell.dependentsButton addTarget:self action:@selector(dependentsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.dependentsButton.hidden = YES;
    
    GIUser *user;
    
    NSArray *sections = [self connectionSections];
    if (sections.count > indexPath.section)
    {
        NSArray *connections = [self connectionsInSection:sections[indexPath.section]];
        
        if ( connections.count > indexPath.row)
        {
            user = [connections objectAtIndex:indexPath.row];
        }
    }
    
    GIUserProfile *userProfile = user.userProfile;
    
    cell.nameLabel.text = userProfile.fullName;
    
    [cell.profilePhoto setImageWithURL:userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    
    if ([self.selectedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]].count > 0) {
        cell.selectedButton.selected = YES;
    }
    else
    {
        cell.selectedButton.selected = NO;
    }
    
    __block NSIndexPath *_indexPath = indexPath;

    [userProfile dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
        NSIndexPath *cellIndexPath = [self.tableview indexPathForCell:cell];
        
        if (dependents.count > 0 && _indexPath.row == cellIndexPath.row) {
            
            cell.dependentsButton.hidden = NO;
            
            if (dependents.count == 1)
                [cell.dependentsButton setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long)dependents.count, NSLocalizedString(@"Dependent", @"Dependent")] forState:UIControlStateNormal];
            else
                [cell.dependentsButton setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long)dependents.count, NSLocalizedString(@"Dependents", @"Dependents")] forState:UIControlStateNormal];
        }
    }];
}


- (void)dependentsButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"UserDependentsSegue" sender:sender];
}


#pragma mark --

- (void)resetSearchResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchBar.text = @"";
        [self cancelSearch];
    });
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self performSearchForString:searchText withResultCountUpdateBlock:^(id sender, int numberOfItemsFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (searchBar.text.length == 0)
                {
                    [self resetSearchResult];
                }
            });
        }];
    }
    else
    {
        [self resetSearchResult];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self resetSearchResult];
}

- (NSArray*)connectionsInSection:(NSString*)section
{
    NSArray *connections = nil;
    connections = self.groupOfconnections[section];
    return connections;
}

- (NSArray*)connectionSections
{
    return [[self.groupOfconnections allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
        return [key1 compare:key2];
    }];
}

- (void)updateConnectionGroupWithConnections:(NSArray*)connections
{
    if (self.groupOfconnections == nil)
    {
        self.groupOfconnections = [@{} mutableCopy];
    }
    NSMutableDictionary *connectionGroup = [self.groupOfconnections mutableCopy];
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
    self.groupOfconnections = [NSDictionary dictionaryWithDictionary:connectionGroup];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
}

- (void)reloadDataConnections
{
    [self.view showProgressHUD];
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
            [self.view hideProgressHUD];
        });
    }];
}

- (void)performSearchForString:(NSString*)searchString withResultCountUpdateBlock:(GIConnectionsSearchResultCountUpdateBlock)resultBlock
{
    if ([searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
            NSMutableArray *filteredConnections = [@[] mutableCopy];
            [[self.groupOfconnections allValues] enumerateObjectsUsingBlock:^(NSArray *aGroupOfConnections, NSUInteger idx, BOOL *stop) {
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
        [self reloadDataConnections];
    }
}

- (void)cancelSearch
{
    [self reloadDataConnections];
}

@end
