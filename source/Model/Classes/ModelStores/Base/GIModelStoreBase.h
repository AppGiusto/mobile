//
//  GIModelStoreBase.h
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import <Foundation/Foundation.h>

@interface GIModelStoreBase : NSObject

/**
 *  An array of model objects persisted in memory.
 */
@property (nonatomic,strong) NSArray *modelObjects;

/**
 *  The GIModelObject type that the store services. 
 
    @discussion Set in the initSingleton method of each store.
 */
@property (nonatomic) Class modelObjectType;

/**
 *  An operation queue to schedule all operations from store instances.
 *
 *  @return the background operation queue used to execute operations for all store instances.
 */
+ (NSOperationQueue*) backgroundOperationQueue;

/**
 *  Updates the modelObjects array using the supplied query.
 *
 *  @param query           The PFQuery used to perform the update.
 *  @param completionBlock A block to execute when the operation completes.
 
 *  @discussion The method takes the results from the query and combines them with the existing modelObjects. modelObjects existing in the array are replaced if an updated version is returned from this operation. Objects are not removed from the modelObject array if they are not returned from this operation.
 */
- (void) updateModelObjectsWithQuery:(PFQuery*)query completion:(MYCompletionBlock)completionBlock;

@end
