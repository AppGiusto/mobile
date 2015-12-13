//
//  GIEditTableViewController.m
//  Giusto
//
//  Created by John Gabelmann on 10/23/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIEditTableViewController.h"
#import "GIUserProfileTableViewCell.h"
#import "GIUserDependentsTableViewController.h"
#import "GIAddNewMembersViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIEditTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UILabel *membersCountLabel;

@property (nonatomic, strong) NSArray *userProfiles;
@property (nonatomic, strong) NSMutableArray *removedProfiles;
@property (nonatomic, strong) NSMutableArray *addedProfiles;
@property (nonatomic, strong) NSArray *mergedProfiles;
@property (nonatomic, strong) NSArray *filteredProfiles;

@end

@implementation GIEditTableViewController

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)saveButtonPressed:(id)sender
{
    if (self.nameField.text.length) {
        
        NSMutableArray *filteredAdded = [NSMutableArray array];
        NSMutableArray *filteredRemoved = [NSMutableArray array];
        
        for (GIUserProfile *userProfile in self.addedProfiles) {
            if (![[self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]] count]) {
                [filteredAdded addObject:userProfile];
            }
        }
        
        for (GIUserProfile *userProfile in self.removedProfiles) {
            if ([[self.userProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]] count]) {
                [filteredRemoved addObject:userProfile];
            }
        }
        
        [[GITableStore sharedStore] saveTable:self.table name:self.nameField.text withAddedProfiles:filteredAdded andRemovedProfiles:filteredRemoved completion:^(id sender, BOOL success, NSError *error, id result) {
            if (success) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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


- (IBAction)deleteButtonPressed:(id)sender
{
    [UIAlertView showWithTitle:NSLocalizedString(@"Delete Table", @"Delete Table") message:NSLocalizedString(@"Are you sure you want to delete this table?", @"Are you sure you want to delete this table?") cancelButtonTitle:NSLocalizedString(@"No", @"No") otherButtonTitles:@[NSLocalizedString(@"Yes, delete", @"Yes, delete")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [[GITableStore sharedStore] deleteTable:self.table completion:^(id sender, BOOL success, NSError *error, id result) {
                if (success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"UnwindToTablesSegue" sender:self];
                    });
                }
                else
                {
                    [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
                }
            }];
        }
    }];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *userProfileNib = [UINib nibWithNibName:@"GIUserProfileTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableview registerNib:userProfileNib forCellReuseIdentifier:@"UserProfileCell"];
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AddMoreCell"];
    
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.userProfiles = [NSArray array];
    self.removedProfiles = [NSMutableArray array];
    self.addedProfiles = [NSMutableArray array];
    self.mergedProfiles = [NSArray array];
    self.filteredProfiles = [NSArray array];
    
    self.nameField.text = self.table.name;
    
    [self configureDatasource];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureViews];
}


- (void)viewDidLayoutSubviews
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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    
    return self.filteredProfiles.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        GIUserProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileCell" forIndexPath:indexPath];
        
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            cell.preservesSuperviewLayoutMargins = NO;
        }
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddMoreCell" forIndexPath:indexPath];
    
    cell.textLabel.text = NSLocalizedString(@"Add new members", @"Add new members");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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


#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        __block GIUserProfile *selectedProfile = [self.filteredProfiles objectAtIndex:indexPath.row];
        
        NSArray *filteredProfiles = [self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]];
        
        if (filteredProfiles.count > 0) {
            [self.removedProfiles removeObject:filteredProfiles.firstObject];
        }
        else
        {
            [self.removedProfiles addObject:selectedProfile];
            
            [selectedProfile dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
                if (dependents.count) {
                    for (GIUserProfile *dependent in dependents) {
                        if ([[self.mergedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", dependent.parseObject.objectId]] count] && ![[self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", dependent.parseObject.objectId]] count]) {
                            
                            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"You cannot remove a user who has dependents in the table, remove them first", @"You cannot remove a user who has dependents in the table, remove them first") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
                            [self.removedProfiles removeObject:selectedProfile];
                            [self configureViews];
                        }
                    }
                }
            }];
        }
        
        [self.tableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self configureViews];
    }
    else
    {
        [self performSegueWithIdentifier:@"AddMembersSegue" sender:tableView];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"AddMembersSegue"]) {
        
        GIAddNewMembersViewController *destination = segue.destinationViewController;
        
        destination.tableProfiles = self.userProfiles;
        destination.addedProfiles = self.addedProfiles;
        destination.removedProfiles = self.removedProfiles;
    }
    else if ([segue.identifier isEqualToString:@"UserDependentsSegue"])
    {
        CGPoint center = [(UIButton *)sender center];
        CGPoint rootViewPoint = [[(UIButton *)sender superview] convertPoint:center toView:self.tableview];
        NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:rootViewPoint];
        
        GIUserProfile *selectedUserProfile = [self.filteredProfiles objectAtIndex:indexPath.row];
        
        GIUserDependentsTableViewController *destination = segue.destinationViewController;
        destination.userProfiles = self.userProfiles;
        destination.addedProfiles = self.addedProfiles;
        destination.removedProfiles = self.removedProfiles;
        destination.selectedUserProfile = selectedUserProfile;
        
        destination.title = [NSString stringWithFormat:@"%@'s %@", selectedUserProfile.fullName, NSLocalizedString(@"Dependents", @"Dependents")];
    }
}



#pragma mark - Private Methods

- (void)configureViews
{
    self.mergedProfiles = [self.addedProfiles arrayByAddingObjectsFromArray:self.userProfiles];
    
    self.filteredProfiles = [self.mergedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.user != nil"]];
    [self.tableview reloadData];
    
    NSInteger memberCount = self.mergedProfiles.count - self.removedProfiles.count;
    
    self.membersCountLabel.text = [NSString stringWithFormat:@"%li %@", (long)memberCount, memberCount > 1 ? NSLocalizedString(@"Members", @"Members") : NSLocalizedString(@"Member", @"Member")];
}


- (void)configureDatasource
{
    [self.table userProfilesWithCompletion:^(id sender, BOOL success, NSError *error, NSArray * userProfiles) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userProfiles = userProfiles;
            
            if ([[self.userProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", [GIUserStore sharedStore].currentUser.userProfile.parseObject.objectId]] count] == 0) {
                // If the current user isn't part of the table, display them anyway as a user they could re-add
                [self.addedProfiles addObject:[GIUserStore sharedStore].currentUser.userProfile];
                [self.removedProfiles addObject:[GIUserStore sharedStore].currentUser.userProfile];
            }
            [self configureViews];
        });

    }];
}


- (void)configureCell:(GIUserProfileTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [cell.dependentsButton addTarget:self action:@selector(dependentsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.dependentsButton.hidden = YES;
    
    GIUserProfile *userProfile = [self.filteredProfiles objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = userProfile.fullName;
    
    [cell.profilePhoto setImageWithURL:userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    
    if ([self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]].count > 0) {
        cell.selectedButton.selected = NO;
    }
    else
    {
        cell.selectedButton.selected = YES;
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

@end
