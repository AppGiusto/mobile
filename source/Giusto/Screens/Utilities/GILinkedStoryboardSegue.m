//
//  GILinkedStoryboardSegue.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-21.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GILinkedStoryboardSegue.h"

@implementation GILinkedStoryboardSegue

+ (UIViewController *)sceneNamed:(NSString *)identifier
{
    NSArray *info = [identifier componentsSeparatedByString:@"."];
    NSString *storyboardName = info[0];
    NSString *sceneName = info[1];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *scene = nil;
    
    if (sceneName.length == 0)
    {
        scene = [storyboard instantiateInitialViewController];
    }
    else
    {
        scene = [storyboard instantiateViewControllerWithIdentifier:sceneName];
    }
    
    return scene;
}

+ (UIViewController*)sceneWithName:(NSString*)sceneName inStoryboardNamed:(NSString*)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *scene = nil;
    
    if (scene != nil && sceneName.length > 0)
    {
        scene = [storyboard instantiateViewControllerWithIdentifier:sceneName];
    }
    else
    {
        scene = [storyboard instantiateInitialViewController];
    }
    
    return scene;
}

- (id)initWithIdentifier:(NSString *)identifier
                  source:(UIViewController *)source
             destination:(UIViewController *)destination
{
    return [super initWithIdentifier:identifier
                              source:source
                         destination:[GILinkedStoryboardSegue sceneNamed:identifier]];
}

- (void)perform
{
    UIViewController *source = (UIViewController *)self.sourceViewController;
    [source.navigationController pushViewController:self.destinationViewController
                                           animated:YES];
}
@end
