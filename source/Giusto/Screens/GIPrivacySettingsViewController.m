//
//  GIPrivacySettingsViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/17/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIPrivacySettingsViewController.h"

// Sections
#define kProfilePrivacy         0
#define kDependentsPrivacy      1

@interface GIPrivacySettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSIndexPath *profileSelection;
@property (nonatomic, strong) NSIndexPath *dependentSelection;

@end

@implementation GIPrivacySettingsViewController

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender
{
    self.userSettings.profilePrivacy = [NSNumber numberWithUnsignedInteger:self.profileSelection.row];
    //self.userSettings.dependentPrivacy = self.dependentSelection.row;
    
    [self.userSettings.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [UIAlertView showWithTitle:@"Save Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:NULL];
        }
    }];
    
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // If there is no settings object, create one
    if (!self.userSettings || !self.userSettings.parseObject) {
        NSLog(@"No user settings set for this user.");
        
        [self.view showProgressHUD];
        
        [[GIUserSettingsStore sharedStore] createUserSettingsWithUser:[GIUserStore sharedStore].currentUser completion:^(id sender,  BOOL success, NSError *error, id result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    self.userSettings = [GIUserStore sharedStore].currentUser.userSettings;
                    // THEN configure the datasource
                    [self configureViews];
                    [self configureDatasource];
                }
                else {
                    [UIAlertView showWithTitle:@"Settings Creation Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:NULL];
                    [self.navigationController popViewControllerAnimated:YES];
                }

                [self.view hideProgressHUD];
            });

        }];
    }
    else {
        [self configureViews];
        [self configureDatasource];
    }
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.sections objectAtIndex:section] count];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PrivacySettingsTableHeaderView"];
    
    [self configureHeader:headerView inSection:section];

    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrivacySettingsTableViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSIndexPath *previousIndexPath;
    
    switch (indexPath.section) {
        case kProfilePrivacy:
            if (indexPath.row == self.profileSelection.row) {
                return;
            }
            previousIndexPath = self.profileSelection;
            self.profileSelection = indexPath;
            [tableView reloadRowsAtIndexPaths:@[previousIndexPath, self.profileSelection] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case kDependentsPrivacy:
            if (indexPath.row == self.dependentSelection.row) {
                return;
            }
            previousIndexPath = self.dependentSelection;
            self.dependentSelection = indexPath;
            [tableView reloadRowsAtIndexPaths:@[previousIndexPath, self.dependentSelection] withRowAnimation:UITableViewRowAnimationNone];
            break;
        default:
            break;
    }
}


#pragma mark - Private Methods

- (void)configureViews
{
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableview registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"PrivacySettingsTableHeaderView"];
}


- (void)configureDatasource
{
    self.sections = @[@[NSLocalizedString(@"Everyone", @"Everyone"), NSLocalizedString(@"Friends of friends", @"Friends of friends"), NSLocalizedString(@"By email only", @"By email only")], @[NSLocalizedString(@"Your dependents' names and profiles are only visible by your buds", @"Your dependents' names and profiles are only visible by your buds")]];
    
    self.profileSelection = [NSIndexPath indexPathForRow:self.userSettings.profilePrivacy.unsignedIntegerValue inSection:kProfilePrivacy];
    self.dependentSelection = [NSIndexPath indexPathForRow:self.userSettings.dependentPrivacy.unsignedIntegerValue inSection:kDependentsPrivacy];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    switch (indexPath.section) {
        case kProfilePrivacy:
            if (indexPath.row == self.profileSelection.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case kDependentsPrivacy:
            if (/*indexPath.row == self.dependentSelection.row*/NO) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        default:
            break;
    }
}


- (void)configureHeader:(UITableViewHeaderFooterView *)headerView inSection:(NSInteger)section
{
    NSString *headerLabelString = nil;
    
    switch (section) {
        case kProfilePrivacy:
            headerLabelString = NSLocalizedString(@"Who can find my profile?", @"Who can find my profile?");
            break;
        case kDependentsPrivacy:
            headerLabelString = NSLocalizedString(@"Who can see all my dependents?", @"Who can see all my dependents?");
            break;
        default:
            break;
    }
    
    headerView.textLabel.text = headerLabelString;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
