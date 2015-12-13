//
//  GIConnectionsViewController.m
//  Giusto
//
//  Created by Elinam Hini on 2014-10-10.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIConnectionsViewController.h"
#import "GIFindContactsViewController.h"

@interface GIConnectionsViewController()<GIUserTableViewControllerBaseDelegate>
@end

@implementation GIConnectionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchResultsLabel.text = @"";
    self.connectionsSearchBar.returnKeyType = UIReturnKeySearch;
    self.instructionView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self.navigationController navigationBar] setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Connections tableview model update delegate
- (void)connectionsTableViewController:(GIConnectionsTableViewController*)connectionsTableViewController didUpdateModelWithNumberOfConnections:(NSInteger)numberOfConnections
{
    if (numberOfConnections == 0)
    {
        self.instructionView.hidden = NO;
    }
    else
    {
        self.instructionView.hidden = YES;
    }
}

- (void)willUpdateDataModelconnectionsTableViewController:(GIConnectionsTableViewController *)connectionsTableViewController
{
    [self.view showProgressHUD];
}

- (void)didUpdateDataModelconnectionsTableViewController:(GIConnectionsTableViewController *)connectionsTableViewController
{
    [self.view hideProgressHUD];
}

- (void)didBeginToInteractWithTableViewController:(GIUserTableViewControllerBase *)connectionsTableViewController
{
    [self.connectionsSearchBar resignFirstResponder];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"findBudsAddFromContactsSegue"]) {
        GIFindContactsViewController* findContactsVC = (GIFindContactsViewController*)segue.destinationViewController;
        findContactsVC.searchType = @"addressBook";
    } else if ([segue.identifier isEqualToString:@"findBudsAddFromFacebookFriendsSegue"]) {

        GIFindContactsViewController* findContactsVC = (GIFindContactsViewController*)segue.destinationViewController;
        findContactsVC.searchType = @"facebook";
    } else {
        
        if (self.connectionsTableViewController == nil)
        {
            id destinationViewController = [segue destinationViewController];
            if ([destinationViewController isKindOfClass:[GIUserTableViewControllerBase class]])
            {
                self.connectionsTableViewController = destinationViewController;
                if ([self.connectionsTableViewController respondsToSelector:@selector(modelUpdateDelegate)])
                {
                    self.connectionsTableViewController.modelUpdateDelegate = self;
                }
            }
        }
        
    }
}

- (void)updateSearchResultsWithResults:(NSInteger)users forSearchString:(NSString*)searchString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *searchResultMessage = [NSString stringWithFormat:@"%ld %@ found for \"%@\"",(long)users, (users == 0 | users > 1) ? @"results" : @"result",searchString];
        self.searchResultsLabel.attributedText = [[NSAttributedString alloc] initWithString:searchResultMessage
                                                                                 attributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor],
                                                                                              NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold"
                                                                                                                                  size:16]
                                                                                              }];
    });
}

- (void)resetSearchResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchResultsLabel.text = @"";
        [self.connectionsTableViewController cancelSearch];
    });
}

- (void)evaluateSearch:(NSString*)searchText forSearchBar:(UISearchBar*)searchBar
{
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        [self.view showProgressHUD];
        [self.connectionsTableViewController performSearchForString:searchText withResultCountUpdateBlock:^(id sender, int numberOfItemsFound) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (searchText.length > 0)
                {
                    [self updateSearchResultsWithResults:numberOfItemsFound forSearchString:searchText];
                }
                else
                {
                    [self resetSearchResult];
                }
                [self.view hideProgressHUD];
            });
        }];
    }
    else
    {
        [self resetSearchResult];
    }
}

#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
     if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        //self.searchButton.enabled = YES;
    }
    else
    {
        //self.searchButton.enabled = NO;
        [self resetSearchResult];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self resetSearchResult];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self evaluateSearch:self.connectionsSearchBar.text forSearchBar:self.connectionsSearchBar];
    [searchBar resignFirstResponder];
}

@end