//
//  GINotificationSettingsViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/18/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GINotificationSettingsViewController.h"
#import "GISwitchTableViewCell.h"

// Rows
#define kSentConnectionRequest          0
#define kAcceptedConnectionRequest      1

@interface GINotificationSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, assign) BOOL sentConnectionRequestEnabled;
@property (nonatomic, assign) BOOL acceptedConnectionRequestEnabled;

@end

@implementation GINotificationSettingsViewController

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender
{
    self.userSettings.sentConnectionRequestNotificationsEnabled = self.sentConnectionRequestEnabled;
    self.userSettings.connectionRequestAcceptedNotificationsEnabled = self.acceptedConnectionRequestEnabled;
    
    [self.userSettings.parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [UIAlertView showWithTitle:@"Save Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:NULL];
        }
    }];
}


- (IBAction)notificationSwitchChanged:(UISwitch *)sender
{
    switch (sender.tag) {
        case kSentConnectionRequest:
            self.sentConnectionRequestEnabled = sender.isOn;
            break;
        case kAcceptedConnectionRequest:
            self.acceptedConnectionRequestEnabled = sender.isOn;
            break;
        default:
            break;
    }
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureViews];
    [self configureDatasource];
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex:section] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"NotificationSettingsTableHeaderView"];
    
    [self configureHeader:headerView inSection:section];
    
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GISwitchTableViewCell *cell = (GISwitchTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationSettingsTableViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Private Methods

- (void)configureViews
{
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableview registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"NotificationSettingsTableHeaderView"];
}


- (void)configureDatasource
{
    self.sections = @[@[NSLocalizedString(@"I'm sent a connection request", @"I'm sent a connection request"), NSLocalizedString(@"My connection request is accepted", @"My connection request is accepted")]];
    
    self.sentConnectionRequestEnabled = self.userSettings.sentConnectionRequestNotificationsEnabled;
    self.acceptedConnectionRequestEnabled = self.userSettings.connectionRequestAcceptedNotificationsEnabled;
}


- (void)configureCell:(GISwitchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.switchLabel.text = [[self.sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.cellSwitch.tag = indexPath.row;
    
    switch (indexPath.row) {
        case kSentConnectionRequest:
            [cell.cellSwitch setOn:self.sentConnectionRequestEnabled animated:NO];
            break;
        case kAcceptedConnectionRequest:
            [cell.cellSwitch setOn:self.acceptedConnectionRequestEnabled animated:NO];
            break;
        default:
            break;
    }
}


- (void)configureHeader:(UITableViewHeaderFooterView *)headerView inSection:(NSInteger)section
{
    NSString *headerLabelString = nil;
    
    switch (section) {
        case 0:
            headerLabelString = NSLocalizedString(@"Notify me when...", @"Notify me when...");
            break;
            
        default:
            break;
    }
    
    headerView.contentView.backgroundColor = GIColorTableHeaderTextColor;
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
