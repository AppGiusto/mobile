//
//  GIUserDependentsTableViewController.m
//  Giusto
//
//  Created by John Gabelmann on 10/21/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIUserDependentsTableViewController.h"
#import "GIUserProfileTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIUserDependentsTableViewController ()

@property (nonatomic, strong) NSArray *userDependents;

@end

@implementation GIUserDependentsTableViewController

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender
{
    // This button may not be necessary?
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GIUserProfileTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserProfileCell"];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureDatasource];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.userDependents.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIUserProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserProfileCell" forIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    
    // Configure the cell...
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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GIUserProfile *selectedProfile = [self.userDependents objectAtIndex:indexPath.row];
    
    if (self.userProfiles) {
        
        BOOL inCurrentTable = [[self.userProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]] count];
        
        if (inCurrentTable) {
            
            NSArray *filteredProfiles = [self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]];
            
            if (filteredProfiles.count > 0) {
                [self.removedProfiles removeObject:filteredProfiles.firstObject];
            }
            else
            {
                [self.removedProfiles addObject:selectedProfile];
            }
        }
        else
        {
            BOOL alreadyAdded = [[self.addedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]] count];
            
            if (alreadyAdded) {
                NSArray *filteredProfiles = [self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]];
                
                if (filteredProfiles.count > 0) {
                    [self.removedProfiles removeObject:filteredProfiles.firstObject];
                }
                else {
                    [self.removedProfiles addObject:selectedProfile];
                }
            }
            else
            {
                [self.addedProfiles addObject:selectedProfile];
                
                NSArray *mergedProfiles = [self.addedProfiles arrayByAddingObjectsFromArray:self.userProfiles];
                NSArray *guardianProfiles = [mergedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", self.selectedUserProfile.parseObject.objectId]];
                
                if (guardianProfiles.count == 0) {
                    // Dependents cannot be part of a table without their guardian
                    [self.addedProfiles addObject:self.selectedUserProfile];
                }
            }
        }
    }
    else
    {
        NSArray *filteredProfiles = [self.selectedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", selectedProfile.parseObject.objectId]];
        
        if (filteredProfiles.count > 0) {
            [self.selectedProfiles removeObject:filteredProfiles.firstObject];
        }
        else
        {
            [self.selectedProfiles addObject:selectedProfile];
            
            NSArray *guardianProfiles = [self.selectedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", self.selectedUser.userProfile.parseObject.objectId]];
            
            if (guardianProfiles.count == 0) {
                // Dependents cannot be part of a table without their guardian
                [self.selectedProfiles addObject:self.selectedUser.userProfile];
            }
        }
    }

    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Private Methods

- (void)configureDatasource
{
    if (!self.selectedUser) {
        [self.selectedUserProfile userWithCompletion:^(id sender, BOOL success, NSError *error, GIUser *result) {
            self.selectedUser = result;
            
            [self.selectedUser dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
                self.userDependents = dependents;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }];
        }];
    }
    else
    {
        [self.selectedUser dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
            self.userDependents = dependents;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}


- (void)configureCell:(GIUserProfileTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GIUserProfile *userProfile = [self.userDependents objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = userProfile.fullName;
    
    [cell.profilePhoto setImageWithURL:userProfile.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    
    if (self.userProfiles) {
        
        BOOL inCurrentTable = [[self.userProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]] count];
        
        if (inCurrentTable) {
            
            NSArray *filteredProfiles = [self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]];
            
            if (filteredProfiles.count > 0) {
                cell.selectedButton.selected = NO;
            }
            else
            {
                cell.selectedButton.selected = YES;
            }
        }
        else
        {
            BOOL alreadyAdded = [[self.addedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]] count];
            
            if (alreadyAdded) {
                NSArray *filteredProfiles = [self.removedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]];
                
                if (filteredProfiles.count > 0) {
                    cell.selectedButton.selected = NO;
                }
                else
                {
                    cell.selectedButton.selected = YES;
                }
            }
            else
            {
                cell.selectedButton.selected = NO;
            }
        }
    }
    else
    {
        if ([self.selectedProfiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.parseObject.objectId == %@", userProfile.parseObject.objectId]].count > 0) {
            cell.selectedButton.selected = YES;
        }
        else
        {
            cell.selectedButton.selected = NO;
        }
    }
    

}

@end
