//
//  GIProfileEditViewController.m
//  Giusto
//
//  Created by John Gabelmann on 9/17/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIProfileEditViewController.h"
#import "GIChangePasswordViewController.h"
#import "UIImage+MyAdditions.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#define kNameTag               0
#define kEmailTag              1
#define kLocationTag           2
#define kPasswordTag           3

@interface GIProfileEditViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *locationField;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;

@property (nonatomic, strong) UIImage *avatarImage;

@end

@implementation GIProfileEditViewController
{
    BOOL _viewWillDisappear;
    
    UITextField *_currentField;
    
}

#pragma mark - Actions

- (IBAction)changePasswordSelected:(id)sender
{
    GIUser* currentUser = [GIUserStore sharedStore].currentUser;
    
    if (currentUser.email.length) {
        if ([currentUser.email isEqualToString:currentUser.username]) {
            [self performSegueWithIdentifier:@"ChangePasswordSegue" sender:self];
        } else {
            
            NSString* confirmationMessage = @"An e-mail will be sent to reset your password.\n You will be logged out.\nDo you want to proceed?";
            UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Reset password"
                                                                   message:confirmationMessage
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"No", @"Yes", nil];
            confirmAlert.tag = 1;
            [confirmAlert show];
        }
    } else {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error")
                           message:NSLocalizedString(@"Please, add en e-mail address to your profile", @"Please, add en e-mail address to your profile")
                 cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                 otherButtonTitles:nil
                          tapBlock:NULL];
    }
}


- (IBAction)saveButtonPressed:(id)sender
{
    
    // TODO: If we're going to allow users to change their email, the following code will have to reflect that.
    
    if ([[self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]
        && [[self.locationField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] length]) {
        
        [self.view showProgressHUD];
        
        GIUser* currentUser = [GIUserStore sharedStore].currentUser;
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"email" equalTo:self.emailField.text];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                // Didn't find anyone
                
                [[GIUserProfileStore sharedStore] saveUserProfileWithEmail:[GIUserStore sharedStore].currentUser.userProfile fullName:self.nameField.text email:self.emailField.text location:self.locationField.text photo:self.avatarImage birthday:nil completion:^(id sender, BOOL success, NSError *error, id result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (success) {
                            [UIAlertView showWithTitle:NSLocalizedString(@"Saved!", @"Saved!") message:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
                        }
                        else
                        {
                            [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
                        }
                        
                        [self.view hideProgressHUD];
                    });
                }];
                
            } else {
                // Found User
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    //Run UI Updates
                    [self.view hideProgressHUD];
                    [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error")
                                       message:NSLocalizedString(@"There is an user using this e-mail address already", @"There is an user using this e-mail address already")
                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                             otherButtonTitles:nil
                                      tapBlock:NULL];
                });
            }
        }];
        
        
        
    }
    else
    {
        [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"A name and location are required.", @"A name and location are required.") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:NULL];
    }
}


- (IBAction)photoButtonPressed:(id)sender
{
    [MYImagePickerController presentPickerWithCompletion:^(id sender, BOOL didPickImage, NSError *error, NSDictionary *info, UIImage *originalImage) {
        
        if (didPickImage) {
            
#pragma message "TODO: This is not working properly because there is something wrong with our image mask.  We need to create one with a raw path and apply it."
            UIImage *imageMask = [UIImage imageNamed:@"AvatarPhotoMask"];
            self.avatarImage = [UIImage maskImage:[originalImage imageByScalingAndCroppingForSize:CGSizeMake(68,68)]withMask:imageMask];
            self.avatarImageView.image = self.avatarImage;

            
        } else {
            
            if (error) {
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", @"Error") message:NSLocalizedString(@"There was an error with the image you selected. Please try again.", @"") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:NULL];
            }
            
        }
        
    }];
}


- (IBAction)deleteProfile:(id)sender
{
    [UIAlertView showWithTitle:@"Delete Profile"
                       message:@"Are you sure you want to delete your profile?"
             cancelButtonTitle:@"No"
             otherButtonTitles:@[@"Yes"]
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex){
        if(buttonIndex == 1){
        
            __weak __typeof__(self) weakSelf = self;
            // show progress hud
            [weakSelf.view showProgressHUD];
            
            // Delete user
            [[GIUserStore sharedStore] deleteUserWithCompletion:^(id sender, BOOL success, NSError *error, id result){
                if (success) {
                    // Log out User
                    [[GIUserStore sharedStore] logout];
                    [[[UITabBarController profileTabBarController] presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
                }else{
                    [UIAlertView showWithTitle:@"Error deleting profile" message:@"There was an error deleting your profile" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:nil];
                }
                
                // hide progress hud
                [weakSelf.view hideProgressHUD];
            }];
        }
    }];
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
    GIUserProfile *userProfile = [GIUserStore sharedStore].currentUser.userProfile;
    
    self.nameField.text = userProfile.fullName;
    self.emailField.text = [GIUserStore sharedStore].currentUser.email;
    self.locationField.text = userProfile.location;
    self.locationField.keyboardType = UIKeyboardTypeDecimalPad;
    
    if (userProfile.photoURL) {
        
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:userProfile.photoURL];
        
        [self.avatarImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            UIImage *imageMask = [UIImage imageNamed:@"AvatarPhotoMask"];
            self.avatarImage = [UIImage maskImage:[image imageByScalingAndCroppingForSize:CGSizeMake(68,68)] withMask:imageMask];
            self.avatarImageView.image = self.avatarImage;
            
        } failure:nil];
    }
}

#pragma mark - UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentField = textField;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _currentField = nil;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL rc = YES;
        
    switch (textField.tag) {
        case kLocationTag: {
            NSString *s = [textField.text stringByReplacingCharactersInRange:range withString:string];
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d{0,5}$" options:0 error:nil];
            NSTextCheckingResult *match = [regex firstMatchInString:s options:0 range:NSMakeRange(0, [s length])];
            rc = (match != nil);
            break;
        }
    }
    
    return rc;
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        GIUser* currentUser = [GIUserStore sharedStore].currentUser;
        
        switch(buttonIndex) {
            case 0: //"No" pressed
                break;
            case 1: //"Yes" pressed
                currentUser.parseUser.username = currentUser.email;
                [self.view showProgressHUD];
                [currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            //Run UI Updates
                            [self.view hideProgressHUD];
                            [[GIUserStore sharedStore] resetPasswordForEmail:currentUser.username];
                            [[GIUserStore sharedStore] logout];
                            [[[UITabBarController profileTabBarController] presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
                        });
                    }
                }];
                break;
        }
    }
}



@end
