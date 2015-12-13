//
//  GIChangeDietViewController.m
//  Giusto
//
//  Created by Nielson Rolim on 7/20/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIChangeDietViewController.h"
#import "GIFoodItemTableViewCell.h"
#import "GIChageDietDetailViewController.h"

@interface GIChangeDietViewController ()

@property (weak, nonatomic) IBOutlet UITableView *dietTableView;

@property (strong, nonatomic) NSArray* dietItems;
@property (strong, nonatomic) NSMutableDictionary* userDietItems;

@end

@implementation GIChangeDietViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view showProgressHUD];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        
        self.dietItems = [[GIDietItemStore sharedStore] getDietItems];
                
        self.userDietItems = [[self.userProfile dietItems] mutableCopy];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self.dietTableView reloadData];
            [self.view hideProgressHUD];
        });
        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueButtonPressed:(UIBarButtonItem *)sender {
    GIDietItem* omnivoreDietItem = nil;
    for (GIDietItem* dietItem in self.userDietItems.allValues) {
        if ([dietItem.name isEqualToString:@"Omnivore"]) {
            omnivoreDietItem = dietItem;
            break;
        }
    }
    
    if (omnivoreDietItem && (self.userDietItems.allValues.count == 1)) {
        [self changeDietToOmnivoreDiet:omnivoreDietItem];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        if (omnivoreDietItem) {
            [self.userDietItems removeObjectForKey:omnivoreDietItem.objectId];
            [self.dietTableView reloadData];
        }
        [self performSegueWithIdentifier:@"changeDietDetailSegue" sender:self];
    }
}

- (void) changeDietToOmnivoreDiet:(GIDietItem*) omnivoreDietItem {
    NSArray* dietItems = [[GIDietItemStore sharedStore] getDietItems];
    [[GIDietItemStore sharedStore] removeDietItems:dietItems FromProfile:self.userProfile];
    [[GIDietItemStore sharedStore] addDietItem:omnivoreDietItem toProfile:self.userProfile];
    
    [self.userProfile cannotHaveFoodItemsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray* cannothaves) {
        //
        if (success) {
            [[GIFoodItemStore sharedStore] removeFoodItems:cannothaves FromProfile:self.userProfile category:GIFoodItemCategoryCannotHaves];
         
            [[GIFoodItemStore sharedStore] addFoodItems:cannothaves toProfile:self.userProfile itemCategory:GIFoodItemCategoryLikes];
        }
        
    }];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dietItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIFoodItemTableViewCell *cell = (GIFoodItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"ChangeDietCell" forIndexPath:indexPath];
    // Configure the cell...

    GIDietItem* dietItem = [self.dietItems objectAtIndex:indexPath.row];

    cell.itemTitleLabel.text = dietItem.name;
    NSString* imageName = [NSString stringWithFormat:@"diet-%@", dietItem.name];
    UIImage* image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageNamed:@"AvatarImagePlaceholder"];
    }
    cell.itemImageView.image = image;
    cell.itemImageView.layer.borderWidth = 0;

    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    if ([self.userDietItems objectForKey:dietItem.objectId]) {
        btnImageView.image = [UIImage imageNamed:@"AddUserChecked"];
    } else {
        btnImageView.image = [UIImage imageNamed:@"AddUserUnchecked"];
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
    
//    NSLog(@"self.userDietItems.count: %lu", (unsigned long)self.userDietItems.count);
    
    GIFoodItemTableViewCell *cell = (GIFoodItemTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];

    GIDietItem* dietItem = [self.dietItems objectAtIndex:indexPath.row];
    
    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];

    if (![self.userDietItems objectForKey:dietItem.objectId]) {
        [self.userDietItems setValue:dietItem forKey:dietItem.objectId];
        btnImageView.image = [UIImage imageNamed:@"AddUserChecked"];
    } else {
        [self.userDietItems removeObjectForKey:dietItem.objectId];
        btnImageView.image = [UIImage imageNamed:@"AddUserUnchecked"];
    }
    
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


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"changeDietDetailSegue"]) {
         GIChageDietDetailViewController* changeDietDetailVC = segue.destinationViewController;
         changeDietDetailVC.userDietItems = self.userDietItems;
     }
 }

@end
