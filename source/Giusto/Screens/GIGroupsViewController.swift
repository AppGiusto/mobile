//
//  GIGroupsViewController.swift
//  Giusto
//
//  Created by Eli Hini on 2014-11-25.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

import UIKit
/*
#pragma mark - Navigation

- (IBAction)unwindToTables:(UIStoryboardSegue *)unwindSegue
{

}

- (UIViewController*)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender
{
return [super viewControllerForUnwindSegueAction:action fromViewController:fromViewController withSender:sender];
}
*/
class GIGroupsViewController: UIViewController,GIGroupsOfTablesDelegate {

    var groupsCollectionViewController: GITableCollectionViewController?
    
    @IBOutlet weak var instructionView: UIView!
    
    // MARK: - Override - 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.instructionView.hidden = true;
    }
    // MARK: - Navigation -
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "GroupsCollectionView" && groupsCollectionViewController == nil {
            self.groupsCollectionViewController = segue.destinationViewController as? GITableCollectionViewController
            self.groupsCollectionViewController?.modelDataUpdateDelegate = self
        }
    }
    
    // MARK: - GIGroupsOfTablesDelegate - 
    func tableCollectionViewController(collectionViewController: GITableCollectionViewController!, didUpdateModelWithCount count: Int) {
        
        if count == 0 {
            instructionView.hidden = false
        }
        else
        {
            instructionView.hidden = true
        }
//        self.view.hideProgressHUD()
    }
    
    func tableCollectionViewControllerWillUpdateDataModel() {
//        self.view.showProgressHUD()
    }
    
    // MARK: - Navigation - 
    @IBAction func unwindToTables(unwindSegue: UIStoryboardSegue)
    {
        // required for Uwind segue to work
    }

}
