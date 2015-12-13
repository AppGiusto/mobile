//
//  GITourViewController.swift
//  Giusto
//
//  Created by Nielson Rolim on 7/19/15.
//  Copyright (c) 2015 Gennovacap. All rights reserved.
//

import UIKit

class GITourViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var tourCollectionView: UICollectionView!
    
    
    var firstRun:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (defaults.objectForKey("firstRunDatetime") == nil) {
//            defaults.setObject(NSDate(), forKey: "firstRunDatetime")
//            NSUserDefaults.standardUserDefaults().synchronize()
            self.firstRun = true
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func skipButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("startAppSegue", sender: self)
    }

    @IBAction func nestButtonPressed(sender: AnyObject) {
        self.slideTour()
    }
    
    
    func slideTour() {
        let visibleItems:NSArray = self.tourCollectionView.indexPathsForVisibleItems()
        let currentItem:NSIndexPath = visibleItems.objectAtIndex(0) as! NSIndexPath
        let nextItem:NSIndexPath = NSIndexPath(forItem: currentItem.item + 1, inSection: currentItem.section)
        if (nextItem.row < 8) {
            self.tourCollectionView.scrollToItemAtIndexPath(nextItem, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "startAppSegue") {
            let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(NSDate(), forKey: "firstRunDatetime")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var reuseCellIdentifier:String
        
        if (self.firstRun) {
            reuseCellIdentifier = "TourCell-\(indexPath.row)"
        } else {
            reuseCellIdentifier = "TourCell-7"
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) 
        
        if iOS7 {
            self.collectionView(collectionView, willDisplayCell: cell, forItemAtIndexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell:UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (cell.reuseIdentifier == "TourCell-7") {
            self.performSegueWithIdentifier("startAppSegue", sender: self)
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
     func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
     func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
     func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
     func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */


    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(self.tourCollectionView.frame.size.width, self.tourCollectionView.frame.size.height)
    }
}
