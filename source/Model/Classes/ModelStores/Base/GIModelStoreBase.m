//
//  GIModelStoreBase.m
//  Pods
//
//  Created by Vincil Bishop on 9/8/14.
//
//

#import "GIModelStoreBase.h"
#import "GIModelObjectBase.h"


@implementation GIModelStoreBase

static NSOperationQueue *_backgroundOperationQueue;

- (id) init
{
    self = [super init];
    if (self) {
        _modelObjects = [NSArray new];
    }
    
    return self;
}

+ (NSOperationQueue*) backgroundOperationQueue
{
    if (!_backgroundOperationQueue) {
        _backgroundOperationQueue = [NSOperationQueue new];
        _backgroundOperationQueue.maxConcurrentOperationCount = 4;
    }
    return _backgroundOperationQueue;
}

- (void) updateModelObjectsWithQuery:(PFQuery*)query completion:(MYCompletionBlock)completionBlock
{
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    //query.parseClassName = [self.modelObjectType parseModelClass];

    // Using the backgroundOperationQueue
    // Submit block jobs as synchronous operations
    [[[self class] backgroundOperationQueue] addOperationWithBlock:^{
        
        // Update model objects from the parse back end
        NSError *error = nil;

        NSArray *result = [query findObjects:&error];
        if (error) {
            DDLogError(@"updateModelObjectsWithQuery:error:%@:%@",[error localizedDescription],[error userInfo]);
        } else {
            
            if (result) {
                
                NSArray *existingModelObjects = @[];
                
                if (self.modelObjects) {
                    existingModelObjects = _.filter(self.modelObjects,^BOOL(GIModelObjectBase *modelObject){
                        
                        // See if the parseObject is in the results.
                        // Filter the results array using the object's Id
                        NSArray *updatedObject = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId = %@",modelObject.objectId]];
                        // If the object exists in the results array, return no
                        // else return yes
                        return updatedObject == nil;
                    });
                }
                
                // Map results array to ParseModel objects
                NSMutableArray *parseModelResults = [NSMutableArray new];
                
                if (result) {
                    parseModelResults = [_.arrayMap(result,^(id parseEntity){
                        
                        [parseEntity fetchIfNeeded];
                        
                        if ([parseEntity isKindOfClass: [PFUser class]])
                        {
                            return [self.modelObjectType parseModelUserWithParseUser:parseEntity];
                        }
                        else
                        {
                            return [self.modelObjectType parseModelWithParseObject:parseEntity];
                        }
                        
                    }) mutableCopy];
                }
                
                // Combine the updatedModelObjects with the parseModelResults;
                [parseModelResults addObjectsFromArray:existingModelObjects];
                
                @synchronized(_modelObjects) {
                    // Populate self.modelObjects on completion
                    //_modelObjects = parseModelResults;
                    
                    self.modelObjects = parseModelResults;
                }
            }
        }
        
        if (completionBlock) {
            completionBlock(self,error == nil,error,self.modelObjects);
        }
    }];
}

@end
