//
//  GIMembersTableViewController.m
//  Giusto
//
//  Created by Timothy Raveling on 15-05-20.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import "GIMembersTableViewController.h"
#import "GIMembersTableViewCell.h"
#import "GIUserProfileViewController.h"
#import "GIConnectionDependentsTableViewController.h"

#define kCellIdentifier                 @"GIMembersTableViewCell"

@interface GIMembersTableViewController ()
{
    NSMutableArray *keyList;
    NSMutableDictionary *userDictionary; // Letters as keys w/ mutable arrays of users as objects, sorted alphabetically
}

@end

@implementation GIMembersTableViewController

#pragma mark - Public interface

- (void)setUserProfiles:(NSArray*)users
{
    self.userList = [NSArray arrayWithArray:users];
    userDictionary = [NSMutableDictionary new];
    keyList = [NSMutableArray new];
    
    // Set up the index
    NSUInteger index = 0;
    
    // Sort the users into individual alphabet lists
    for (GIUserProfile *user in users) {
        
        // Set index
        user.masterIndex = index;
        
        // Get first char
        NSString *key = [[user.fullName substringToIndex:1] uppercaseString];
        
        // Get array
        NSMutableArray *sublist = [userDictionary objectForKey:key];
        
        // Create it if needed
        if (!sublist ){
            
            // Add key
            [keyList addObject:key];
            
            // Create array
            sublist = [NSMutableArray new];
            
            // Add it to the dict
            [userDictionary setObject:sublist forKey:key];
        }
        
        // Add object to array
        [sublist addObject:user];
        
        // Advance the index
        index ++;
    }
    
    // Sort the index array
    [keyList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    // Sort the sub arrays
    for (NSString *key in keyList) {
        
        // Get the sub array
        NSMutableArray *sublist = [userDictionary objectForKey:key];
        
        // Sort it
        [sublist sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            GIUserProfile *a = (GIUserProfile*)obj1;
            GIUserProfile *b = (GIUserProfile*)obj2;
            
            return [a.fullName compare:b.fullName];
        }];
    }
}

#pragma mark - IBActions

-(IBAction)hitDependents:(id)sender
{
    UIButton *dep_bt = (UIButton*)sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"GIUserConnections" bundle:nil];
    GIConnectionDependentsTableViewController *dvc = [storyboard instantiateViewControllerWithIdentifier:@"GIConnectionDependentsTableViewController"];
    dvc.user = [self.userList objectAtIndex:dep_bt.tag];
    [self.navigationController pushViewController:dvc animated:true];
}

#pragma mark - VC and interface functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.viewTitle;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GIMembersTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [keyList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [keyList objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([keyList count] > 15)
        return keyList;
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [keyList indexOfObject:title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Get the key
    NSString *key = [keyList objectAtIndex:section];
    
    // Get the sublist
    NSMutableArray *sublist = [userDictionary objectForKey:key];

    // Return the number of rows in the section.
    return [sublist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GIMembersTableViewCell *cell = (GIMembersTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    // Get the key
    NSString *key = [keyList objectAtIndex:indexPath.section];
    
    // Get the sublist
    NSMutableArray *sublist = [userDictionary objectForKey:key];
    
    // Get the user
    GIUserProfile *profile = [sublist objectAtIndex:indexPath.row];
    
    // Configure the cell...
    [cell setUser:profile];
    
    // Set tags
    cell.btDependents.tag = profile.masterIndex;
    cell.btCheckbox.tag = profile.masterIndex;
    cell.btCheckbox.alpha = 0.0f;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the key
    NSString *key = [keyList objectAtIndex:indexPath.section];
    
    // Get the sublist
    NSMutableArray *sublist = [userDictionary objectForKey:key];
    
    // Get the user
    GIUserProfile *user = [sublist objectAtIndex:indexPath.row];
    
    // Push profile view
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    GIUserProfileViewController *userProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"GIUserProfileViewController"];
    userProfileViewController.isReadOnlyMode = YES;
    userProfileViewController.hidesBottomBarWhenPushed = YES;
    userProfileViewController.extendedLayoutIncludesOpaqueBars = YES;
    userProfileViewController.userProfile = user;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}


@end
