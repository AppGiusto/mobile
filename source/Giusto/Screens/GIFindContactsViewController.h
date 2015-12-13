//
//  GIFindContactsViewController.h
//  Giusto
//
//  Created by Nielson Rolim on 8/7/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

#import "GIChangeDietViewControllerBase.h"

@interface GIFindContactsViewController : GIChangeDietViewControllerBase <UITableViewDataSource, UITableViewDelegate>

//Type os search of contacts: addressBook or facebook
@property (nonatomic, strong) NSString* searchType;

@end
