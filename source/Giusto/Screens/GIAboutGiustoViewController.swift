//
//  GIAboutGiustoViewController.swift
//  Giusto
//
//  Created by Eli Hini on 2014-11-20.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

import UIKit

class GIAboutGiustoViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var webView: UIWebView?
    var urlRequest: NSURLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documentURL = NSBundle.mainBundle().URLForResource("About", withExtension:"rtf")
        urlRequest = NSURLRequest(URL: documentURL!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        webView?.loadRequest(urlRequest!)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.view.showProgressHUD()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.view.hideProgressHUD()
    }
}
