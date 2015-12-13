//
//  GIModel.m
//  Pods
//
//  Created by Vincil Bishop on 8/21/14.
//
//

#import "GIModel.h"
#import "GIModelStores.h"

static GIModel *_sharedModel;

@implementation GIModel

+ (GIModel*) sharedModel
{
    if (!_sharedModel) {
        _sharedModel = [[GIModel alloc] init];
    }
    
    return _sharedModel;
}

+ (void) setupModel
{
    [GIModel sharedModel];
    
    
}

- (id) init
{
    self = [super init];
    
    if (self) {
        
        [self setupParse];
        [self setupStores];
    }
    
    return self;
}

- (void) setupParse
{
//    [Parse setApplicationId:kParse_AppID clientKey:kParse_ClientKey];
//    [PFFacebookUtils initializeFacebook];
}

- (void) setupStores
{
    [GIUserStore sharedStore];
    [GIUserSettingsStore sharedStore];
    [GIUserProfileStore sharedStore];
    [GITableStore sharedStore];
    [GIFoodItemStore sharedStore];
    [GIConnectionRequestStore sharedStore];
}

@end
