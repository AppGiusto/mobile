/*
 *	GITableStore.m
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import "GITableStore.h"
#import "GIModelObjects.h"
#import "GIModelStores.h"

@interface GITableStore()

@end

@implementation GITableStore

+ (GITableStore *) sharedStore
{
	static GITableStore *_sharedStore = nil;
	
	if (!_sharedStore)
	{
		_sharedStore = [[GITableStore alloc] initSingleton];
	}
	
	return _sharedStore;
}

- (id) initSingleton
{
	if ((self = [super init]))
	{
		// Initialization code here.
        self.modelObjectType = [GITable class];
        
	}
	
	return self;
}


- (void) createTableForUser:(GIUser *)user name:(NSString *)name withUserProfiles:(NSArray *)userProfiles completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        GITable *table = [GITable parseModel];
        table.name = name;
        
        NSError *error = nil;
        
        [table.parseObject save:&error];
        
        NSAssert(!error,@"error in table creation!");
        
        for (GIUserProfile *userProfile in userProfiles) {
            [[table.parseObject relationForKey:@"userProfiles"] addObject:userProfile.parseObject];
        }
        
        [table.parseObject save:&error];
        
        NSAssert(!error, @"error in associating user profile with table!");
        
        [[[GIUserStore sharedStore].currentUser.parseUser relationForKey:@"tables"] addObject:table.parseObject];
        
        NSAssert([GIUserStore sharedStore].currentUser, @"must have a current user...");
        
        [[GIUserStore sharedStore].currentUser.parseUser save:&error];
        
        NSAssert(!error, @"error in associating table with user!");
    
        
        if (completion) {
            completion(self, error == nil, error, table);
        }
    }];
}


- (void) saveTable:(GITable *)table name:(NSString *)name withAddedProfiles:(NSArray *)addedProfiles andRemovedProfiles:(NSArray *)removedProfiles completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        
        for (GIUserProfile *userProfile in removedProfiles) {
            [[table.parseObject relationForKey:@"userProfiles"] removeObject:userProfile.parseObject];
        }
        
        [table.parseObject save:&error];
        
        NSAssert(!error, @"error in disassociating user profile with table!");
        
        for (GIUserProfile *userProfile in addedProfiles) {
            [[table.parseObject relationForKey:@"userProfiles"] addObject:userProfile.parseObject];
        }
        
        [table.parseObject save:&error];
        
        NSAssert(!error, @"error in associating user profile with table!");
        
        table.name = name;
        
        [table.parseObject save:&error];
        
        NSAssert(!error, @"error updating table name!");
        
        if (completion) {
            completion(self, error == nil, error, table);
        }
        
    }];
}


- (void) deleteTable:(GITable *)table completion:(MYCompletionBlock)completion
{
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        NSError *error = nil;
        
        [table.parseObject delete:&error];
        
        NSAssert(!error, @"error deleting table!");
        
        if (completion) {
            completion(self, error == nil, error, nil);
        }
    }];
}

@end
