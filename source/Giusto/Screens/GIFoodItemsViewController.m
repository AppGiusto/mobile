//
//  GIFoodItemsViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/19/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIFoodItemsViewController.h"
#import "GINewFoodItemViewController.h"
#import "GIFoodItemTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIFoodItemsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSArray *foodItems;

@end

@implementation GIFoodItemsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self configureViews];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.isReadOnlyMode)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    }
    
}

- (void) viewWillDisappear:(BOOL)animated {
    self.tableview.editing = NO;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureDatasource];
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.foodItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodItemTableViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        GIFoodItem *foodItem = [self.foodItems objectAtIndex:indexPath.row];
        
        NSMutableArray *mutableFoodItems = [NSMutableArray arrayWithArray:self.foodItems];
        [mutableFoodItems removeObjectAtIndex:indexPath.row];
        
        self.foodItems = mutableFoodItems;
        
        [self.tableview deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[GIFoodItemStore sharedStore] removeFoodItem:foodItem FromProfile:self.userProfile category:self.foodItemCategory completion:^(id sender, BOOL success, NSError *error, id result) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView showWithTitle:NSLocalizedString(@"Error Deleting Food Item", @"Error Deleting Food Item") message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:NULL];
                    
                    [mutableFoodItems insertObject:foodItem atIndex:indexPath.row];
                    [self.tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }
        }];
    }
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    GINewFoodItemViewController *destination = [[segue.destinationViewController viewControllers] firstObject];
    
    destination.foodItemCategory = self.foodItemCategory;
    [destination configureWithModelObject:self.userProfile];
}


#pragma mark - Private Methods

- (void)configureViews
{
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}


- (void)configureDatasource
{
    if (!self.foodItems) {
        self.foodItems = [NSArray array];
    }
    
    switch (self.foodItemCategory) {
        case GIFoodItemCategoryCannotHaves:
        {
            [self.userProfile cannotHaveFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *foodItems) {
                self.foodItems = foodItems;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }];
            break;
        }
        case GIFoodItemCategoryLikes:
        {
            [self.userProfile likedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *foodItems) {
                self.foodItems = foodItems;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }];
            break;
        }
        case GIFoodItemCategoryDislikes:
        {
            [self.userProfile dislikedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *foodItems) {
                self.foodItems = foodItems;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                });
            }];
            break;
        }
    
        default:
            break;
    }
}


- (void)configureCell:(GIFoodItemTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItem *foodItem = [self.foodItems objectAtIndex:indexPath.row];
    
    cell.itemTitleLabel.text = foodItem.name;
    
    NSString *photoURL = [NSString stringWithFormat:@"http://%@", foodItem.photoURL];
    
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    [cell.itemImageView setRoundCorners];
}

@end
