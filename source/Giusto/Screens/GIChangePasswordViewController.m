//
//  GIChangePasswordViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/17/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIChangePasswordViewController.h"

@interface GIChangePasswordViewController ()

@property (nonatomic, weak) IBOutlet UITextField *currentPasswordField;
@property (nonatomic, weak) IBOutlet UITextField *changedPasswordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordField;

@end

@implementation GIChangePasswordViewController

#pragma mark - Actions

- (IBAction)saveButtonPressed:(id)sender
{
    if ([self.changedPasswordField.text isEqualToString:self.confirmPasswordField.text]) {
        
        [[GIUserStore sharedStore] changePasswordFrom:self.currentPasswordField.text to:self.changedPasswordField.text completion:^(id sender, BOOL success, NSError *error, id result) {
            if (success) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [UIAlertView showWithTitle:@"Error Changing Password" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:NULL];
            }
        }];
    }
    else
    {
        [UIAlertView showWithTitle:@"Password Mismatch" message:@"New password and confirmed password do not match." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:NULL];
    }
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


#pragma mark - Private Methods

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
