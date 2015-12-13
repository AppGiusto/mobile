//
//  GITableDetailsTableViewController.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-30.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GITableDetailsTableViewController.h"
#import "GITableViewControllerBase.h"
#import "GIFoodItemCollectionViewCell.h"
#import "GITableProfileTableViewCell.h"
#import "GIFoodItemsViewController.h"
#import "GIMembersTableViewCell.h"
#import "GIUserProfileViewController.h"
#import "GIConnectionDependentsTableViewController.h"
#import "GIFoodItemsTableViewController.h"
#import "GIConnectionsTableViewController.h"
#import "GIAddNewMembersViewController.h"
#import "GIMembersTableViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

#define kRowCannotHaves         0
#define kRowLikes               1
#define kRowDislikes            2


#define kDislikesThresholdLow   20
#define kDislikesThresholdMid   50
#define kDislikesThresholdHigh  100

#define kDislikesCutoffLow      0.3f
#define kDislikesCutoffMid      0.4f
#define kDislikesCutoffHigh     0.5f

#define kLikesThresholdLow      20
#define kLikesThresholdMid      50
#define kLikesThresholdHigh     100

#define kLikesCutoffLow         0.5f
#define kLikesCutoffMid         0.6f
#define kLikesCutoffHigh        0.65f

@interface GITableDetailsTableViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *cannotHaves;
@property (nonatomic, strong) NSArray *userProfiles;
@property (nonatomic, strong) NSArray *likedFoodItems;
@property (nonatomic, strong) NSArray *dislikedFoodItems;

@end

@implementation GITableDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.table.name;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self configureViews];
    [self configureDatasourceWithLimit:1000 showingProgressHUD:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void) configureWithModelObject:(id<MYParseableModelObject>)modelObject
{
    self.table = modelObject;
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

// Get cutoff for likes based on number of users
- (float)getLikesThreshold
{
    int user_count = (int)self.userProfiles.count;
    
    if (user_count < kLikesThresholdLow)
        return 0.0f;
    
    if (user_count >= kLikesThresholdLow && user_count < kLikesThresholdMid)
        return kLikesCutoffLow;
    
    if (user_count >= kLikesThresholdMid && user_count < kLikesThresholdHigh)
        return kLikesCutoffMid;
    
    return kLikesCutoffHigh;
}

// Get cutoff for dislikes based on number of users
- (float)getDislikesThreshold
{
    int user_count = (int)self.userProfiles.count;
    
    if (user_count < kLikesThresholdLow)
        return 0.0f;
    
    if (user_count >= kLikesThresholdLow && user_count < kLikesThresholdMid)
        return kLikesCutoffLow;
    
    if (user_count >= kLikesThresholdMid && user_count < kLikesThresholdHigh)
        return kLikesCutoffMid;
    
    return kLikesCutoffHigh;
}

- (void)configureDatasourceWithLimit:(int) limit showingProgressHUD:(BOOL)showProgressHUD
{
    void (^populateFoodItems)(NSMutableDictionary*, NSArray*, GIUserProfile*) = ^(NSMutableDictionary *mutableFoodItemsDict, NSArray *foodItems, GIUserProfile *userProfile) {
        
        for (GIFoodItem* foodItem in foodItems) {
            GIFoodItem* currentFoodItem = mutableFoodItemsDict[foodItem.parseObject.objectId];
            if (currentFoodItem == nil) {
                currentFoodItem = foodItem;
                currentFoodItem.memberCount = 1;
                mutableFoodItemsDict[currentFoodItem.parseObject.objectId] = currentFoodItem;
            } else {
                currentFoodItem.memberCount++;
            }
            currentFoodItem.memberPercentage = (currentFoodItem.memberCount * 1.00) / ((unsigned long) self.userProfiles.count * 1.00);
            [currentFoodItem.memberArray addObject:userProfile];
        }
    };
    
    if (showProgressHUD) {
        [self.view showProgressHUD];
    }

    [self.table userProfilesWithCompletion:^(id sender, BOOL success, NSError *error, NSArray * userProfiles) {
        
        [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
            NSMutableDictionary* cannotHavesDict = [NSMutableDictionary new];
            NSMutableDictionary* dislikesDict = [NSMutableDictionary new];
            NSMutableDictionary* likesDict = [NSMutableDictionary new];
            
            [userProfiles enumerateObjectsUsingBlock:^(GIUserProfile *userProfile, NSUInteger idx, BOOL *stop) {
                self.userProfiles = userProfiles;

//                NSArray* userProfileCannotHaveFoodItems = userProfile.cannotHaveFoodItems;
//                NSArray* userProfileDislikedFoodItems = userProfile.likedFoodItems;
//                NSArray* userProfileLikedFoodItems = userProfile.dislikedFoodItems;
                
                NSArray* userProfileCannotHaveFoodItems = [userProfile cannotHaveFoodItemsWithLimit:limit andType:nil];
                NSArray* userProfileDislikedFoodItems = [userProfile dislikedFoodItemsWithLimit:limit andType:nil];
                NSArray* userProfileLikedFoodItems = [userProfile likedFoodItemsWithLimit:limit andType:nil]; // @"Dishes"
                
                populateFoodItems(cannotHavesDict, userProfileCannotHaveFoodItems, userProfile);
                populateFoodItems(dislikesDict, userProfileDislikedFoodItems, userProfile);
                populateFoodItems(likesDict, userProfileLikedFoodItems, userProfile);

            }];
            
            
            self.cannotHaves = [cannotHavesDict.allValues sortedArrayUsingComparator:^NSComparisonResult(GIFoodItem* a, GIFoodItem* b) {
                NSNumber *first = [NSNumber numberWithInt:a.memberCount];
                NSNumber *second = [NSNumber numberWithInt:b.memberCount];
                return [second compare:first];
            }];
            self.dislikedFoodItems = [dislikesDict.allValues sortedArrayUsingComparator:^NSComparisonResult(GIFoodItem* a, GIFoodItem* b) {
                NSNumber *first = [NSNumber numberWithInt:a.memberCount];
                NSNumber *second = [NSNumber numberWithInt:b.memberCount];
                return [second compare:first];
            }];
            self.likedFoodItems = [likesDict.allValues sortedArrayUsingComparator:^NSComparisonResult(GIFoodItem* a, GIFoodItem* b) {
                NSNumber *first = [NSNumber numberWithInt:a.memberCount];
                NSNumber *second = [NSNumber numberWithInt:b.memberCount];
                return [second compare:first];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (showProgressHUD) {
                    [self.view hideProgressHUD];
                }
                [self configureViews];
            });

        }];
    }];
}


- (void)configureDatasourceWithLimit_old:(int) limit showingProgressHUD:(BOOL)showProgressHUD
{
    if (showProgressHUD) {
        [self.view showProgressHUD];
    }
    void (^trimAndPopulateFoodItemPreference)(NSMutableArray *, NSArray *, GIUserProfile *);
    
    trimAndPopulateFoodItemPreference = ^(NSMutableArray *mutableFoodItems, NSArray *foodItems, GIUserProfile *user_profile)
    {
        [foodItems enumerateObjectsUsingBlock:^(GIFoodItem *aFoodItem, NSUInteger idx, BOOL *stop) {
            
            GIFoodItem *working = aFoodItem;
            for (GIFoodItem *check_item in mutableFoodItems) {
                if ([check_item.name isEqualToString:aFoodItem.name]) {
                    working = check_item;
                    break;
                }
            }
            
            if (working == aFoodItem)
            {
                //                NSLog(@"Adding %@ for %@",working.name,user_profile.fullName);
                [mutableFoodItems addObject:aFoodItem];
                working.memberCount = 1;
                working.memberArray = [NSMutableArray new];
            } else {
                //                NSLog(@"Updating %@ for %@",working.name,user_profile.fullName);
                working.memberCount ++;
            }
            
            [working.memberArray addObject:user_profile];
        }];
    };
    
    [self.table userProfilesWithCompletion:^(id sender, BOOL success, NSError *error, NSArray * userProfiles) {
        
        [[NSOperationQueue backgroundQueue] addOperationWithBlock:^{
            NSMutableArray *cannotHaves_ = [NSMutableArray array];
            NSMutableArray *likedFoodItems_ = [NSMutableArray array];
            NSMutableArray *dislikedFoodItems_ = [NSMutableArray array];
            NSMutableArray *likedFoodItemsAll_ = [NSMutableArray array];
            NSMutableArray *dislikedFoodItemsAll_ = [NSMutableArray array];
            
            [userProfiles enumerateObjectsUsingBlock:^(GIUserProfile *userProfile, NSUInteger idx, BOOL *stop)
             {
                 NSArray* userProfileCannotHaveFoodItems = [userProfile cannotHaveFoodItemsWithLimit:limit andType:nil];
                 NSArray* userProfileDislikedFoodItems = [userProfile dislikedFoodItemsWithLimit:limit andType:nil];
                 NSArray* userProfileLikedFoodItems = [userProfile likedFoodItemsWithLimit:limit andType:nil]; // @"Dishes"
                 
                 
                 trimAndPopulateFoodItemPreference(cannotHaves_, userProfileCannotHaveFoodItems, userProfile);
                 trimAndPopulateFoodItemPreference(likedFoodItemsAll_, userProfileLikedFoodItems, userProfile);
                 trimAndPopulateFoodItemPreference(dislikedFoodItemsAll_, userProfileDislikedFoodItems, userProfile);
                 [likedFoodItems_ addObject:userProfileLikedFoodItems];
                 [dislikedFoodItems_ addObject:userProfileDislikedFoodItems];
             }];
            
            self.userProfiles = userProfiles;
            
            CGFloat likedItemThreshold = [self getLikesThreshold];
            CGFloat dislikedItemThreshold = [self getDislikesThreshold];
            
            // Union of all likes, over a certain percentage threshold
            NSMutableArray *newLikedFoodItems = [NSMutableArray array];
            for (GIFoodItem *foodItem in likedFoodItemsAll_) {
                CGFloat foodItemFoundPercentage = 1.0;  // 100% Starting
                for (int i = 0; i < likedFoodItems_.count && foodItemFoundPercentage > likedItemThreshold; i++) {
                    NSArray *foodItems = [likedFoodItems_ objectAtIndex:i];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name LIKE[cd] %@", foodItem.name];
                    NSArray *filtered = [foodItems filteredArrayUsingPredicate:predicate];
                    if (!filtered || filtered.count == 0) {
                        foodItemFoundPercentage -= 1.0f / (float)likedFoodItems_.count;
                    }
                }
                
                foodItem.memberPercentage = foodItemFoundPercentage;
                
                if (foodItemFoundPercentage > likedItemThreshold) {
                    [newLikedFoodItems addObject:foodItem];
                }
                
                foodItemFoundPercentage = 1.0f;
            }
            
            // Union of all dislikes, over a certain percentage threshold
            NSMutableArray *newDislikedFoodItems = [NSMutableArray array];
            for (GIFoodItem *foodItem in dislikedFoodItemsAll_) {
                CGFloat foodItemFoundPercentage = 1.0;  // 100% Starting
                for (int i = 0; i < dislikedFoodItems_.count && foodItemFoundPercentage > dislikedItemThreshold; i++) {
                    NSArray *foodItems = [dislikedFoodItems_ objectAtIndex:i];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name LIKE[cd] %@", foodItem.name];
                    NSArray *filtered = [foodItems filteredArrayUsingPredicate:predicate];
                    if (!filtered || filtered.count == 0) {
                        foodItemFoundPercentage -= 1.0f / (float)dislikedFoodItems_.count;
                    }
                }
                
                foodItem.memberPercentage = foodItemFoundPercentage;
                
                if (foodItemFoundPercentage > dislikedItemThreshold) {
                    [newDislikedFoodItems addObject:foodItem];
                }
                
                foodItemFoundPercentage = 1.0f;
            }
            
            // Order cannot have array
            [cannotHaves_ sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                GIFoodItem *a = (GIFoodItem*)obj1;
                GIFoodItem *b = (GIFoodItem*)obj2;
                
                return a.memberCount < b.memberCount;
            }];
            
            // Order likes array
            [newLikedFoodItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                GIFoodItem *a = (GIFoodItem*)obj1;
                GIFoodItem *b = (GIFoodItem*)obj2;
                
                return a.memberPercentage < b.memberPercentage;
            }];
            
            // Order dislikes array
            [newDislikedFoodItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                GIFoodItem *a = (GIFoodItem*)obj1;
                GIFoodItem *b = (GIFoodItem*)obj2;
                
                return a.memberPercentage < b.memberPercentage;
            }];
            
            // Finalize
            self.cannotHaves = [NSArray arrayWithArray:cannotHaves_];
            self.likedFoodItems = [NSArray arrayWithArray:newLikedFoodItems];
            self.dislikedFoodItems = [NSArray arrayWithArray:newDislikedFoodItems];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (showProgressHUD) {
                    [self.view hideProgressHUD];
                }
                [self configureViews];
            });
            
        }];
    }];
}




- (void)configureViews
{
    [self.tableView reloadData];
    //GITableProfileTableViewCell *tableProfileCell = (GITableProfileTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    //[self configureTableProfileTableViewCell:tableProfileCell];
}

- (void)resizeCountLabel:(UILabel*)countLabel
{
    [countLabel sizeToFit];
    CGRect frame = countLabel.frame;
    frame.size.width += 10;
    frame.size.height += 5;
    countLabel.frame = frame;
}

- (void)configureTableProfileTableViewCell:(GITableProfileTableViewCell*)tableProfileCell
{
    [tableProfileCell.itemsCollectionView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 3;
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSString *identifier = @"GITableProfileCannotHave";
        if (indexPath.row == kRowLikes)     identifier = @"GITableProfileLikes";
        if (indexPath.row == kRowDislikes)  identifier = @"GITableProfileDislikes";
        
        GITableProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.itemsCollectionView.tag = indexPath.row;
        cell.itemsCollectionView.dataSource = self;
        cell.itemsCollectionView.delegate = self;
        [self configureTableProfileTableViewCell:cell];
        
        return cell;
    } else {
        GIMembersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GIMembers"];
        GIUserProfile *aUserProfile = self.userProfiles[indexPath.row];
        
        #pragma message "TODO: Add multiple user images"
        return cell;
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1 && self.userProfiles.count > 0)
    {
        UILabel *headerLabel = [[[NSBundle mainBundle] loadNibNamed:@"GIConnectionsTableViewSectionView" owner:nil options:nil] firstObject];
        headerLabel.text = @"";
        
        NSInteger numberOfMembers = self.userProfiles.count;
        //headerLabel.text = [NSString stringWithFormat:@"   %i %@",self.userProfiles.count, (numberOfMembers == 1) ? NSLocalizedString(@"Member", @"Member"):NSLocalizedString(@"Members", @"Members")];
        headerLabel.layer.borderWidth = 0.26;
        headerLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        return headerLabel;
    }
    else
    {
        return nil;
    }
}

#pragma mark - Tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 170;
    }
    else
    {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected row at indexpath %@",indexPath);
    if (indexPath.section == 0) {
        
        if (indexPath.row == kRowCannotHaves)
            [self showFoodItemTable:self.cannotHaves withType:kFoodTableTypeCannotHaves];
        
        if (indexPath.row == kRowDislikes)
            [self showFoodItemTable:self.dislikedFoodItems withType:kFoodTableTypeDislikes];
        
        if (indexPath.row == kRowLikes)
            [self showFoodItemTable:self.likedFoodItems withType:kFoodTableTypeLikes];
    }
    
    if (indexPath.section == 1)
    {
        GIMembersTableViewController *tvc = [[GIMembersTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [tvc setUserProfiles:self.userProfiles];
        tvc.viewTitle = @"Table Members";
        [self.navigationController pushViewController:tvc animated:true];
    }
}

- (void)showFoodItemTable:(NSArray*)food_items withType:(int)type
{
    GIFoodItemsTableViewController *tvc = [[GIFoodItemsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    tvc.tableType = type;
    tvc.aFoodItems = [NSMutableArray arrayWithArray:food_items];
    [self.navigationController pushViewController:tvc animated:true];
}

#pragma mark - UICollectionView Datasource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == kRowLikes)    return self.likedFoodItems.count;
    if (collectionView.tag == kRowDislikes) return self.dislikedFoodItems.count;
    return self.cannotHaves.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"CannotHaveCollectionViewCell";
    if (collectionView.tag == kRowDislikes) identifier = @"DislikesCollectionViewCell";
    if (collectionView.tag == kRowLikes)    identifier = @"LikesCollectionViewCell";
    
    GIFoodItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath withType:collectionView.tag];
    
    return cell;
}

- (void)configureCell:(GIFoodItemCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withType:(NSInteger)type
{
    GIFoodItem *foodItem;
    
    if (type == kRowCannotHaves)    foodItem = [self.cannotHaves objectAtIndex:indexPath.item];
    if (type == kRowDislikes)       foodItem = [self.dislikedFoodItems objectAtIndex:indexPath.item];
    if (type == kRowLikes)          foodItem = [self.likedFoodItems objectAtIndex:indexPath.item];
    
    cell.itemTitleLabel.text = foodItem.name;
    if (type == kRowCannotHaves)
        cell.itemCountLabel.text = [NSString stringWithFormat:@"%i",foodItem.memberCount];
    else
        cell.itemCountLabel.text = [NSString stringWithFormat:@"%i%%",(int)(foodItem.memberPercentage * 100)];
    
    NSString *photoURL = [NSString stringWithFormat:@"http://%@",foodItem.photoURL];
    
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIFoodItem *foodItem;
    
    if (collectionView.tag == kRowCannotHaves)      foodItem = [self.cannotHaves objectAtIndex:indexPath.item];
    if (collectionView.tag == kRowDislikes)         foodItem = [self.dislikedFoodItems objectAtIndex:indexPath.item];
    if (collectionView.tag == kRowLikes)            foodItem = [self.likedFoodItems objectAtIndex:indexPath.item];

    if (foodItem && foodItem.memberArray) {
        
        // Set up members view
        GIMembersTableViewController *tvc = [[GIMembersTableViewController alloc] initWithStyle:UITableViewStylePlain];
        [tvc setUserProfiles:foodItem.memberArray];
        
        // Get title
        NSString *base;
        if (collectionView.tag == kRowCannotHaves)  base = @"Cannot Have";
        if (collectionView.tag == kRowDislikes)     base = @"Dislikes";
        if (collectionView.tag == kRowLikes)        base = @"Likes";
        
        // Present view
        tvc.viewTitle = [NSString stringWithFormat:@"%@ %@",base,foodItem.name];
        [self.navigationController pushViewController:tvc animated:true];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ModalEditTableSegue"]) {
        GITableViewControllerBase *destination = [[(UINavigationController *)segue.destinationViewController viewControllers] firstObject];
        
        [destination configureWithModelObject:self.table];
    }
}

@end
