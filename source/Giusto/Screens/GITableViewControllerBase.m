//
//  GITableViewControllerBase.m
//  Giusto
//
//  Created by John Gabelmann on 10/23/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GITableViewControllerBase.h"

@interface GITableViewControllerBase ()

@end

@implementation GITableViewControllerBase

- (void) configureWithModelObject:(id<MYParseableModelObject>)modelObject
{
    self.table = modelObject;
    [super configureWithModelObject:modelObject];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ModalEditTableSegue"]) {
        GITableViewControllerBase *destination = [[(UINavigationController *)segue.destinationViewController viewControllers] firstObject];
        
        [destination configureWithModelObject:self.table];
    }
}

@end
