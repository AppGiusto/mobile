/*
 *	GIUserStore.m
 *	Pods
 *
 *	Created by Vincil Bishop on 9/3/14.
 *
 */

#import "GIUserStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"
/*#import <Appsee/Appsee.h>*/
#import <Intercom/Intercom.h>


@interface GIUserStore()

@end

@implementation GIUserStore

+ (GIUserStore *) sharedStore
{
    // Persistent instance.
    static GIUserStore *_sharedStore = nil;
    
    // Small optimization to avoid wasting time after the
    // singleton being initialized.
    if (!_sharedStore)
    {
        _sharedStore = [[GIUserStore alloc] initSingleton];
    }
    
    return _sharedStore;
}

- (id) initSingleton
{
    if ((self = [super init]))
    {
        // Initialization code here.
        self.modelObjectType = [GIUser class];
    }
    
    return self;
}

#pragma mark - Helper Properties -

- (BOOL) authenticated
{
    return self.currentUser != nil;
}

- (NSString*) defaultUsername
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:kGIDefaultUsernameKey];
}

- (void) setDefaultUsername:(NSString*)defaultUsername
{
    [[NSUserDefaults standardUserDefaults] setValue:defaultUsername forKey:kGIDefaultUsernameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) defaultPassword
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    return [[NSUserDefaults standardUserDefaults] valueForKey:kGIDefaultPasswordKey];
    
}

- (void) setDefaultPassword:(NSString*)defaultPassword
{
    [[NSUserDefaults standardUserDefaults] setValue:defaultPassword forKey:kGIDefaultPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) hasDefaultCredentials
{
    return ([self defaultUsername] != nil) && ([self defaultPassword] != nil);
}

- (void) clearDefaultCredentials
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGIDefaultUsernameKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGIDefaultPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Store Verbs -

- (void) deleteUserWithCompletion:(MYCompletionBlock)completion
{
    // A. Delete userProfile
    [[GIUserProfileStore sharedStore] deleteUserProfile:self.currentUser.userProfile completion:^(id sender, BOOL success, NSError *error, id result) {
        
        // A. Sucessfully deleted userProfile
        if (success) {
            
            // B. Delete  userSettings
            [[GIUserSettingsStore sharedStore] deleteUserSetting:self.currentUser.userSettings completion:^(id sender, BOOL success, NSError *error, id result) {
                
                // B. Sucessfully deleted userSettings
                if (success) {
                    
                    // C. Delete currentUser
                    [self.currentUser.parseUser deleteInBackgroundWithBlock:^(BOOL success, NSError *error){
                        // C. Sucessfully deleted  currentUser
                        if (completion) {
                            completion(self, success, error, nil);
                        }
                    }];
                }else{ // B. Fail
                    if (completion) {
                        completion(self, success, error, nil);
                    }
                }
            }];
        }else{ // A. Fail
            if (completion) {
                completion(self, success, error, nil);
            }
        }
    }];
}

- (void) signUpWithFullName:(NSString*)fullName email:(NSString*)email location:(NSString*)location password:(NSString*)password photo:(UIImage *)photo completion:(MYCompletionBlock)completion
{
    GIUser *user = [GIUser parseModel];
    user.parseUser.username = email;
    user.parseUser.email = email;
    user.parseUser.password = password;
    NSError *signUpError = nil;
    
    
#pragma message "TODO Signup should be carried out on a background thread. Show a progress indicator."
    if([user.parseUser signUp:&signUpError]) {
        
        [self loginInBackgroundWithUsername:email password:password completion:^(id sender, BOOL success, NSError *error, id result) {
            
            // Create user profile
            [[GIUserProfileStore sharedStore] createUserProfileWithUser:self.currentUser fullName:fullName location:location photo:photo completion:^(id sender, BOOL success, NSError *error, id result) {
                
                if (success) {
                    [[GIUserSettingsStore sharedStore] createUserSettingsWithUser:self.currentUser completion:^(id sender,  BOOL success, NSError *error, id result) {
                        if (completion) {
                            completion(self, error == nil, error, self.currentUser);
                        }
                    }];
                }
                else
                {
                    if (completion) {
                        completion(self,error == nil,error,self.currentUser);
                    }
                }
            }];
            
        }];
    }
    else {
        if(completion) {
            completion(self, signUpError == nil, signUpError, self.currentUser);
        }
    }
}

- (void) initiateUserAnalytics
{
    if (self.currentUser != nil)
    {
        //        [Appsee setUserID: (self.currentUser.username != nil) ? self.currentUser.username : [self.currentUser parseUser].objectId];
    }
}

- (GIUser*) loginWithUsername:(NSString*)username password:(NSString*)password error:(NSError **)error
{
//    error = nil;
    PFUser *user = [PFUser logInWithUsername:username password:password error:error];
    
    //NSAssert(user,@"user must assert!");
    
    if (user) {
        self.defaultUsername = username;
        self.defaultPassword = password;
        self.currentUser = [GIUser parseModelUserWithParseUser:user];
        [self initiateUserAnalytics];
    }
    
    return self.currentUser;
}

- (void) loginInBackgroundWithUsername:(NSString*)username password:(NSString*)password completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        GIUser *user = [self loginWithUsername:username password:password error:&error];
        //NSAssert(!error,@"error on login!");
        
        if (error) {
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:username];
            PFUser* someUser = (PFUser*)[userQuery getFirstObject];
            
            if (!someUser) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"User not found.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please, sign up.", nil)
                                           };
                
                error = [NSError errorWithDomain:@"com.appgiusto.Giusto"
                                            code:901
                                        userInfo:userInfo];
            }
        }
        
        if (completion) {
            completion(self,user != nil,error,user);
        }
    }];
}

- (void) loginInBackgroundWithFacebookAndCompletion:(MYCompletionBlock)completion {
    
    NSArray *permissions = @[@"public_profile", @"email", @"user_friends"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        
//        NSLog(@"---------------------------------------------------");
//        NSLog(@"accessToken: %@", [FBSDKAccessToken currentAccessToken].tokenString);
//        NSLog(@"---------------------------------------------------\n");
        
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            
            self.currentUser = nil;
            [[GIUserStore sharedStore] logout];
            
            if (completion) {
                completion(self, NO, nil, nil);
            }
        } else {
            
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email,location" forKey:@"fields"];
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    NSString *facebookId = userData[@"id"];
                    NSString *email = userData[@"email"];
                    
                    self.currentUser = [GIUser parseModelUserWithParseUser:user];
                    
                    [self initiateUserAnalytics];
                    
                    
                    if (user.isNew) {
                        
                        NSLog(@"User signed up and logged in through Facebook!");
                        
                        NSString *name = userData[@"name"];
                        NSString *location = userData[@"location"][@"zip"];
                        
                        NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
                        
                        NSData *imageData = [NSData dataWithContentsOfURL:pictureURL];
                        UIImage *photoImage = [UIImage imageWithData:imageData];
                        self.defaultUsername = email;
                        self.defaultPassword = facebookId;
                        
                        self.currentUser.parseUser.email = email;
                        self.currentUser.facebookId = facebookId;
                        
                        [self.currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            
                            if (succeeded) {
                                
                                //Create user profile
                                [[GIUserProfileStore sharedStore] createUserProfileWithUser:self.currentUser fullName:name location:location photo:photoImage completion:^(id sender, BOOL success, NSError *error, id result) {
                                    
                                    if (success) {
                                        NSLog(@"UserProfile successfully created!");
                                    }
                                    
                                    //Create user settings
                                    [[GIUserSettingsStore sharedStore] createUserSettingsWithUser:self.currentUser completion:^(id sender, BOOL success, NSError *error, id result) {
                                        
                                        if (success) {
                                            NSLog(@"UserSettings successfully created!");
                                        }
                                        
                                        if (completion) {
                                            completion(self, error == nil, error, self.currentUser);
                                        }
                                        
                                    }];
                                    
                                }];
                                
                                
                            } else {
                                
                                self.currentUser = nil;
                                
                                [user delete];
                                
                                [[GIUserStore sharedStore] logout];
                                
                                if (completion) {
                                    completion(self, error == nil, error, nil);
                                }
                                
                            }
                        }];
                        
                    } else {
                        NSLog(@"User logged in through Facebook!");
                        
                        if (self.currentUser.email.length == 0 || self.currentUser.facebookId.length == 0) {
                            
                            if (self.currentUser.email.length == 0) {
                                self.currentUser.parseUser.email = email;
                            }
                            
                            if (self.currentUser.facebookId.length == 0) {
                                self.currentUser.facebookId = facebookId;
                            }
                            
                            //[self.currentUser.parseUser saveInBackground];
                        }
                        
                        if (completion) {
                            completion(self, error == nil, error, self.currentUser);
                        }
                    }
                    
                } else {
                    if (completion) {
                        completion(self, error == nil, error, self.currentUser);
                    }
                }
            }];
        }
    }];
    
    
}

- (BOOL) loginWithDefaultCredentialsAndError:(NSError **)error
{
    if ([PFUser currentUser] ||
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        self.currentUser = [GIUser parseModelUserWithParseUser:[PFUser currentUser]];
        [self initiateUserAnalytics];
        
        NSString* userID = [NSString stringWithFormat:@"%@", self.currentUser.parseUser.objectId];
        [Intercom registerUserWithUserId:userID];
        
        return self.currentUser != nil;
        
    } else {
        
        if (error){
            *error = [NSError errorWithDomain:@"com.cabforward.giusto.authentication" code:500 userInfo:@{NSLocalizedDescriptionKey:@"Default credentials have not been set."}];
        }
        
        return NO;
        
    }
    
    /*if (self.hasDefaultCredentials) {
     GIUser *user = [self loginWithUsername:self.defaultUsername password:self.defaultPassword error:error];
     return user != nil;
     } else {
     if (error){
     *error = [NSError errorWithDomain:@"com.cabforward.giusto.authentication" code:500 userInfo:@{NSLocalizedDescriptionKey:@"Default credentials have not been set."}];
     }
     
     return NO;
     }*/
}

- (void) logout
{
    [Intercom reset];
    self.currentUser = nil;
    [self clearDefaultCredentials];
    [PFUser logOut];
}

- (void) resetPasswordForEmail:(NSString *)emailAddress
{
    [PFUser requestPasswordResetForEmailInBackground:emailAddress block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [UIAlertView showWithTitle:NSLocalizedString(@"Password Reset Sent!", @"Password Reset Sent!") message:NSLocalizedString(@"Check your email for instructions to reset your password", @"Chack your email for instructions to reset your password") cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Password Reset Failed!", @"Password Reset Failed!") message:error.localizedDescription cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil tapBlock:nil];
        }
    }];
}

- (void) changePasswordFrom:(NSString *)currentPassword to:(NSString *)changedPassword completion:(MYCompletionBlock)completion
{
    if ([self.defaultPassword isEqualToString:currentPassword]) {
        self.currentUser.parseUser.password = changedPassword;
        [self.currentUser.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                self.defaultPassword = changedPassword;
                [self setDefaultPassword:changedPassword];
            }
            
            completion(self, succeeded, error, self.currentUser);
        }];
    }
    else
    {
        NSError *passwordMismatchError = [NSError errorWithDomain:@"com.cabforward.giusto.changepassword" code:500 userInfo:@{NSLocalizedDescriptionKey: @"Current password incorrect"}];
        
        completion(self, NO, passwordMismatchError, self.currentUser);
    }
}

#pragma mark -
- (void) findUsersWithProfile:(id)userProfile completion:(MYCompletionBlock)completion
{
    PFQuery *userProfilesQuery = [PFQuery queryWithClassName:@"User"];
    [userProfilesQuery whereKey:@"email" containsString:@"cabforward.com"];
    [self updateModelObjectsWithQuery:userProfilesQuery completion:completion];
    
}


- (NSArray*) findConnectionsWithFullName:(NSString*)fullName {
    
    PFQuery *userSettingsWithEveryonePrivacyQuery = [PFQuery queryWithClassName:@"UserSettings"];
    [userSettingsWithEveryonePrivacyQuery whereKey:@"profilePrivacy" equalTo:@(GIUserPrivacySettingEveryone)];
    
    PFQuery *userProfileQuery = [PFQuery queryWithClassName:@"UserProfile"];
    [userProfileQuery whereKey:@"fullName" matchesRegex:[NSString stringWithFormat:@"%@",fullName] modifiers:@"i"];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"userSettings" matchesQuery:userSettingsWithEveryonePrivacyQuery];
    [userQuery whereKey:@"userProfile" matchesQuery:userProfileQuery];
    [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    NSArray *parseUsers = [userQuery findObjects];
    
    //    NSArray *users = _.arrayMap(parseUsers, ^(PFObject *parseObject) {
    //        return [GIUser parseModelWithParseObject:parseObject];
    //    });
    
    return parseUsers;
}

- (void) findConnectionsWithFullNamesArray:(NSArray*)fullNames completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        
        PFQuery *userSettingsWithEveryonePrivacyQuery = [PFQuery queryWithClassName:@"UserSettings"];
        [userSettingsWithEveryonePrivacyQuery whereKey:@"profilePrivacy" equalTo:@(GIUserPrivacySettingEveryone)];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName IN %@", fullNames];
        PFQuery *userProfileQuery = [PFQuery queryWithClassName:@"UserProfile" predicate:predicate];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"userSettings" matchesQuery:userSettingsWithEveryonePrivacyQuery];
        [userQuery whereKey:@"userProfile" matchesQuery:userProfileQuery];
        [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        userQuery.limit = 1000;
        
        [self updateModelObjectsWithQuery:userQuery completion:completion];
    }];
}

- (void) findConnectionsWithFullName:(NSString*)fullName completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        PFQuery *userSettingsWithEveryonePrivacyQuery = [PFQuery queryWithClassName:@"UserSettings"];
        [userSettingsWithEveryonePrivacyQuery whereKey:@"profilePrivacy" equalTo:@(GIUserPrivacySettingEveryone)];
        
        PFQuery *userProfileQuery = [PFQuery queryWithClassName:@"UserProfile"];
        [userProfileQuery whereKey:@"fullName" matchesRegex:[NSString stringWithFormat:@"%@",fullName] modifiers:@"i"];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"userSettings" matchesQuery:userSettingsWithEveryonePrivacyQuery];
        [userQuery whereKey:@"userProfile" matchesQuery:userProfileQuery];
        [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        [self updateModelObjectsWithQuery:userQuery completion:completion];
    }];
}

- (void)findConnectionsByEmail:(NSString *)email completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        [userQuery whereKey:@"username" matchesRegex:[NSString stringWithFormat:@"^%@$",email] modifiers:@"i"];
        [self updateModelObjectsWithQuery:userQuery completion:completion];
    }];
}

- (void)findConnectionsWithEmailsArray:(NSArray *)emails completion:(MYCompletionBlock)completion {
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        PFQuery *userSettingsWithEmailPrivacyQuery = [PFQuery queryWithClassName:@"UserSettings"];
        [userSettingsWithEmailPrivacyQuery whereKey:@"profilePrivacy" equalTo:@(GIUserPrivacySettingEmailOnly)];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email IN %@", emails];
        PFQuery *userQuery = [PFUser queryWithPredicate:predicate];
        [userQuery whereKey:@"userSettings" matchesQuery:userSettingsWithEmailPrivacyQuery];
        [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        [self updateModelObjectsWithQuery:userQuery completion:completion];
    }];

}

- (void)findConnectionsWithEmail:(NSString *)email completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        PFQuery *userSettingsWithEmailPrivacyQuery = [PFQuery queryWithClassName:@"UserSettings"];
        [userSettingsWithEmailPrivacyQuery whereKey:@"profilePrivacy" equalTo:@(GIUserPrivacySettingEmailOnly)];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"userSettings" matchesQuery:userSettingsWithEmailPrivacyQuery];
        [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
        [userQuery whereKey:@"email" matchesRegex:[NSString stringWithFormat:@"^%@$",email] modifiers:@"i"];
        [self updateModelObjectsWithQuery:userQuery completion:completion];
    }];
}

- (void)connectionsWithCompletionBlock:(MYCompletionBlock)completionBlock
{
    if (completionBlock)
    {
        [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
            PFUser *currentUser = [GIUserStore sharedStore].currentUser.parseUser;
            PFRelation *connectionsRelation = [currentUser relationForKey:@"connections"];
            PFQuery *connectionsQuery = [connectionsRelation query];
            connectionsQuery.limit = 500;
            [self updateModelObjectsWithQuery:connectionsQuery completion:completionBlock];
            //
            //            NSError *error = nil;
            //            NSArray *connections = [connectionsQuery findObjects:&error];
            //
            //            completionBlock(self,(error == nil),error,connections);
        }];
    }
}

- (void)removeConnection:(GIUser*)connection withCompletionBlock:(MYCompletionBlock)completionBlock
{
    if (connection != nil)
    {
        [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
            [[[PFUser currentUser] relationForKey:@"connections"] removeObject:connection.parseUser];
            NSError *error = nil;
            [[PFUser currentUser] save:&error];
            
            NSAssert(!error, @"error in removing association between food item and profile!");
            
            if (completionBlock) {
                completionBlock(self, error == nil, error, connection);
            }
        }];
    }
    else
    {
        if (completionBlock) {
            completionBlock(self, NO, nil, connection);
        }
    }
}
@end
