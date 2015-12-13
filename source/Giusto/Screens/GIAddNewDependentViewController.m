//
//  GIAddNewDependentViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/18/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIAddNewDependentViewController.h"
#import "UIImage+MyAdditions.h"
#import "NSDate+MTDates.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "GIDependentsViewController.h"

@interface GIAddNewDependentViewController ()

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *birthdayField;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSDate *birthday;


@end

@implementation GIAddNewDependentViewController

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)createButtonPressed:(id)sender
{
    
    if (self.birthday && self.nameField.text.length) {
        [[GIUserProfileStore sharedStore] createDependentForUser:[GIUserStore sharedStore].currentUser name:self.nameField.text birthday:self.birthday photo:self.avatarImage completion:^(id sender, BOOL success, NSError *error, id result) {
            if (success) {
                //[self.navigationController dismissViewControllerAnimated:YES completion:NULL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
            }
        }];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"A name and birthdate are required.", @"A name and birthdate are required.") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
    }

}


- (IBAction)saveButtonPressed:(id)sender
{
    if (self.birthday && self.nameField.text.length) {
        [[GIUserProfileStore sharedStore] saveDependent:self.currentDependent name:self.nameField.text birthday:self.birthday photo:self.avatarImage completion:^(id sender, BOOL success, NSError *error, id result) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
            }
        }];
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"A name and birthdate are required.", @"A name and birthdate are required.") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
    }
}


- (IBAction)deleteButtonPressed:(id)sender
{
    [UIAlertView showWithTitle:NSLocalizedString(@"Delete Dependent", @"Delete Dependent") message:NSLocalizedString(@"Are you sure you want to delete this dependent?", @"Are you sure you want to delete this dependent?") cancelButtonTitle:NSLocalizedString(@"No", @"No") otherButtonTitles:@[NSLocalizedString(@"Yes, delete", @"Yes, delete")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [[GIUserProfileStore sharedStore] deleteDependent:self.currentDependent completion:^(id sender, BOOL success, NSError *error, id result) {
                if (success) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIViewController *vc =  [self.navigationController viewControllerForUnwindSegueAction:@selector(goToDependents:) fromViewController:self withSender:nil];
                        if (vc)
                            [self.navigationController popToViewController:vc animated:YES];
                    });
                }
                else
                {
                    [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
                }
            }];
        }
    }];
}


- (IBAction)addPhotoButtonPressed:(id)sender
{
    [MYImagePickerController presentPickerWithCompletion:^(id sender, BOOL didPickImage, NSError *error, NSDictionary *info, UIImage *originalImage) {
        
        if (didPickImage) {
            
#pragma message "TODO: This is not working properly because there is something wrong with our image mask.  We need to create one with a raw path and apply it."
            UIImage *imageMask = [UIImage imageNamed:@"AvatarPhotoMask"];
            self.avatarImage = [UIImage maskImage:[originalImage imageByScalingAndCroppingForSize:CGSizeMake(68,68)] withMask:imageMask];
            self.avatarImageView.image = self.avatarImage;
            
        } else {
            
            if (error) {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There was an error with the image you selected. Please try again.", @"") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:NULL];
            }
            
        }
        
    }];
}


- (IBAction)birthdayButtonPressed:(id)sender
{
    [self.nameField resignFirstResponder];
    
    NSDate *selectedDate = [NSDate date];
    
    if (self.birthday) {
        selectedDate = self.birthday;
    }
    
    MYModalDatePickerView *datePicker = [MYModalDatePickerView pickerWithDate:selectedDate block:^(MYModalDatePickerView *datePickerView, BOOL madeChoice) {
        if (madeChoice) {
            self.birthday = datePickerView.datePicker.date;
            self.birthdayField.text = [NSString stringWithFormat:@"%@ %li %li", [self.birthday mt_stringFromDateWithShortMonth], (long)[self.birthday mt_dayOfMonth], (long)[self.birthday mt_year]];
        }
    }];
    
    datePicker.toolbar.barTintColor = GIColorOrange;
    datePicker.toolbar.tintColor = [UIColor whiteColor];
    
    
    // Adjusting toolbar buttons, they're plastered on the sides of the screen by default in its implementation, not sure why
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:datePicker.toolbar.items];
    
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButton.width = 10;
    
    [toolbarItems insertObject:spaceButton atIndex:0];
    [toolbarItems addObject:spaceButton];
    
    datePicker.toolbar.items = toolbarItems;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureViews];
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private Methods

- (void)configureViews
{
    if (self.currentDependent) {
        
        self.birthday = self.currentDependent.birthDate;

        self.nameField.text = self.currentDependent.fullName;
        self.birthdayField.text = [NSString stringWithFormat:@"%@ %li %li", [self.birthday mt_stringFromDateWithShortMonth], (long)[self.birthday mt_dayOfMonth], (long)[self.birthday mt_year]];
        
        if (self.currentDependent.photoURL) {
            
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:self.currentDependent.photoURL];
            
            [self.avatarImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
                UIImage *imageMask = [UIImage imageNamed:@"AvatarPhotoMask"];
                self.avatarImage = [UIImage maskImage:[image imageByScalingAndCroppingForSize:CGSizeMake(68,68)] withMask:imageMask];
                self.avatarImageView.image = self.avatarImage;
                
            } failure:nil];
        }
    }
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
