//
//  GIFindContactsViewController.m
//  Giusto
//
//  Created by Nielson Rolim on 8/7/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIFindContactsViewController.h"
#import "GIFindContactsTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@import AddressBook;

typedef void (^GIConnectionsSearchResultCountUpdateBlock)(id sender, int numberOfItemsFound);

@interface GIFindContactsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (nonatomic, strong) NSMutableArray* allContacts;
@property (nonatomic, strong) NSMutableDictionary* usersFound;
@property (nonatomic, strong) NSMutableDictionary* connections;

@end

@implementation GIFindContactsViewController

- (NSMutableArray*) allContacts {
    if (!_allContacts) {
        _allContacts = [NSMutableArray new];
    }
    return _allContacts;
}

- (NSMutableDictionary*) usersFound {
    if (!_usersFound) {
        _usersFound = [NSMutableDictionary new];
    }
    return _usersFound;
}

- (NSMutableDictionary*) connections {
    if (!_connections) {
        _connections = [NSMutableDictionary new];
    }
    return _connections;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Find Contacts";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    NSLog(@"currentUser.id: %@", [GIUserStore sharedStore].currentUser.parseUser.username);
    
    if ([self.searchType isEqualToString:@"addressBook"]) {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
            //1
            //NSLog(@"Denied!");
        } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            //2
            //NSLog(@"Authorized!");

            [self loadContacts];
            
        } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
            //3
            //NSLog(@"Not determined");
            
            ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted){
                        //4
                        //NSLog(@"Just denied!");
                        return;
                    }
                    //5
                    //NSLog(@"Just authorized!");

                    [self loadContacts];
                });
            });
        }

    } else if ([self.searchType isEqualToString:@"facebook"]) {
        
        if (![FBSDKAccessToken currentAccessToken]) {
            if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Link to Facebook?"
                                                                message:@"Do you want to link your Giusto account to your Facebook account?\nIf you have another Giusto account linked to your Facebook account, this action will unlink it."
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"No", @"Yes", nil];
                [alert show];
            }
        } else {
            [self loadFacebookFriends];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) hideProgress {
    [self.view hideProgressHUD];
}

- (void) loadContacts {
    //NSLog(@"Loading contacts...");
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, nil);
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    
    for (id record in allContacts){
        
        NSMutableDictionary *friend = [NSMutableDictionary dictionary];
        
        ABRecordRef contact = (__bridge ABRecordRef)record;
        
        [friend setObject:[NSString stringWithFormat:@"%@", (__bridge NSString *)ABRecordCopyCompositeName(contact)] forKey:@"fullName"];
        
        
        NSMutableArray *allEmails = [NSMutableArray new];
        ABMultiValueRef emails = ABRecordCopyValue(contact, kABPersonEmailProperty);
        for (CFIndex j=0; j < ABMultiValueGetCount(emails); j++) {
            NSString* email = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emails, j);
            [allEmails addObject:email];
        }
        CFRelease(emails);
        [friend setObject:allEmails forKey:@"emails"];
        
        
        NSMutableArray *allPhones = [NSMutableArray new];
        ABMultiValueRef phones = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        for (CFIndex j=0; j < ABMultiValueGetCount(phones); j++) {
            NSString* phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j);
            [allPhones addObject:phone];
        }
        CFRelease(phones);
        [friend setObject:allPhones forKey:@"phones"];
        
        [self.allContacts addObject:friend];
    }
    
    [self findUsersFormContacts];
}

- (void) findUsersFormContacts {
    [self.view showProgressHUD];
    
    NSLog(@"self.allContacts.count: %d", (int)self.allContacts.count);
    
    NSMutableArray* allFullNames = [NSMutableArray new];
    NSMutableArray* allEmails = [NSMutableArray new];
    
    for (NSDictionary* contact in self.allContacts) {
        NSString* fullName = [contact objectForKey:@"fullName"];
        [allFullNames addObject:fullName];
        
        NSArray* emails = [contact objectForKey:@"emails"];
        for (NSString* email in emails) {
            [allEmails addObject:email];
        }
    }
    
    [[GIUserStore sharedStore] findConnectionsWithFullNamesArray:allFullNames completion:^(id sender, BOOL success, NSError *error, NSArray *users) {
        if (success) {
            
            for (GIUser* user in users) {
                [self.usersFound setObject:user forKey:user.username];
            }
            
            [[GIUserStore sharedStore] findConnectionsWithEmailsArray:allEmails completion:^(id sender, BOOL success, NSError *error, NSArray *usersByEmail) {
                if (success) {
                    for (GIUser* user in usersByEmail) {
                        [self.usersFound setObject:user forKey:user.username];
                    }
                    
                    [[GIUserStore sharedStore] connectionsWithCompletionBlock:^(id sender, BOOL success, NSError *error, NSArray* connections) {
                        //
                        for (GIUser* connection in connections) {
                            [self.connections setObject:connection forKey:connection.parseUser.objectId];
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            //Run UI Updates
                            [self.contactsTableView reloadData];
                            [self.view hideProgressHUD];
                        });
                        
                    }];
                }
            }];
        }
    }];
}

- (void) linkUserToFacebook {
    NSArray *linkUser = @[@"public_profile", @"email", @"user_friends"];
    [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:linkUser block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Woohoo, user is linked with Facebook!");
            
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name,email,location" forKey:@"fields"];
            
            FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends"
                                                                                  parameters:parameters];
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    NSString *facebookId = userData[@"id"];
                    
                    GIUser* currentUser = [GIUserStore sharedStore].currentUser;
                    currentUser.facebookId = facebookId;
                    [currentUser.parseUser save];
                    
                    [UIAlertView showWithTitle:@"Account linked!"
                                       message:@"Your Giusto Account is now linked to your Facebook account."
                             cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                             otherButtonTitles:nil tapBlock:nil];

                    
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
            }];
            
        } else {
            [UIAlertView showWithTitle:@"Account linked!"
                               message:@"Your Giusto Account is now linked to your Facebook account.\nYour other account has been unlinked."
                     cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                     otherButtonTitles:nil tapBlock:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}


- (void) loadFacebookFriends {
    
    [self.view showProgressHUD];

    // Issue a Facebook Graph API request to get your user's friend list
    
    if ([FBSDKAccessToken currentAccessToken]) {
    
        FBSDKGraphRequest *friendsRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends"
                                                                              parameters:nil];
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        [connection addRequest:friendsRequest
             completionHandler:^(FBSDKGraphRequestConnection *innerConnection, NSDictionary *result, NSError *error) {
                 
                 // result will contain an array with your user's friends in the "data" key
                 NSArray *friendObjects = [result objectForKey:@"data"];
                 
                 NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
                 // Create a list of friends' Facebook IDs
                 for (NSDictionary *friendObject in friendObjects) {
                     //NSLog(@"[friendObject objectForKey:@id]: %@", [friendObject objectForKey:@"id"]);
                     [friendIds addObject:[friendObject objectForKey:@"id"]];
                 }
                 
                 // Construct a PFUser query that will find friends whose facebook ids
                 // are contained in the current user's friend list.
                 PFQuery *friendQuery = [PFUser query];
                 [friendQuery whereKey:@"facebookId" containedIn:friendIds];
                 
                 // findObjects will return a list of PFUsers that are friends
                 // with the current user
                 //NSArray *friendUsers = [friendQuery findObjects];
                 
                 [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                     // objects contains all of the User objects, and their associated Weapon objects, too
                     
                     for (PFUser* parseUser in objects) {
                         GIUser* user = [GIUser parseModelUserWithParseUser:parseUser];
                         [self.usersFound setObject:user forKey:user.username];
                     }
                     
                     [[GIUserStore sharedStore] connectionsWithCompletionBlock:^(id sender, BOOL success, NSError *error, NSArray* connections) {
                         //
                         for (GIUser* connection in connections) {
                             [self.connections setObject:connection forKey:connection.parseUser.objectId];
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^(void){
                             //Run UI Updates
                             [self.contactsTableView reloadData];
                             [self.view hideProgressHUD];
                         });
                         
                     }];
                     
                 }];
             }];
        //start the actual request
        [connection start];
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.usersFound.allKeys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GIFindContactsTableViewCell *cell = (GIFindContactsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];

    GIUser* user = [self.usersFound.allValues objectAtIndex:indexPath.row];
    

    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 29)];
    btnImageView.image = [UIImage imageNamed:@"SendConnectionRequest"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"requestee = %@ AND requestor = %@", user.parseUser, [GIUserStore sharedStore].currentUser.parseUser];
    PFQuery *query = [PFQuery queryWithClassName:[GIConnectionRequest parseModelClass] predicate:predicate];
    
    NSArray *parseConnections = [query findObjects];
    NSArray *connections = _.arrayMap(parseConnections, ^(PFObject *parseObject) {
        return [GIConnectionRequest parseModelWithParseObject:parseObject];
    });
    
    //NSLog(@"connections: %ld", (long)connections.count);
    
    if (connections.count > 0) {
        GIConnectionRequest* conn = [connections firstObject];
        //NSLog(@"conn.requestee: %@", conn.requestee.objectId);
        [self.connections setObject:conn forKey:conn.requestee.objectId];
    }
    
    if ([self.connections.allKeys containsObject:user.parseUser.objectId]) {
        btnImageView.image = [UIImage imageNamed:@"connectionRequestSent"];
    }

    cell.accessoryView = btnImageView;
    
    cell.nameLabel.text = user.userProfile.fullName;
    
    [cell.photoImageView setRoundCorners];
    NSString *photoURL = [NSString stringWithFormat:@"%@", user.userProfile.photoURL];
    [cell.photoImageView setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:[UIImage imageNamed:@"AvatarImagePlaceholder"]];
    
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
    
    GIUser* user = [self.usersFound.allValues objectAtIndex:indexPath.row];
    

    if (![self.connections.allKeys containsObject:user.parseUser.objectId]) {
        
        [self.connections setObject:user forKey:user.parseUser.objectId];
        
        GIConnectionRequest *connectionRequest = [[GIConnectionRequest alloc] initWithParseObject:[[PFObject alloc] initWithClassName:@"ConnectionRequest"]];
        connectionRequest.parseObject[@"requestor"] = [GIUserStore sharedStore].currentUser.parseUser;
        connectionRequest.parseObject[@"requestee"] = user.parseUser;
        
        [self.view showProgressHUD];
        [[GIConnectionRequestStore sharedStore] sendConnectionRequest:connectionRequest withCompletionBlock:^(id sender, BOOL success, NSError *error, id result) {
            
            if (success)
            {
                //NSLog(@"Did Send connection Request");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.connections setObject:user forKey:user.username];
                    [self.view hideProgressHUD];
                    UIImageView* btnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 29)];
                    btnImageView.image = [UIImage imageNamed:@"connectionRequestSent"];
                    cell.accessoryView = btnImageView;
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideProgressHUD];
                });

            }
        }];

    }
    
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


#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            [self linkUserToFacebook];
            break;
    }
}

- (BOOL)isValidEmail:(NSString *)email
{
    NSString *regex1 = @"\\A[a-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,}\\z";
    NSString *regex2 = @"^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*";
    NSPredicate *test1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [test1 evaluateWithObject:email] && [test2 evaluateWithObject:email];
}


@end
