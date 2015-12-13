//
//  GITablesNavigationController.m
//  Giusto
//
//  Created by Eli Hini on 2014-10-30.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GITablesNavigationController.h"

@interface GITablesNavigationController ()

@end

@implementation GITablesNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIViewController *tablesViewController = [[[UIStoryboard storyboardWithName:@"GITables" bundle:nil] instantiateInitialViewController] topViewController];
    [self pushViewController:tablesViewController animated:NO];
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
