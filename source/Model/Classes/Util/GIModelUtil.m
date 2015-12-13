//
//  GIModelUtil.m
//  Pods
//
//  Created by Vincil Bishop on 9/14/14.
//
//

#import "GIModelUtil.h"
#import "GIModelLogic.h"

@implementation GIModelUtil

+ (void) seedModelWithCompletion:(MYCompletionBlock)completion
{
    /*
     PFUser *user = [PFUser user];
     user.username = @"test";
     user.password = @"test";
     user.email = @"email@example.com";
     
     // other fields can be set just like with PFObject
     user[@"phone"] = @"415-392-0202";
     
     [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (!error) {
     // Hooray! Let them use the app now.
     } else {
     NSString *errorString = [error userInfo][@"error"];
     // Show the errorString somewhere and let the user try again.
     }
     }];
     
     */
    
    //GIUser *user = [GIUser parseModelUserWithParseUser:[PFUser user]];
    
    
    
    GIUser *user = [GIUser parseModel];
    user.parseUser.username = @"DevUser";
    user.parseUser.email = @"devuser@devuser.com";
    user.parseUser.password = @"supersecret";
    NSError *error = nil;
    
    [user.parseUser signUp:&error];
    
    
    
    if (completion) {
        completion(self,error == nil,error,self);
    }
    

    
}

@end
