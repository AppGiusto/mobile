//
//  GIConnectionRequest.h
//  Pods
//
//  Created by Vincil Bishop on 9/3/14.
//
//

#import "GIModelObjectBase.h"

typedef NS_ENUM(NSUInteger, GIConnectionRequestStatus) {
    GIConnectionRequestStatusPending,
    GIConnectionRequestStatusAccepted,
    GIConnectionRequestStatusRejected,
};

@interface GIConnectionRequest : GIModelObjectBase

@property (nonatomic,strong) PFUser *requestor;
@property (nonatomic,strong) PFUser *requestee;
@property (nonatomic,strong) NSNumber *status;

+ (NSString *)parseModelClass;

@end
