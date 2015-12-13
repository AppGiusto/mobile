//
//  GIModelObjectBase.h
//  Pods
//
//  Created by Vincil Bishop on 8/31/14.
//
//

#import <UIKit/UIKit.h>
#import "ParseModel.h"
#import "ParseModelUser.h"
#import "MYParseableModelObject.h"

@interface GIModelObjectBase : ParseModel<MYParseableModelObject>

@property (nonatomic,strong) NSString *objectId;

@end
