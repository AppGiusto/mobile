/*
 *	GIConnectionRequestStore.h
 *	Pods
 *	
 *	Created by Vincil Bishop on 9/3/14.
 *	
 */

#import <Foundation/Foundation.h>
#import "GIModelStoreBase.h"
#import "GIModel.h"

static NSString *const  kGIConnectionRequestStoreDidAcceptConnectionRequest = @"com.giusto.connectionrequeststore.didacceptrequest";
static NSString *const  kGIConnectionRequestStoreDidRejectConnectionRequest = @"com.giusto.connectionrequeststore.didrejectrequest";

@interface GIConnectionRequestStore : GIModelStoreBase

+ (GIConnectionRequestStore *) sharedStore;

- (void) connectionRequestsWithCompletetionBlock:(MYCompletionBlock)completionBlock;
- (void) pendingConnectionRequestsReceivedWithCompletionBlock:(MYCompletionBlock)completionBlock;
- (void) sendConnectionRequest:(GIConnectionRequest*)connectionRequest withCompletionBlock:(MYCompletionBlock)completion;
- (void) rejectConnectionRequest:(GIConnectionRequest*)connectionRequest withCompletionBlock:(MYCompletionBlock)completionBlock;
- (void) acceptConnectionRequest:(GIConnectionRequest*)connectionRequest withCompletionBlock:(MYCompletionBlock)completionBlock;
- (void) evaluateAndFinalizeSentConnectionRequestsWithCompletionBlock:(MYCompletionBlock)completionBlock;
@end