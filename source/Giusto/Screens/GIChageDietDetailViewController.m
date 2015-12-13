//
//  GIChageDietDetailViewController.m
//  Giusto
//
//  Created by Nielson Rolim on 7/26/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIChageDietDetailViewController.h"
#import "GIFoodItemTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIChageDietDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *foodItemsTableView;
@property (nonatomic, strong) NSMutableArray* foodItems;
@property (nonatomic, strong) NSMutableArray* selectedFoodItems;
@property (nonatomic, strong) NSMutableArray* unselectedFoodItems;
@property (nonatomic, strong) NSArray* cannotHaveFoodItems;
@property (nonatomic, strong) NSArray* dietFootItems;

@end

@implementation GIChageDietDetailViewController


- (NSMutableArray*) foodItems {
    if (!_foodItems) {
        _foodItems = [NSMutableArray new];
    }
    return _foodItems;
}

- (NSMutableArray*) selectedFoodItems {
    if (!_selectedFoodItems) {
        _selectedFoodItems = [NSMutableArray new];
    }
    return _selectedFoodItems;
}

- (NSMutableArray*) unselectedFoodItems {
    if (!_unselectedFoodItems) {
        _unselectedFoodItems = [NSMutableArray new];
    }
    return _unselectedFoodItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view showProgressHUD];
    [self configureWithModelObject:[GIUserStore sharedStore].currentUser.userProfile];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        
        self.cannotHaveFoodItems = self.userProfile.cannotHaveFoodItems;
        
//        NSLog(@"--------------------------------");
//        NSLog(@"self.cannotHaveFoodItems: %@", self.cannotHaveFoodItems);
//        NSLog(@"self.cannotHaveFoodItems.count: %d", (int)self.cannotHaveFoodItems.count);
//        NSLog(@"--------------------------------");

        for (GIFoodItem* foodItem in self.cannotHaveFoodItems) {
            [self.foodItems addObject:foodItem];
            [self.selectedFoodItems addObject:foodItem];
        }
        
        for (GIDietItem* dietItem in self.userDietItems.allValues) {
            for (GIFoodItem* foodItem in [dietItem foodItems]) {
                if (![self.foodItems containsObject:foodItem]) {
                    [self.foodItems addObject:foodItem];
                    [self.selectedFoodItems addObject:foodItem];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self.foodItemsTableView reloadData];
            [self.view hideProgressHUD];
        });
    });
    
    if ([self.foodItemsTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.foodItemsTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmHandler:(UIBarButtonItem *)sender {
    //    NSLog(@"confirmHandler");
    [self.view showProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        
        NSArray* dietItems = [[GIDietItemStore sharedStore] getDietItems];
        [[GIDietItemStore sharedStore] removeDietItems:dietItems FromProfile:self.userProfile];
        [[GIDietItemStore sharedStore] addDietItems:self.userDietItems.allValues toProfile:self.userProfile];

        
        
        [[GIFoodItemStore sharedStore] removeFoodItems:self.unselectedFoodItems FromProfile:self.userProfile category:GIFoodItemCategoryCannotHaves];
        
        [[GIFoodItemStore sharedStore] removeFoodItems:self.selectedFoodItems FromProfile:self.userProfile category:GIFoodItemCategoryLikes];
        [[GIFoodItemStore sharedStore] removeFoodItems:self.selectedFoodItems FromProfile:self.userProfile category:GIFoodItemCategoryDislikes];

        [[GIFoodItemStore sharedStore] addFoodItems:self.selectedFoodItems toProfile:self.userProfile itemCategory:GIFoodItemCategoryCannotHaves];
        

//        NSArray* dislikedFoodItems = [[self.userProfile dislikedFoodItems] copy];
//        NSArray* likedFoodItems = [[self.userProfile likedFoodItems] copy];
//        NSArray* cannothaveFoodItems = [[self.userProfile cannotHaveFoodItems] copy];
//        NSMutableArray* newLikedFoodItems = [[[GIFoodItemStore sharedStore] getFoodItems] mutableCopy];
//        
//        for (GIFoodItem* foodItem in dislikedFoodItems) {
//            [newLikedFoodItems removeObject:foodItem];
//        }
//
//        for (GIFoodItem* foodItem in likedFoodItems) {
//            [newLikedFoodItems removeObject:foodItem];
//        }
//
//        for (GIFoodItem* foodItem in cannothaveFoodItems) {
//            [newLikedFoodItems removeObject:foodItem];
//        }
//        
//        [[GIFoodItemStore sharedStore] addFoodItems:newLikedFoodItems toProfile:self.userProfile itemCategory:GIFoodItemCategoryLikes];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self.view hideProgressHUD];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.foodItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIFoodItemTableViewCell *cell = (GIFoodItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"changeDietFoodItemCell" forIndexPath:indexPath];
    
    // Configure the cell...
    GIFoodItem* foodItem = [self.foodItems objectAtIndex:indexPath.row];
    
//    if ([self.cannotHaveFoodItems containsObject:foodItem]) {
//        [self.selectedFoodItems addObject:foodItem];
//    }
    
    // Cell Title
    cell.itemTitleLabel.text = foodItem.name;
    
    // Cell Image
    [cell.itemImageView setRoundCorners];
    NSString *photoURL = [NSString stringWithFormat:@"http://%@",foodItem.photoURL];
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    
    
    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    btnImageView.image = [UIImage imageNamed:@"AddFoodItem"];
    
    if ([self.selectedFoodItems containsObject:foodItem]) {
        btnImageView.image = [UIImage imageNamed:@"AddedDislikedFoodItem"];
    }
    
    cell.accessoryView = btnImageView;

    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - UITableview Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    GIFoodItem* foodItem = [self.foodItems objectAtIndex:indexPath.row];
    
    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];

    if ([self.selectedFoodItems containsObject:foodItem]) {
        [self.selectedFoodItems removeObject:foodItem];
        [self.unselectedFoodItems addObject:foodItem];
        btnImageView.image = [UIImage imageNamed:@"AddFoodItem"];
    } else {
        [self.selectedFoodItems addObject:foodItem];
        [self.unselectedFoodItems removeObject:foodItem];
        btnImageView.image = [UIImage imageNamed:@"AddedDislikedFoodItem"];
    }
    
//    NSLog(@"--------------------------------");
//    NSLog(@"selectedFoodItems: %d", (int)self.selectedFoodItems.count);
//    NSLog(@"unselectedFoodItems: %d", (int)self.unselectedFoodItems.count);
//    NSLog(@"--------------------------------");

    
    cell.accessoryView = btnImageView;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
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



@end
