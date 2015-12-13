//
//  GIConnectionDependentsTableViewController.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-24.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionDependentsTableViewController.h"
#import "GIUserProfileTableViewCell.h"
#import "GIUserProfileViewController.h"
#import "GIDependentsViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIConnectionDependentsTableViewController ()
@property (nonatomic,strong) NSArray *dependents;
@end

@implementation GIConnectionDependentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self prepareDataModel];
    self.title = NSLocalizedString(@"Dependents", @"Dependents");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self.navigationController navigationBar] setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)prepareDataModel
{
    if (self.user)
    {
        [self.view showProgressHUD];
        [[[self.user.parseUser relationForKey:@"dependents"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.dependents = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.view hideProgressHUD];
                [self.tableView reloadData];
            });
        }];
    }
}

- (void)configureCell:(GIUserProfileTableViewCell*)cell withUserProfile:(GIUserProfile*)userProfile
{
    cell.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:@"..."
                                                                    attributes:@{NSForegroundColorAttributeName:[UIColor grayColor],
                                                                                 NSFontAttributeName:[UIFont systemFontOfSize:12.0],}];
    cell.profilePhoto.image = [UIImage imageNamed:@"AvatarImagePlaceholder"];
    [cell.profilePhoto setRoundCorners];
    
    [userProfile.parseObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.nameLabel.attributedText = [[NSAttributedString alloc] initWithString:[object objectForKey:@"fullName"]
                                                                            attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                         NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                                                             size:18]
                                                                                         }];
            [cell.profilePhoto setImageWithURL:[NSURL URLWithString:[object objectForKey:@"photoURL"]] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dependents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIUserProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIDependentProfile" forIndexPath:indexPath];
    [self configureCell:cell withUserProfile:[GIUserProfile parseModelWithParseObject:[self.dependents objectAtIndex:indexPath.row]]];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dependents.count > indexPath.row)
    {
        GIUserProfile *userProfile = [GIUserProfile parseModelWithParseObject:[self.dependents objectAtIndex:indexPath.row]];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        GIDependentsViewController *dependentsViewController = [storyboard instantiateViewControllerWithIdentifier:@"GIDependentProfileViewController"];
        dependentsViewController.isReadOnlyMode = YES;
        dependentsViewController.hidesBottomBarWhenPushed = YES;
        dependentsViewController.extendedLayoutIncludesOpaqueBars = YES;
        dependentsViewController.userProfile = userProfile;
        [self.navigationController pushViewController:dependentsViewController animated:YES];
    }
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
