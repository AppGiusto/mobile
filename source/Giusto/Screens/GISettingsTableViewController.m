//
//  GISettingsTableViewController.m
//  Giusto
//
//  Created by Fredrick Gabelmann on 9/15/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIAppDelegate.h"
#import "GISettingsTableViewController.h"
#import "GISplashViewController.h"
#import "GIPrivacySettingsViewController.h"
#import "GINotificationSettingsViewController.h"
#import "Helpshift.h"
#import "GIFindContactsViewController.h"

@interface GISettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GISettingsTableViewController

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)logoutButtonPressed:(id)sender
{
    [[GIUserStore sharedStore] logout];
    [[[UITabBarController profileTabBarController] presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"SettingsTableHeaderView"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        numberOfRows = 2;
    } else if (section == 1) {
        numberOfRows = 3;
    }
    
    return numberOfRows;
}


#pragma mark - UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
    
    return [self configureCell:cell atIndexPath:indexPath];
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SettingsTableHeaderView"];
    
    NSString *headerLabelString = nil;
    
    switch (section) {
        case 0:
            headerLabelString = NSLocalizedString(@"My Account", @"My Account");
            break;
        case 1:
            headerLabelString = NSLocalizedString(@"Information", @"Information");
            break;
        default:
            break;
    }
    
    headerView.textLabel.text = headerLabelString;
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueForIndexPath:indexPath];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"findContactsSegue"]) {
        GIFindContactsViewController* findContactsVC = (GIFindContactsViewController*)segue.destinationViewController;
        findContactsVC.searchType = @"addressBook";
    } else if ([segue.identifier isEqualToString:@"findFacebookFriendsSegue"]) {
        
        GIFindContactsViewController* findContactsVC = (GIFindContactsViewController*)segue.destinationViewController;
        findContactsVC.searchType = @"facebook";
    } else if ([segue.identifier isEqualToString:@"PrivacyPolicySegue"]) {
        GIPrivacySettingsViewController *destination = segue.destinationViewController;
        
        [destination configureWithModelObject:[GIUserStore sharedStore].currentUser.userSettings];
    }
    else if ([segue.identifier isEqualToString:@"NotificationsSettingsSegue"])
    {
        GINotificationSettingsViewController *destination = segue.destinationViewController;
        
        [destination configureWithModelObject:[GIUserStore sharedStore].currentUser.userSettings];
    }
    else if ([segue.identifier isEqualToString:@"HelpAndFeedbacktSegue"])
    {
        
    }
}



#pragma mark - Private Methods

- (UITableViewCell *)configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *cellLabelString = nil;
    
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    cellLabelString = NSLocalizedString(@"Profile", @"Profile");
                    break;
                case 1:
                    cellLabelString = NSLocalizedString(@"Privacy", @"Privacy");
                    break;
                case 2:
                    cellLabelString = NSLocalizedString(@"Notifications", @"Notifications");
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (row) {
                case 0:
                    cellLabelString = NSLocalizedString(@"About Giusto", @"About Giusto");
                    break;
                case 1:
                    cellLabelString = NSLocalizedString(@"Help & Feedback", @"Help & Feedback");
                    break;
                case 2:
                    cellLabelString = NSLocalizedString(@"Legal", @"Legal");
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    aCell.textLabel.text = cellLabelString;
    return aCell;
}


- (void)performSegueForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *segueIdentifier = nil;
    
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    segueIdentifier = @"ProfileSettingsSegue";
                    break;
                case 1:
                    segueIdentifier = @"PrivacyPolicySegue";
                    break;
                case 2:
                    segueIdentifier = @"NotificationsSettingsSegue";
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (row) {
                case 0:
                    segueIdentifier = @"AboutGiustoSegue";
                    break;
                case 1:
                    segueIdentifier = @"HelpAndFeedbacktSegue";
                    break;
                case 2:
                    segueIdentifier = @"LegalPolicySegue";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    if ([segueIdentifier isEqualToString:@"HelpAndFeedbacktSegue"])
    {
        [[Helpshift sharedInstance] showFAQs:self withOptions:nil];
    }
    else
    {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}

@end
