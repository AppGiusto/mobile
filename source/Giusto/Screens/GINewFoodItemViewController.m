//
//  GINewFoodItemViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/24/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GINewFoodItemViewController.h"
#import "GIFoodItemTableViewCell.h"
#import "GINewFoodItemAdditionCellButton.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#define BLOCKER_TAG 103
#define FILTERED_TABLE_TAG 104

typedef NS_ENUM(NSUInteger, GIFoodItemPreference) {
    GIFoodItemPreferenceDislikes,
    GIFoodItemPreferenceLikes,
    GIFoodItemPreferenceUnknown,
};

@interface GINewFoodItemViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    UILabel *_foodCountLabel;
    UIView *_roundCountView;
}

@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *profilefoodItems;
@property (nonatomic, strong) NSArray *likedFoodItems;
@property (nonatomic, strong) NSArray *dislikedFoodItems;
@property (nonatomic, strong) NSArray *foodItems;
@property (nonatomic, strong) NSArray *searchedFoodItems;
@property (weak, nonatomic) IBOutlet UISearchBar *foodSearchBar;
@property (nonatomic, strong) IBOutlet UITableView * filteredResultsTable;

@end

@implementation GINewFoodItemViewController

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure Custom Views
    [self configureCustomViews];
    
    // Get Profile Food Items
    [self preConfigureDataSource];
    
    // add keyboard notification to adjust search table height for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate refreshProfileDataSource];
}

-(void) confirmHandler:(id)sender
{
//    NSLog(@"confirmHandler");
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == FILTERED_TABLE_TAG) {
        return [self.searchedFoodItems count];
    }
    return self.foodItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodItemTableViewCell" forIndexPath:indexPath];
    if (tableView.tag == FILTERED_TABLE_TAG) {
        [self configureCell:cell atIndexPath:indexPath forSearch:YES];
    }else{
        [self configureCell:cell atIndexPath:indexPath forSearch:NO];
    }
    return cell;
}

#pragma mark - UITableview Delegate Methods

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath: %ld",(long)indexPath.row);
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

#pragma mark - Private Methods

-(void)preConfigureDataSource
{
    [self configureProfileData:^(NSArray *foodItemsArr){
        dispatch_async(dispatch_get_main_queue(), ^{
            // UserProfile FoodItems 
            self.profilefoodItems = foodItemsArr;
            if ([foodItemsArr count] > 0) {
                [_roundCountView setHidden:NO];
                [_foodCountLabel setText: [NSString stringWithFormat:@"%lu", (unsigned long)[foodItemsArr count]]];
            }else{
                [_roundCountView setHidden:YES];
            }
            
            [self configureViews];
            [self configureDatasource];
            [self configureDatasourceForPhrase];
            [self.view hideProgressHUD];
        });
    }];
}

-(void)configureProfileData:(void(^)(NSArray* array)) block
{
    if (self.foodItemCategory == GIFoodItemCategoryCannotHaves)
    {
        [self.userProfile cannotHaveFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *cannotHaves) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(cannotHaves);
            });
        }];
    }
    else
    {
        [self.userProfile likedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *likes) {
            
            [self.userProfile dislikedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dislikes) {
                NSMutableArray *likedAndDislikedFoodItems = [@[] mutableCopy];

                self.dislikedFoodItems = [NSArray arrayWithArray:dislikes];
                [likedAndDislikedFoodItems addObjectsFromArray:dislikes];
                
                self.likedFoodItems = [NSArray arrayWithArray:likes];
                [likedAndDislikedFoodItems addObjectsFromArray:likes];
                
                
                [likedAndDislikedFoodItems sortUsingComparator:^NSComparisonResult(GIFoodItem *foodItem1, GIFoodItem *foodItem2) {
                    return [[foodItem1 name] compare:[foodItem2 name]];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    block([NSArray arrayWithArray:likedAndDislikedFoodItems]);
                });
            }];
        }];
    }
}

- (void)configureDatasource
{
    self.foodItems = [NSArray array];
    [[GIFoodItemStore sharedStore] getFoodItemsForType:self.foodItemType withCompletion:^(id sender, BOOL success, NSError *error, NSArray *result) {
        self.foodItems = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }];
}

- (void)configureDatasourceForPhrase
{
    self.searchedFoodItems = [NSArray array];
    [[GIFoodItemStore sharedStore] getFoodItemsForSearchPhrase:self.foodSearchBar.text andType:self.foodItemType.name withCompletion:^(id sender, BOOL success, NSError *error, NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.searchedFoodItems = result;
                [self.filteredResultsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if(error){
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
            }
        });
    }];
}

- (void)configureViews
{
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)configureCustomViews
{
    // filteredResultsTable
    CGRect filteredTableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.filteredResultsTable setFrame:filteredTableFrame];
    [self.filteredResultsTable setTag:FILTERED_TABLE_TAG];
    [self.filteredResultsTable setHidden:YES];
    
    // Right Confrim Button
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"NewFoodConfirmCheck"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(confirmHandler:)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    
    // Label
    _foodCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    [_foodCountLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:10]];
    [_foodCountLabel setTextColor:[UIColor colorWithRed:.949 green:.4745 blue:.2235 alpha:1]];
    
    [_foodCountLabel setTextAlignment:NSTextAlignmentCenter];
    _foodCountLabel.adjustsFontSizeToFitWidth = YES;
    [_foodCountLabel setMinimumScaleFactor:0];
    
    // RoundedView
    _roundCountView = [[UIView alloc] initWithFrame:CGRectMake(28, -2, 15, 15)];
    _roundCountView.clipsToBounds = YES;
    [_roundCountView setBackgroundColor:[UIColor whiteColor]];
    [self setRoundedView:_roundCountView toDiameter:15];
    
    [_roundCountView addSubview:_foodCountLabel];
    [button addSubview:_roundCountView];
    UIBarButtonItem *confirmButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = confirmButton;
}

- (void)configureCell:(GIFoodItemTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forSearch:(BOOL)forSearch
{
     GIFoodItem *foodItem;
    if (forSearch) {
        foodItem = [self.searchedFoodItems objectAtIndex:indexPath.row];
    }else{
        foodItem = [self.foodItems objectAtIndex:indexPath.row];
    }
    
    float btnSize = 24;
    
    if (self.foodItemCategory == GIFoodItemCategoryCannotHaves)
    {
        // Check for selection
        BOOL alreadySelected = NO;
        for (int i =0;  i < [self.profilefoodItems count]; i++) {
            if ([[(GIFoodItem*)[self.profilefoodItems objectAtIndex:i] name] isEqualToString:foodItem.name]) {
                alreadySelected = YES;
                break;
            }
        }
        
        // Custom AccessoryButton
        GINewFoodItemAdditionCellButton *accessoryButton = [GINewFoodItemAdditionCellButton new];
        accessoryButton.foodItem = foodItem;
        accessoryButton.category = GIFoodItemCategoryCannotHaves;
        
        CGRect btnFrame = CGRectMake(cell.contentView.frame.size.width - (btnSize+10) , (68 - 24)/2, btnSize, btnSize);
        UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
        
        if (alreadySelected) {
            accessoryButton.deletionMode = YES;
            [btnImageView setImage:[UIImage imageNamed:@"AddedDislikedFoodItem"]]; //Cannot have FoodItem
        }else{
            accessoryButton.deletionMode = NO;
            [btnImageView setImage:[UIImage imageNamed:@"AddFoodItem"]];
        }
        
        [accessoryButton addSubview:btnImageView];
        [accessoryButton addTarget:self action:@selector(foodItemPreferencesHandleAction:) forControlEvents:UIControlEventTouchUpInside];
        accessoryButton.tag = 411;
        [accessoryButton setFrame:btnFrame];
        
        // Remove Cell if added
        if ([[cell.contentView viewWithTag:411] superview]) {
            [(GINewFoodItemAdditionCellButton*)[cell.contentView viewWithTag:411] removeTarget:self action:@selector(foodItemPreferencesHandleAction:) forControlEvents:UIControlEventTouchUpInside];
            [[cell.contentView viewWithTag:411] removeFromSuperview];
        }// Add Cell
        [cell.contentView addSubview:accessoryButton];
        CGRect itemRect = cell.itemImageView.frame;
        itemRect.origin.x = 8;
        
        if (forSearch)
        {
            itemRect.origin.y = cell.bounds.size.height/2 - itemRect.size.height/2;
        }
        cell.itemImageView.frame = itemRect;
    }
    else
    {
        
        // Check for selection
        GIFoodItemPreference foodItemPreference = GIFoodItemPreferenceUnknown;
        
        if ([self.likedFoodItems containsObject:foodItem])
        {
            foodItemPreference = GIFoodItemPreferenceLikes;
        }
        else if ([self.dislikedFoodItems containsObject:foodItem])
        {
            foodItemPreference = GIFoodItemPreferenceDislikes;
        }
        
        // Custom AccessoryButton
        GINewFoodItemAdditionCellButton *addLikeAccessoryButton = [GINewFoodItemAdditionCellButton new];
        addLikeAccessoryButton.foodItem = foodItem;
        addLikeAccessoryButton.category = GIFoodItemCategoryLikes;
        
        CGRect btnFrame = CGRectMake(cell.contentView.frame.size.width - (btnSize+10) , (68 - 24)/2, btnSize, btnSize);
        UIImageView* likesBtnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
        [likesBtnImageView setImage:[UIImage imageNamed:@"AddLikedFoodItem"]];
        [addLikeAccessoryButton addSubview:likesBtnImageView];
        [addLikeAccessoryButton addTarget:self action:@selector(foodItemPreferencesHandleAction:) forControlEvents:UIControlEventTouchUpInside];
        addLikeAccessoryButton.tag = 411;
        [addLikeAccessoryButton setFrame:btnFrame];
        addLikeAccessoryButton.deletionMode = NO;
        
        GINewFoodItemAdditionCellButton *addDislikeAccessoryButton = [GINewFoodItemAdditionCellButton new];
        addDislikeAccessoryButton.foodItem = foodItem;
        addDislikeAccessoryButton.category = GIFoodItemCategoryDislikes;
        
        btnFrame = CGRectMake(cell.contentView.frame.origin.x + 8 , (68 - 24)/2, btnSize, btnSize);
        UIImageView *dislikesBtnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
        [dislikesBtnImageView setImage:[UIImage imageNamed:@"AddDislikedFoodItem"]];
        [addDislikeAccessoryButton addSubview:dislikesBtnImageView];
        [addDislikeAccessoryButton addTarget:self action:@selector(foodItemPreferencesHandleAction:) forControlEvents:UIControlEventTouchUpInside];
        addDislikeAccessoryButton.tag = 412;
        [addDislikeAccessoryButton setFrame:btnFrame];
        addDislikeAccessoryButton.deletionMode = NO;
        
        // update state
        if (foodItemPreference == GIFoodItemPreferenceLikes)
        {
            addLikeAccessoryButton.deletionMode = YES;
            [likesBtnImageView setImage:[UIImage imageNamed:@"AddedLikedFoodItem"]];
            addDislikeAccessoryButton.hidden = YES;
        }
        else if (foodItemPreference == GIFoodItemPreferenceDislikes)
        {
            addLikeAccessoryButton.hidden = YES;
            addDislikeAccessoryButton.deletionMode = YES;
            [dislikesBtnImageView setImage:[UIImage imageNamed:@"AddedFoodItem"]]; //Disliked FoodItem
        }
    
        // Remove Cell if added
        if ([[cell.contentView viewWithTag:411] superview]) {
            [(GINewFoodItemAdditionCellButton*)[cell.contentView viewWithTag:411] removeTarget:self action:@selector(foodItemPreferencesHandleAction:) forControlEvents:UIControlEventTouchUpInside];
            [[cell.contentView viewWithTag:411] removeFromSuperview];
        }// Add Cell
        [cell.contentView addSubview:addLikeAccessoryButton];
        
        // Remove Cell if added
        if ([[cell.contentView viewWithTag:412] superview]) {
            [(GINewFoodItemAdditionCellButton*)[cell.contentView viewWithTag:412] removeTarget:self action:@selector(foodItemPreferencesHandleAction:) forControlEvents:UIControlEventTouchUpInside];
            [[cell.contentView viewWithTag:412] removeFromSuperview];
        }// Add Cell
        [cell.contentView addSubview:addDislikeAccessoryButton];
        
        CGRect itemRect = cell.itemImageView.frame;
        itemRect.origin.x = 40;
        if (forSearch)
        {
            itemRect.origin.y = cell.bounds.size.height/2 - itemRect.size.height/2;
        }
        cell.itemImageView.frame = itemRect;
    }
    
    // Cell Title
    cell.itemTitleLabel.text = foodItem.name;
    
    // Cell Image
    [cell.itemImageView setRoundCorners];
    NSString *photoURL = [NSString stringWithFormat:@"http://%@",foodItem.photoURL];
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
}


-(void) foodItemPreferencesHandleAction:(GINewFoodItemAdditionCellButton*)sender
{
    NSLog(@"food Name: %@", sender.foodItem.name);
     [self.view showProgressHUD];
    if (sender.deletionMode ) {
        [[GIFoodItemStore sharedStore] removeFoodItem:sender.foodItem FromProfile:self.userProfile category:sender.category completion:^(id sender, BOOL success, NSError *error, id result) {
            [self.delegate refreshProfileDataSource];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self preConfigureDataSource];
                });
        }];
    }else {
       
        [[GIFoodItemStore sharedStore] addFoodItem:sender.foodItem toProfile:self.userProfile itemCategory:sender.category completion:^(id sender, BOOL success, NSError *error, id result) {
            [self.delegate refreshProfileDataSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self preConfigureDataSource];
            });
        }];
    }
}

- (void)launchFilteredSearch
{
    // Create Blocker View
    CGRect blockFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIControl * blockerControl =[[UIControl alloc] initWithFrame:blockFrame];
    [blockerControl setBackgroundColor:[UIColor blackColor]];
    [blockerControl setAlpha:.5];
    blockerControl.tag = BLOCKER_TAG;
    [blockerControl addTarget:self action:@selector(dismissFilterSearch) forControlEvents:UIControlEventTouchUpInside];
    
    if([[self.view viewWithTag:BLOCKER_TAG] superview])
    {
        [[self.view viewWithTag:BLOCKER_TAG] removeFromSuperview];
    }
    [self.view insertSubview:blockerControl belowSubview:self.filteredResultsTable];
}

- (void) dismissFilterSearch
{
    [self.foodSearchBar resignFirstResponder];
    if([[self.view viewWithTag:BLOCKER_TAG] superview])
    {
        [[self.view viewWithTag:BLOCKER_TAG] removeFromSuperview];
    }
}

- (void) handleDisplayResultsTable
{
    if (self.foodSearchBar.text.length > 0) {
        // Show TableView
        if ([self.filteredResultsTable isHidden]) {
            [self.filteredResultsTable setHidden:NO];
        }
    }else{
        // Remove TableView
        [self.filteredResultsTable setHidden:YES];
    }
}

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    CGSize size = CGSizeMake(30, 30);
    // create context with transparent background
    UIGraphicsBeginImageContextWithOptions(size, NO, 1);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,30,30)
                                cornerRadius:5.0] addClip];
    [[UIColor whiteColor] setFill];
    
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [searchBar setSearchFieldBackgroundImage:image forState:UIControlStateNormal];
    //    NSLog(@"called when text starts editing");
    [self launchFilteredSearch];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    //    NSLog(@"called when text ends editing");
    if (searchBar.text.length == 0) {

        CGSize size = CGSizeMake(30, 30);
        // create context with transparent background
        UIGraphicsBeginImageContextWithOptions(size, NO, 1);
        
        // Add a clip before drawing anything, in the shape of an rounded rect
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0,0,30,30)
                                    cornerRadius:5.0] addClip];
        [GIColorSearchInactiveOrangeColor setFill];
        
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [searchBar setSearchFieldBackgroundImage:image forState:UIControlStateNormal];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    NSLog(@"called when text changes (including clear)");
    [self handleDisplayResultsTable];
    [self configureDatasourceForPhrase];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //    NSLog(@"called when keyboard search button pressed");
    [self configureDatasourceForPhrase];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //    NSLog(@"called when cancel button pressed");
    [self dismissFilterSearch];
}

#pragma mark - keyboard
-(void)keyboardDidShow:(NSNotification*)aNotification{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    float keyBoardHeight = keyboardSize.height;
    CGRect filteredTableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - keyBoardHeight );
    [self.filteredResultsTable setFrame:filteredTableFrame];
}

-(void)keyboardDidHide:(NSNotification*)aNotification{
    NSLog(@"keyboardDidHide");
    CGRect filteredTableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height );
    [self.filteredResultsTable setFrame:filteredTableFrame];
}

@end
