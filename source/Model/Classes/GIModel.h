//
//  GIModel.h
//  Pods
//
//  Created by Vincil Bishop on 8/21/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <CoreData/CoreData.h>

#import "Underscore.h"
#import "DateTools.h"
#import "NSDate+MTDates.h"
#import "MyiOSHelpers.h"
#import "CoreData+MagicalRecord.h"
#import "ParseModel.h"

#import "GIModelObjects.h"
#import "GIModelLogic.h"
#import "GIModelStores.h"
#import "GIModelUtil.h"
#import "GIModelDefines.h"

#ifndef _
#define _ Underscore
#endif

@interface GIModel : NSObject

+ (GIModel*) sharedModel;

+ (void) setupModel;

@end
