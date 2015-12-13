//
//  GILegalPolicyReaderViewController.swift
//  Giusto
//
//  Created by Eli Hini on 2014-11-20.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

import UIKit

class GILegalPolicyReaderViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet var legalContentWebView: UIWebView?
    
    var legalDocumentName: String?
    var urlRequest: NSURLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        legalContentWebView?.delegate = self
        legalContentWebView?.scalesPageToFit = true
        
        if let documentName = legalDocumentName {
            let documentURL = NSBundle.mainBundle().URLForResource(documentName, withExtension:"docx")
            urlRequest = NSURLRequest(URL: documentURL!)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        legalContentWebView?.loadRequest(urlRequest!)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.view.showProgressHUD()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.view.hideProgressHUD()
    }
}
