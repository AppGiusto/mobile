//
//  GIFoodItemsTableViewController.m
//  Giusto
//
//  Created by Timothy Raveling on 15-05-20.
//  Copyright (c) 2015 CabForward. All rights reserved.
//

#import "GIFoodItemsTableViewController.h"
#import "GIFoodItemsTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#define kCellIdentifier         @"FoodItemTableViewCell"

#define HexColor(rgbValue)          [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kColorRed                   HexColor(0xF04936)
#define kColorOrange                HexColor(0xFF6900)
#define kColorGreen                 HexColor(0x26A65B)

@interface GIFoodItemsTableViewController ()

@end

@implementation GIFoodItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set title
    if (self.tableType == kFoodTableTypeLikes)          self.title = @"Likes";
    if (self.tableType == kFoodTableTypeDislikes)       self.title = @"Dislikes";
    if (self.tableType == kFoodTableTypeCannotHaves)    self.title = @"Cannot Haves";
    
    [self.tableView registerNib:[UINib nibWithNibName:@"GIFoodItemsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.aFoodItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GIFoodItemsTableViewCell *cell = (GIFoodItemsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    // Configure cell
    GIFoodItem *item = [self.aFoodItems objectAtIndex:indexPath.row];
    cell.lbItemLabel.text = item.name;
    
    // Configure badge
    if (self.tableType == kFoodTableTypeLikes)          cell.lbPercentage.backgroundColor = kColorGreen;
    if (self.tableType == kFoodTableTypeDislikes)       cell.lbPercentage.backgroundColor = kColorOrange;
    if (self.tableType == kFoodTableTypeCannotHaves)    cell.lbPercentage.backgroundColor = kColorRed;
    
    // Populate badge
    if (self.tableType == kFoodTableTypeCannotHaves)
        cell.lbPercentage.text = [NSString stringWithFormat:@"%i",item.memberCount];
    else
        cell.lbPercentage.text = [NSString stringWithFormat:@"%i%%",(int)(item.memberPercentage * 100)];
    
    // Set photo
    NSString *photoURL = [NSString stringWithFormat:@"http://%@",item.photoURL];
    [cell.ivIcon setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}

@end