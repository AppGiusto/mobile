/*
 *	GIUserProfileStore.m
 *	Pods
 *
 *	Created by Vincil Bishop on 9/3/14.
 *
 */

#import "GIUserProfileStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"
#import "GIModel.h"

@interface GIUserProfileStore()

@end

@implementation GIUserProfileStore

+ (GIUserProfileStore *) sharedStore
{
	static GIUserProfileStore *_sharedStore = nil;
	
	if (!_sharedStore)
	{
		_sharedStore = [[GIUserProfileStore alloc] initSingleton];
	}
	
	return _sharedStore;
}

- (id) initSingleton
{
	if ((self = [super init]))
	{
		// Initialization code here.
        self.modelObjectType = [GIUserProfile class];
        
        // refresh when users have changed
        [RACObserve([GIUserStore sharedStore], currentUser) subscribeNext:^(GIUser *currentUser) {
            
            if (currentUser) {
                DDLogVerbose(@"GIUserProfileStore observed users changing...");
                
                PFObject *userProfile = currentUser.parseUser[@"userProfile"];
                
                PFQuery *profileQuery = [PFQuery queryWithClassName:@"UserProfile" predicate:[NSPredicate predicateWithFormat:@"objectId == %@", userProfile.objectId]];
                
                [self updateModelObjectsWithQuery:profileQuery completion:NULL];
            }
        }];
        
        /*
        // refresh when users have changed

        [RACObserve([GIUserProfileStore sharedStore], modelObjects) subscribeNext:^(NSArray *dependents) {
            
            if (dependents.count) {
                
                NSMutableArray *queries = [NSMutableArray new];
                
                DDLogVerbose(@"GIUserProfileStore observed GIDependentStore changes...");
                
                [dependents enumerateObjectsUsingBlock:^(GIUserProfile *dependent, NSUInteger idx, BOOL *stop) {
                    
                    NSError *dependentError = nil;
                    
                    if (dependentError) {
                        DDLogVerbose(@"dependentError:%@",[dependentError description]);
                    }
                    
                    
                    PFObject *userProfile = dependent.parseObject[@"userProfile"];
                    
                    if (userProfile) {
                        PFQuery *profileQuery = [PFQuery queryWithClassName:@"UserProfile" predicate:[NSPredicate predicateWithFormat:@"objectId == %@", userProfile.objectId]];

                        [queries addObject:profileQuery];
                    }
                    
                }];
                
                if (queries.count) {
                    PFQuery *query = [PFQuery orQueryWithSubqueries:queries];
                    [self updateModelObjectsWithQuery:query completion:NULL];
                }
            }
        }];
        
        
        
        // refresh when dependents have changed
        [RACObserve([GIDependentStore sharedStore], modelObjects) subscribeNext:^(NSArray *dependentObjects) {
            
            NSMutableArray *queries = [NSMutableArray new];
            
            [dependentObjects enumerateObjectsUsingBlock:^(GIDependent *updatedDependent, NSUInteger idx, BOOL *stop) {
                
                PFQuery *query = [updatedDependent.parseObject relationForKey:@"userProfile"];
                
                [queries addObject:query];
                
            }];
            
            PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:queries];
            
            [self updateModelObjectsWithQuery:compoundQuery completion:NULL];
            
        }];
         */
        
        
	}
	
	return self;
}

#pragma mark - Store Verbds -

- (BOOL) createUserProfileWithUser:(GIUser*)user fullName:(NSString*)fullName location:(NSString*)location photo:(UIImage *)photo {
    
    BOOL isCreated = YES;
    
        GIUserProfile *userProfile = [GIUserProfile parseModel];
        userProfile.fullName = fullName;
        userProfile.location = (location) ? location : @"";
        
        NSError *error = nil;
        [userProfile associateUser:user];
    
        [userProfile.parseObject save:&error];
        
        NSAssert(!error,@"error in user profile creation!");
        
        [GIUserStore sharedStore].currentUser.parseUser[@"userProfile"] = userProfile.parseObject;
        
        NSAssert([GIUserStore sharedStore].currentUser,@"must have a current user...");
        
        [[GIUserStore sharedStore].currentUser.parseUser save:&error];
        
        NSAssert(!error,@"error in associating user profile with user!");
        
        if (photo) {
            PFFile *photoFile = [PFFile fileWithData:UIImagePNGRepresentation(photo) contentType:@"png"];
            
            userProfile.parseObject[@"photo"] = photoFile;
            
            [userProfile.parseObject save:&error];
            
            NSAssert(!error,@"error in saving user's profile image!");
            
            userProfile.photoURL = [NSURL URLWithString:photoFile.url];
            
            [userProfile.parseObject save:&error];
            
            NSAssert(!error, @"error in saving user's profile image url!");
            
        }
    
    if (error) {
        isCreated = NO;
    }
    
    return isCreated;
}


- (void) createUserProfileWithUser:(GIUser*)user fullName:(NSString*)fullName location:(NSString*)location photo:(UIImage *)photo completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        GIUserProfile *userProfile = [GIUserProfile parseModel];
        userProfile.fullName = fullName;
        userProfile.location = (location) ? location : @"";
        
        NSError *error = nil;
        [userProfile associateUser:user];
        [userProfile.parseObject save:&error];
        
        NSAssert(!error,@"error in user profile creation!");
        
        [GIUserStore sharedStore].currentUser.parseUser[@"userProfile"] = userProfile.parseObject;
        
        NSAssert([GIUserStore sharedStore].currentUser,@"must have a current user...");
        
        [[GIUserStore sharedStore].currentUser.parseUser save:&error];
        
        NSAssert(!error,@"error in associating user profile with user!");
        
        if (photo) {
            PFFile *photoFile = [PFFile fileWithData:UIImagePNGRepresentation(photo) contentType:@"png"];
            
            userProfile.parseObject[@"photo"] = photoFile;
            
            [userProfile.parseObject save:&error];
            
            NSAssert(!error,@"error in saving user's profile image!");
            
            userProfile.photoURL = [NSURL URLWithString:photoFile.url];
            
            [userProfile.parseObject save:&error];
            
            NSAssert(!error, @"error in saving user's profile image url!");
            
            if (completion) {
                completion(self, error == nil, error, userProfile);
            }
        }
        else if (completion)
        {
            completion(self,error == nil,error,userProfile);
        }

    }];
}

- (void) saveUserProfile:(GIUserProfile *)userProfile fullName:(NSString *)fullName location:(NSString *)location photo:(UIImage *)photo birthday:(NSDate *)birthday completion:(MYCompletionBlock)completion
{
    [self saveUserProfileWithEmail:userProfile fullName:fullName email:nil location:location photo:photo birthday:birthday completion:completion];
}

- (void) saveUserProfileWithEmail:(GIUserProfile *)userProfile fullName:(NSString *)fullName email:(NSString*)email location:(NSString *)location photo:(UIImage *)photo birthday:(NSDate *)birthday completion:(MYCompletionBlock)completion {
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        userProfile.fullName = fullName;

        if (email) {
            GIUser* currentUser = [GIUserStore sharedStore].currentUser;
            currentUser.email = email;
            [currentUser.parseUser save];
        }
        
        if (location) {
            userProfile.location = location;
        }
        
        if (birthday) {
            userProfile.birthDate = birthday;
        }
        
        NSError *error = nil;
        
        [userProfile.parseObject save:&error];
        
        NSAssert(!error,@"error in user profile update!");
        
        if (photo) {
            PFFile *photoFile = [PFFile fileWithData:UIImagePNGRepresentation(photo) contentType:@"png"];
            
            userProfile.parseObject[@"photo"] = photoFile;
            
            [userProfile.parseObject save:&error];
            
            NSAssert(!error,@"error in saving user's profile image!");
            
            userProfile.photoURL = [NSURL URLWithString:photoFile.url];
            
            [userProfile.parseObject save:&error];
            
            NSAssert(!error, @"error in saving user's profile image url!");
            
            if (completion) {
                completion(self, error == nil, error, userProfile);
            }
        }
        else if (completion)
        {
            completion(self,error == nil,error,userProfile);
        }
        
    }];
}


- (void) deleteUserProfile:(GIUserProfile *)userProfile completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        
        [userProfile.parseObject delete:&error];
        
        NSAssert(!error,@"error deleting profile!");
        
        if (completion) {
            completion(self, error == nil, error, nil);
        }
    }];
}

#pragma mark Dependent
- (void) createDependentForUser:(GIUser *)user name:(NSString *)name birthday:(NSDate *)birthday photo:(UIImage *)photo completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        GIUserProfile *dependent = [GIUserProfile parseModel];
        dependent.fullName = name;
        dependent.birthDate = birthday;
        
        NSError *error = nil;
        
        [dependent.parseObject save:&error];
        
        NSAssert(!error,@"error in dependent creation!");
        
        [[[GIUserStore sharedStore].currentUser.parseUser relationForKey:@"dependents"] addObject:dependent.parseObject];
        
        NSAssert([GIUserStore sharedStore].currentUser,@"must have a current user...");
        
        [[GIUserStore sharedStore].currentUser.parseUser save:&error];
        
        NSAssert(!error, @"error in associating dependent with user!");
        
        if (photo) {
            PFFile *photoFile = [PFFile fileWithData:UIImagePNGRepresentation(photo) contentType:@"png"];
            
            dependent.parseObject[@"photo"] = photoFile;
            
            [dependent.parseObject save:&error];
            
            NSAssert(!error,@"error in saving user's profile image!");
            
            dependent.photoURL = [NSURL URLWithString:photoFile.url];
            
            [dependent.parseObject save:&error];
            
            NSAssert(!error, @"error in saving user's profile image url!");
        }

        if (completion) {
            completion(self, error == nil, error, dependent);
        }
    }];
}


- (void) saveDependent:(GIUserProfile *)dependent name:(NSString *)name birthday:(NSDate *)birthday photo:(UIImage *)photo completion:(MYCompletionBlock)completion
{
    [[GIUserProfileStore sharedStore] saveUserProfile:dependent fullName:name location:dependent.location photo:photo birthday:birthday completion:^(id sender, BOOL success, NSError *error, id result) {
        if (completion) {
            completion(self, error == nil, error, dependent);
        }
    }];
}


- (void) deleteDependent:(GIUserProfile *)dependent completion:(MYCompletionBlock)completion
{
    [[GIUserProfileStore sharedStore] deleteUserProfile:dependent completion:^(id sender, BOOL success, NSError *error, id result) {
                
        if (completion) {
            completion(self, error == nil, error, nil);
        }
    }];
}
@end
