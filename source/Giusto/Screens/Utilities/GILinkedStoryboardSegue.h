//
//  GILinkedStoryboardSegue.h
//  Giusto
//
//  Created by Eli Hini on 2014-10-21.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GILinkedStoryboardSegue : UIStoryboardSegue
+ (UIViewController*)sceneWithName:(NSString*)sceneName inStoryboardNamed:(NSString*)storyboardName;
@end
