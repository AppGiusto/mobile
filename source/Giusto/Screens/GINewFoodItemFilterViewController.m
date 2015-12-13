//
//  GINewFoodItemFilterViewController.m
//  Giusto
//
//  Created by Mark Dubouzet on 10/16/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIFoodItemFilterTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GIFoodItemTableViewCell.h"
#import "GINewFoodItemFilterViewController.h"
#import "GINewFoodItemViewController.h"
#import "GINewFoodItemAdditionCellButton.h"


#define CELL_TAG 199
#define BLOCKER_TAG 101
#define FILTERED_TABLE_TAG 102

typedef enum {
    FilterFoodIngredientsEnum,
    FilterFoodDishesEnum,
    FilterDrinksEnum
} FilterFoodEnum;

@interface GINewFoodItemFilterViewController ()< UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    UILabel *_foodCountLabel;
    UIView *_roundCountView;
    UIBarButtonItem *_confirmButton;
}

@property (nonatomic, weak) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *foodItems;
@property (nonatomic, strong) NSArray *foodItemTypes;
@property (nonatomic, strong) NSArray *profilefoodItems;
@property (weak, nonatomic) IBOutlet UISearchBar *foodSearchBar;
@property (nonatomic, strong) IBOutlet UITableView * filteredResultsTable;
@property (nonatomic, strong) GIFoodItemType *selectedFoodItemType;

@end

@implementation GINewFoodItemFilterViewController

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableview setScrollEnabled:NO];
    
    // Configure Custom Views
    [self configureCustomViews];
    
    // Get Ingredients
    [[GIFoodItemTypeStore sharedStore] getFoodItemsTypesWithCompletion:
     ^(id sender, BOOL success, NSError *error, NSArray *result) {
         self.foodItemTypes = result;
         
         // Get Profile Food Items
         [self preConfigureDataSource];
         
     } ];
    
    // add keyboard notification to adjust search table height for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)cancelButtonPressed:(id)sender
{
    [self.delegate refreshProfileDataSource];
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

-(void) confirmHandler:(id)sender
{
//    NSLog(@"confirmHandler");
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == FILTERED_TABLE_TAG) {
        return [self.foodItems count];
    }
    return [self.foodItemTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == FILTERED_TABLE_TAG) {
        GIFoodItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilteredCell"];
        [self configureFilteredCell:cell atIndexPath:indexPath];
        return cell;
    }else{
        GIFoodItemFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodItemFilterTableViewCell" forIndexPath:indexPath];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Adjust Cell Height based on phone size
    if (tableView.tag == FILTERED_TABLE_TAG) {
        return 68;
    }
    return self.tableview.frame.size.height/3;
}

#pragma mark - UITableview Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == FILTERED_TABLE_TAG) {
        //TODO:  Add actions for selected filtered items
        [self.delegate refreshProfileDataSource];
    }else{
        
        NSString *foodTypeString;
        switch (indexPath.row) {
            case FilterFoodIngredientsEnum:
                foodTypeString =@"Ingredients";
                break;
            case FilterFoodDishesEnum:
                foodTypeString =@"Dishes";
                break;
            case FilterDrinksEnum:
                foodTypeString =@"Drinks";
                break;
            default:
                break;
        }
        
        for (int i = 0; i < [self.foodItemTypes count]; i++) {
            if ([foodTypeString isEqualToString:[(GIFoodItemType* )[self.foodItemTypes objectAtIndex:i] name] ]) {
                self.selectedFoodItemType =(GIFoodItemType* )[self.foodItemTypes objectAtIndex:i];
            }
        }
        
        // Segue
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"NewFoodItemPushSegue" sender:self];
    }
}

#pragma mark - Segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewFoodItemPushSegue"]) {
        GINewFoodItemViewController *destination = segue.destinationViewController;
        destination.foodItemCategory = self.foodItemCategory;
        destination.userProfile = self.userProfile;
        destination.delegate = self.delegate;
        destination.foodItemType = self.selectedFoodItemType;
//        NSLog(@"selectedFoodItemType: %@", self.selectedFoodItemType.name);
    }
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    NSLog(@"called when text starts editing");
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
    [self configureDatasourceForPhrase:self.foodSearchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    NSLog(@"called when keyboard search button pressed");
    [self configureDatasourceForPhrase:self.foodSearchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
//    NSLog(@"called when cancel button pressed");
    [self dismissFilterSearch];
}

#pragma mark - Filtered Results Methods

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
            self.navigationItem.rightBarButtonItem = _confirmButton;
        }
    }else{
        // Remove TableView
        [self.filteredResultsTable setHidden:YES];
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - Private Methods

-(void)preConfigureDataSource
{
    [self configureProfileData:^(NSArray *foodItemsArr)
    {
        [self.view hideProgressHUD];
        
        // UserProfile FoodItems 
        self.profilefoodItems = foodItemsArr;
        if ([foodItemsArr count] > 0) {
            [_roundCountView setHidden:NO];
            [_foodCountLabel setText: [NSString stringWithFormat:@"%lu", (unsigned long)[foodItemsArr count]]];
        }else{
            [_roundCountView setHidden:YES];
        }
        
        [self.tableview reloadData];
        [self.filteredResultsTable reloadData];
    }];
}

-(void)configureProfileData:(void(^)(NSArray* array)) block
{
    switch (self.foodItemCategory) {
        case GIFoodItemCategoryLikes:
        {
            [self.userProfile likedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *likes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(likes);
                });
            }];
        }
            break;
        case GIFoodItemCategoryDislikes:
        {
            [self.userProfile dislikedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dislikes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(dislikes);
                });
            }];
        }
            break;
        case GIFoodItemCategoryCannotHaves:
        {
            [self.userProfile cannotHaveFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *cannotHaves) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(cannotHaves);
                });
            }];
        }
            break;
        default:
            break;
    }
}

- (void)configureDatasourceForPhrase:(NSString*)phrase
{
    self.foodItems = [NSArray array];
    [[GIFoodItemStore sharedStore] getFoodItemsForSearchPhrase:phrase andType:nil withCompletion:^(id sender, BOOL success, NSError *error, NSArray *result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.foodItems = result;
                [self.filteredResultsTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            if(error){
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
            }
        });
    }];
}

- (void)configureCell:(GIFoodItemFilterTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //TODO: get right cell font style "Effra Medium"
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:22]];
    
    // Image Dimensios are taken from the size of the actual image
    switch (indexPath.row) {
        case FilterFoodIngredientsEnum:
        {
            [[cell textLabel] setText:@"Ingredients"];
            [self adjustCellImage:cell forImageName:@"FilteredFoodIngredients" andImageWidth:400 andImageHeight:267];
        }
            break;
        case FilterFoodDishesEnum:
        {
            [[cell textLabel] setText:@"Dishes"];
            // center background image
            [self adjustCellImage:cell forImageName:@"FilteredFoodDishes" andImageWidth:400 andImageHeight:267];
        }
            break;
        case FilterDrinksEnum:
        {
            [[cell textLabel] setText:@"Drinks"];
            // center background image
            [self adjustCellImage:cell forImageName:@"FilteredFoodDrinks" andImageWidth:384 andImageHeight:240];
        }
            break;
        default:
            break;
    }
}

- (void)configureFilteredCell:(GIFoodItemTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItem *foodItem = [self.foodItems objectAtIndex:indexPath.row];
    
    float btnSize = 24;
    
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
    
    CGRect btnFrame = CGRectMake(self.view.frame.size.width - (btnSize+10) , (68 - 24)/2, btnSize, btnSize);
    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnSize, btnSize)];
    
    if (alreadySelected) {
        accessoryButton.deletionMode = YES;
        [btnImageView setImage:[UIImage imageNamed:@"AddedDislikedFoodItem"]]; //Cannot have FoodItem
    }else{
        accessoryButton.deletionMode = NO;
        [btnImageView setImage:[UIImage imageNamed:@"AddFoodItem"]];
    }
    
    [accessoryButton addSubview:btnImageView];
    [accessoryButton addTarget:self action:@selector(addItemButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    accessoryButton.tag = 411;
    [accessoryButton setFrame:btnFrame];
    
    // Remove Cell if added
    if ([[cell.contentView viewWithTag:411] superview]) {
        [(GINewFoodItemAdditionCellButton*)[cell.contentView viewWithTag:411] removeTarget:self action:@selector(addItemButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [[cell.contentView viewWithTag:411] removeFromSuperview];
    }// Add Cell
    [cell.contentView addSubview:accessoryButton];
    
    // Cell title
    cell.itemTitleLabel.text = foodItem.name;
    
    // Cell Photo
    NSString *photoURL = [NSString stringWithFormat:@"http://%@",foodItem.photoURL];
    [cell.itemImageView setFrame:CGRectMake(15, 12, 48, 48)];
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
}

-(void)configureCustomViews
{
    // filteredResultsTable
    CGRect filteredTableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.filteredResultsTable setFrame:filteredTableFrame];
    [self.filteredResultsTable setTag:FILTERED_TABLE_TAG];
    [self.filteredResultsTable setHidden:YES];
    
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
    _confirmButton = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void) addItemButtonHandler:(GINewFoodItemAdditionCellButton*)sender
{
    NSLog(@"food Name: %@", sender.foodItem.name);
    [self.view showProgressHUD];
    if (sender.deletionMode ) {
        [[GIFoodItemStore sharedStore] removeFoodItem:sender.foodItem FromProfile:self.userProfile category:self.foodItemCategory completion:^(id sender, BOOL success, NSError *error, id result) {
            [self.delegate refreshProfileDataSource];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self preConfigureDataSource];
            });
        }];
    }else {
        
        [[GIFoodItemStore sharedStore] addFoodItem:sender.foodItem toProfile:self.userProfile itemCategory:self.foodItemCategory completion:^(id sender, BOOL success, NSError *error, id result) {
            [self.delegate refreshProfileDataSource];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self preConfigureDataSource];
            });
        }];
    }
}

- (void)adjustCellImage:(GIFoodItemFilterTableViewCell*)cell forImageName:(NSString*)imgName andImageWidth:(float)imgWidth andImageHeight:(float)imgHeight
{
    // center background image
    
    // Expands image if cell width is larger than the image
    float adjustedRatio = (1-(imgWidth/cell.frame.size.width))* cell.frame.size.height;
    float adjustedWidth = (imgWidth > cell.frame.size.width)? imgWidth:cell.frame.size.width;
    float adjustedHeight = (imgWidth > cell.frame.size.width)?imgHeight: (imgHeight + adjustedRatio);
    
    // Adjust x y placement based on cell size
    float adjustedXpos = [self positioForCellMeasurement:cell.frame.size.width andImageMeasurement:adjustedWidth];
    float adjustedYpos = [self positioForCellMeasurement:cell.frame.size.height andImageMeasurement:adjustedHeight];
    
    // Create bgImgView
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(adjustedXpos, adjustedYpos, adjustedWidth, adjustedHeight)];
    bgImgView.backgroundColor = [UIColor clearColor];
    bgImgView.opaque = NO;
    bgImgView.image = [UIImage imageNamed: imgName];
    bgImgView.tag = CELL_TAG;
    
    // Mask
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.frame = cell.bounds;
    layer.fillColor = [[UIColor blackColor] CGColor];
    layer.path = CGPathCreateWithRect(CGRectMake(adjustedXpos*-1, adjustedYpos*-1, cell.frame.size.width, cell.frame.size.height ), NULL);
    bgImgView.layer.mask = layer;
    
    // precaution
    if ([[cell.contentView viewWithTag:CELL_TAG] superview]) {
        [[cell.contentView viewWithTag:CELL_TAG] removeFromSuperview];
    }
    
    // Insert bgImgView, this prevents the background image from compressing
    [cell.contentView  insertSubview:bgImgView atIndex:0];
}

- (float)positioForCellMeasurement:(float)cellMeasurement andImageMeasurement:(float)imgMeasurement
{
    return (cellMeasurement - imgMeasurement)/2;
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
