//
//  GILegalPolicyTableViewController.swift
//  Giusto
//
//  Created by Eli Hini on 2014-11-20.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

import UIKit

class GILegalPolicyTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LegalDocType", forIndexPath: indexPath) 
        
        if indexPath.row == 0 {
            
            cell.textLabel?.text = "Terms of use"
        }
        else {
            cell.textLabel?.text = "Privacy policy"
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == 0 {
            performSegueWithIdentifier("ShowTermsOfUseDocument", sender: self)
        }
        else {
            performSegueWithIdentifier("ShowPrivacyPolicyDocument", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let legalDocReader = segue.destinationViewController as! GILegalPolicyReaderViewController
        let identifier = segue.identifier
        
        if identifier == "ShowTermsOfUseDocument"{
            legalDocReader.title = "Terms Of Use"
            legalDocReader.legalDocumentName = "Terms_Of_Use"
        }
        else {
            legalDocReader.title = "Privacy Policy"
            legalDocReader.legalDocumentName = "Privacy_Policy"
        }
    }
}
