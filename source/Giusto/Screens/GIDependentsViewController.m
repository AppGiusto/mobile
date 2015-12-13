//
//  GIDependentsViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/18/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIDependentsViewController.h"
#import "GIDependentCollectionViewCell.h"
#import "GIUserProfileViewController.h"
#import <MTDates/NSDate+MTDates.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface GIDependentsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionview;
@property (nonatomic, weak) IBOutlet UIView *instructionView;
@property (nonatomic, strong) NSArray *dependents;

@end

@implementation GIDependentsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.isReadOnlyMode)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    }
    // Do any additional setup after loading the view.
    self.instructionView.hidden = YES;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.view showProgressHUD];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self configureDatasource];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


#pragma mark - Collection View Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dependents.count;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GIDependentCollectionViewCell *cell = (GIDependentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DependentCollectionViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (void)configureDatasource
{
    [self.view showProgressHUD];
    
    [self.userProfile dependentsWithCompletion:^(id sender, BOOL success, NSError *error, NSArray *dependents) {
        
        if (success) {
            self.dependents = dependents;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionview reloadData];
                if (self.dependents.count == 0)
                {
                    self.instructionView.hidden = NO;
                }
                else
                {
                    self.instructionView.hidden = YES;
                }
                [self.view hideProgressHUD];
            });
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Error Loading Dependents", @"Error Loading Dependents") message:error.localizedDescription cancelButtonTitle:nil otherButtonTitles:nil tapBlock:NULL];
            [self.view hideProgressHUD];
        }
        
    }];
}


- (void)configureCell:(GIDependentCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GIUserProfile *dependent = [self.dependents objectAtIndex:indexPath.item];
    
    cell.dependentNameLabel.text = dependent.fullName;
    cell.depententAgeLabel.text = [NSString stringWithFormat:@"%li %@", (long)[dependent.birthDate mt_yearsUntilDate:[NSDate date]], NSLocalizedString(@"years old", @"years old")];
    
    cell.dependentImageView.layer.borderColor = GIColorImageViewBorderColor.CGColor;
    cell.dependentImageView.layer.borderWidth = 1;
    cell.layer.borderColor = GIColorCollectionCellBorderColor.CGColor;
    cell.layer.borderWidth = 1;
    
    if (dependent.photoURL) {
        [cell.dependentImageView setImageWithURL:dependent.photoURL placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    }
    else
    {
        [cell.dependentImageView setImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"DependentProfileSegue"]) {
        
        NSIndexPath *selectedIndexPath = [self.collectionview indexPathForCell:sender];
        GIUserProfile *selectedDependent = [self.dependents objectAtIndex:selectedIndexPath.item];
        
        GIUserProfileViewController *destination = segue.destinationViewController;
        
        destination.selectedDependent = selectedDependent;
        destination.dependentsUser = self.userProfile;
        
        [destination configureWithModelObject:selectedDependent];
        destination.isReadOnlyMode = self.isReadOnlyMode;        
    }
}

#pragma mark - Unwind Seques
- (IBAction) goToDependents:(UIStoryboardSegue *)segue
{
    NSLog(@"Called goToDependents: unwind action");
}

@end
