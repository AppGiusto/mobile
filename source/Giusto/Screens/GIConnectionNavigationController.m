//
//  GIConnectionNavigationController.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-21.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionNavigationController.h"

@interface GIConnectionNavigationController ()

@end

@implementation GIConnectionNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIViewController *connectionsViewController = [[[UIStoryboard storyboardWithName:@"GIUserConnections" bundle:nil] instantiateInitialViewController] topViewController];
    [self pushViewController:connectionsViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
