//
//  GITableCollectionViewController.m
//  Giusto
//
//  Created by John Gabelmann on 10/20/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GITableCollectionViewController.h"
#import "GITableCollectionViewCell.h"
#import "GITableViewControllerBase.h"

@interface GITableCollectionViewController ()

@property (nonatomic, strong) NSArray *tables;

@end

@implementation GITableCollectionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self configureDatasource];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"TableDetailSegue"]) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:(GITableCollectionViewCell *)sender];
    
        GITable *selectedTable = [self.tables objectAtIndex:indexPath.item];
        
        GITableViewControllerBase *destination = segue.destinationViewController;
        
        [destination configureWithModelObject:selectedTable];
        destination.hidesBottomBarWhenPushed = YES;
    }
}



#pragma mark - Collection View Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tables.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GITableCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TableCollectionViewCell" forIndexPath:indexPath];
    
    // Configure the cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Collection View Delegate

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark - Private Methods

- (void)configureDatasource
{
    [self.modelDataUpdateDelegate tableCollectionViewControllerWillUpdateDataModel];
    
    [[GIUserStore sharedStore].currentUser tablesWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *tables) {
        if (success) {
            self.tables = tables;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.modelDataUpdateDelegate tableCollectionViewController:self didUpdateModelWithCount:self.tables.count];
            });
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error Loading Tables", @"Error Loading Tables") message:error.localizedDescription cancelButtonTitle:nil otherButtonTitles:nil tapBlock:NULL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.modelDataUpdateDelegate tableCollectionViewController:self didUpdateModelWithCount:self.tables.count];
            });
        }
    }];
}


- (void)configureCell:(GITableCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.layer.borderColor = GIColorCollectionCellBorderColor.CGColor;
    cell.layer.borderWidth = 1;
    
    GITable *table = [self.tables objectAtIndex:indexPath.item];
    
    cell.tableNameLabel.text = table.name;
    
    __block NSIndexPath *_indexPath = indexPath;
    [table userProfilesWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *userProfiles) {
        
        NSIndexPath *cellIndexPath = [self.collectionView indexPathForCell:cell];
        
        if (cellIndexPath.item == _indexPath.item) {
            cell.memberCountLabel.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)userProfiles.count, NSLocalizedString(@"Members", @"Members")];
        }
    }];
}


@end
