//
//  GIUserProfileViewController.m
//  Giusto
//
//  Created by Vincil Bishop on 9/3/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GISettingsTableViewController.h"
#import "GIUserProfileViewController.h"
#import "GIProfileAddItemViewController.h"
#import "GIFoodItemsViewController.h"
#import "GIFoodItemCollectionViewCell.h"
#import "GIDependentsViewController.h"
#import "GIAddNewDependentViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <MTDates/NSDate+MTDates.h>

@interface GIUserProfileViewController () <UICollectionViewDataSource, GIUserProfileViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *settingsButton;
@property (nonatomic, weak) IBOutlet UIButton *dependentsButton;
@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet UIButton *dependentAgeButton;
@property (nonatomic, weak) IBOutlet UIButton *addNewItemAndStatusButton;
@property (nonatomic, weak) IBOutlet UILabel *cannotHavesCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *likesCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *dislikesCountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *dependentsUserImageView;
@property (nonatomic, weak) IBOutlet UIButton *viewProfilePictureButton;
@property (nonatomic, weak) IBOutlet UICollectionView *cannotHaveCollectionView;
@property (nonatomic, strong) NSArray *cannotHaves;
@property (nonatomic, assign) BOOL isSmallScreen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintSpace;

@end

@implementation GIUserProfileViewController

#pragma mark - Actions

- (IBAction)settingsButtonPressed:(UIButton *)sender
{
    NSLog(@"The user pressed the settings button.");
}


- (IBAction)addItemButtonPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
    
    GIProfileAddItemViewController *addItemViewController = [storyboard instantiateViewControllerWithIdentifier:@"GIProfileAddItemViewController"];
    [addItemViewController configureWithModelObject:self.userProfile];
    addItemViewController.delegate = self;
    addItemViewController.view.alpha = 0.0;
    
    [self.view addSubview:addItemViewController.view];
    [self addChildViewController:addItemViewController];
    
    [UIView animateWithDuration:0.35 animations:^{
        addItemViewController.view.alpha = 1.0;
    }];
}


- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma  mark - GIUserProfileViewControllerBase Method

- (void) configureWithModelObject:(GIUserProfile*)modelObject
{
    [super configureWithModelObject:modelObject];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.isSmallScreen = ([[UIScreen mainScreen] bounds].size.height < 568);
    self.cannotHaves = [NSArray array];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.backButton.hidden = ([self.navigationController viewControllers].count > 1) ? NO : YES;
    
    if ([self.userProfile.parseObject.objectId isEqualToString:[[[PFUser currentUser] objectForKey:@"userProfile"] objectId]]) {
        if (self.isReadOnlyMode) {  // If opening from Table Members, where there's no tab bar
            self.bottomConstraintSpace.constant = 0; // No Tab Bar
        }
        self.isReadOnlyMode = false;
    }
    
    if (self.isReadOnlyMode)
    {
        self.bottomConstraintSpace.constant = 0; // No Tab Bar
        self.settingsButton.hidden = YES;
        self.viewProfilePictureButton.userInteractionEnabled = NO;
        self.addNewItemAndStatusButton.userInteractionEnabled = NO;
        [self.addNewItemAndStatusButton setTitle:NSLocalizedString(@"Connected", @"Connected") forState:UIControlStateNormal];
        [self.addNewItemAndStatusButton setImage:[UIImage imageNamed:@"ConnectionsConnectedButton"] forState:UIControlStateNormal];
        [self.addNewItemAndStatusButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 20.0, 0.0, 0.0)];
    }
    else
    {
        self.settingsButton.hidden = NO;
        self.viewProfilePictureButton.userInteractionEnabled = YES;
        self.addNewItemAndStatusButton.userInteractionEnabled = YES;
        [self.addNewItemAndStatusButton setTitle:NSLocalizedString(@"Add New Item", @"Add New Item") forState:UIControlStateNormal];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self configureViews];
    [self configureDatasource];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configureViews];
    
//    [self.view hideProgressHUD];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id destination = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"CannotHavesSegue"]) {
        ((GIFoodItemsViewController*)destination).foodItemCategory = GIFoodItemCategoryCannotHaves;
        ((GIFoodItemsViewController*)destination).isReadOnlyMode = YES;
        [((GIFoodItemsViewController*)destination) configureWithModelObject:self.userProfile];
    }
    else if ([segue.identifier isEqualToString:@"LikesSegue"])
    {
        ((GIFoodItemsViewController*)destination).foodItemCategory = GIFoodItemCategoryLikes;
        [((GIFoodItemsViewController*)destination) configureWithModelObject:self.userProfile];
    }
    else if ([segue.identifier isEqualToString:@"DislikesSegue"])
    {
        ((GIFoodItemsViewController*)destination).foodItemCategory = GIFoodItemCategoryDislikes;
        [((GIFoodItemsViewController*)destination) configureWithModelObject:self.userProfile];
    }
    else if ([segue.identifier isEqualToString:@"DependentsSegue"])
    {
        [((GIDependentsViewController*)destination) configureWithModelObject:self.userProfile];
    }
    else if ([segue.identifier isEqualToString:@"ModalEditDependentSegue"])
    {
        ((GIAddNewDependentViewController*)destination).currentDependent = self.selectedDependent;
    }
    
    if ([destination respondsToSelector:@selector(isReadOnlyMode)])
    {
        [destination setIsReadOnlyMode:self.isReadOnlyMode];
    }
}


#pragma mark - UICollectionView Datasource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cannotHaves.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CannotHaveViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - GIUserProfileViewControllerDelegate
- (void) refreshProfileDataSource
{
    // Resets data
    [self configureViews];
    [self configureDatasource];
}

#pragma mark - Private Methods

- (void)configureViews
{
    [super configureViews];
    
    
    if (self.dependentsButton) {
        [self.dependentsButton.titleLabel setMinimumScaleFactor:0.5];
        [self.dependentsButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    
    if (self.locationButton) {
        [self.locationButton.titleLabel setMinimumScaleFactor:0.5];
        [self.locationButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.locationButton setTitle:self.userProfile.location forState:UIControlStateNormal];
    }
    
    if (self.dependentAgeButton) {
        [self.dependentAgeButton.titleLabel setMinimumScaleFactor:0.5];
        [self.dependentAgeButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.dependentAgeButton setTitle:[NSString stringWithFormat:@"%li %@", (long)[self.selectedDependent.birthDate mt_yearsUntilDate:[NSDate date]], NSLocalizedString(@"years old", @"years old")] forState:UIControlStateNormal];
    }
    
    if (self.dependentsUserImageView && self.dependentsUser.photoURL) {
        [self.dependentsUserImageView setImageWithURL:self.dependentsUser.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    }
    
    [self.userProfile dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
        [self.dependentsButton setTitle:[NSString stringWithFormat:@"%lu %@", (unsigned long)dependents.count, NSLocalizedString(@"Dependents", @"Dependents")] forState:UIControlStateNormal];
        self.dependentsButton.enabled = (self.isReadOnlyMode == YES && dependents.count == 0) ? NO : YES;
    }];
    
    
    [self.userProfile countLikedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSNumber *countLikes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.likesCountLabel.text = [countLikes stringValue];
        });
        
    }];
    
    [self.userProfile countDislikedFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSNumber* countDislikes) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dislikesCountLabel.text = [countDislikes stringValue];
        });
    }];
    
}

- (void)configureDatasource
{
    [self.userProfile cannotHaveFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *cannotHaves) {
        self.cannotHaves = cannotHaves;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cannotHavesCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.cannotHaves.count];
            //            [self.cannotHavesCountLabel sizeToFit];
            //
            //            CGRect frame = self.cannotHavesCountLabel.frame;
            //            frame.size.width += 10;
            //            frame.size.height += 5;
            //            self.cannotHavesCountLabel.frame = frame;
            //
            [self.cannotHaveCollectionView reloadData];
        });
    }];
}


- (void)configureCell:(GIFoodItemCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItem *foodItem = [self.cannotHaves objectAtIndex:indexPath.item];
    
    cell.itemTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:foodItem.name attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                                               NSFontAttributeName:[UIFont fontWithName:@"Helvetica"
                                                                                                                                                   size:12]}];
    
    NSString *photoURL = [NSString stringWithFormat:@"http://%@",foodItem.photoURL];
    
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize contentSize = CGSizeMake(90.0, 110.0);
    if (self.isSmallScreen)
    {
        contentSize.height = contentSize.height*0.60;
        contentSize.width = contentSize.width*0.60;
    }
    
    return contentSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 10, 2, 10);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 0);
}
@end