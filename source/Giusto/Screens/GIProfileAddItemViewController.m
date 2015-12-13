//
//  GIProfileAddItemViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/19/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIProfileAddItemViewController.h"
#import "GINewFoodItemViewController.h"
#import "GINewFoodItemFilterViewController.h"

@interface GIProfileAddItemViewController ()

@end

@implementation GIProfileAddItemViewController

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.35 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        // refresh data
        [self.delegate refreshProfileDataSource];
    }];
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // With either segue, when they return they need to see the profile view, not the add item view. Dismiss it here
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self cancelButtonPressed:self];
    });
    
    if ([segue.identifier isEqualToString:@"NewCannotHaveModalSegue"])
    {
        GINewFoodItemFilterViewController *destination = [[segue.destinationViewController viewControllers] firstObject];
        [destination configureWithModelObject:self.userProfile];
        destination.foodItemCategory = GIFoodItemCategoryCannotHaves;
        destination.delegate = self.delegate;
    }
    else if ([segue.identifier isEqualToString:@"NewLikeOrDislikeModalSegue"])
    {
        GINewFoodItemFilterViewController *destination = [[segue.destinationViewController viewControllers] firstObject];
        [destination configureWithModelObject:self.userProfile];
        destination.foodItemCategory = GIFoodItemCategoryLikes;
        destination.delegate = self.delegate;
    }
    
}


@end
