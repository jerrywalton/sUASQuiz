//
//  WebViewVC.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/28/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation
import UIKit

class WebViewVC: UIViewController {
    
    @IBOutlet var webview: UIWebView!
    @IBOutlet var label: UILabel!
    @IBOutlet var overlay: UIView!
    var docPath: String!
    var docUrl: NSURL!
    var pageHeight: CGFloat!
    var totalPages: NSInteger!
    var question: QuizQuestion!
    //var hasFinishedLoading: Bool = false
    var timer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.webview.delegate = self
        self.webview.scalesPageToFit = true
        
        self.overlay.alpha = 0
        self.overlay.layer.borderColor = UIColor.whiteColor().CGColor
        self.overlay.layer.borderWidth = 1.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        handleShowOverlayBtn()
        initAutoHideOverlay()
        self.loadPage()
    }
    
    @IBAction func handleBackBtn() {
        self.navigationController?.tabBarController?.selectedIndex = 0
    }
    
    func configNavBtn() {
        var action: Selector! = nil
        var title: String! = nil
        
        switch self.overlay.hidden {
        case true:
            action = #selector(WebViewVC.handleShowOverlayBtn)
            title = "❓"
            break
        case false:
            action = #selector(WebViewVC.handleHideOverlayBtn)
            title = "❔"
            break
        }
        self.showNavBtn(title, action: action)
    }

    @IBAction func handleCloseOverlay() {
        if (timer != nil && timer.valid) {
            timer.invalidate()
        }
        handleHideOverlayBtn()
    }
    
    @objc
    func handleHideOverlayBtn() {
        UIView.animateWithDuration(0.7, animations: {
            self.overlay.alpha = 0
        }) { (_) in
            self.overlay.hidden = true
            self.configNavBtn()
        }
    }
    
    @objc
    func handleShowOverlayBtn() {
        self.overlay.alpha = 0
        self.overlay.hidden = false
        self.configNavBtn()
        UIView.animateWithDuration(0.7, animations: {
            self.overlay.alpha = 0.7
            }) { (_) in
                //self.initAutoHideOverlay()
        }
    }
    
    func initAutoHideOverlay() {
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(handleHideOverlayBtn), userInfo: nil, repeats: false)
    }
    
    func loadPage() {
        
        if (self.question == nil || !(self.question === QuizModel.sharedInstance.currentQuestion)) {
            self.question = QuizModel.sharedInstance.currentQuestion
            self.label.text = self.question.question
            self.docPath = QuizModel.sharedInstance.referencePDFFilePath(self.question.referToPage!)
            self.docUrl = NSURL(fileURLWithPath: self.docPath)
            let request = NSURLRequest(URL: self.docUrl)
            self.webview.loadRequest(request)            
        }
    }
    
}

extension WebViewVC: UIWebViewDelegate {
    
//    func webViewDidFinishLoad(webView: UIWebView) {
//
//        //self.hasFinishedLoading = true
//        
//        //    //get the total height
//        //    CGFloat pageHeight = self.webView.scrollView.contentSize.height;
//        self.totalPages = self.getTotalPDFPages(self.docPath)
//        print("totalPages: \(self.totalPages)")
//        self.pageHeight = self.webview.scrollView.contentSize.height
//        print("pageHeight: \(self.pageHeight)")
//        
//        self.loadPage()
//        
//    }
    
    func getTotalPDFPages(strPDFFilePath: String) -> NSInteger {
        
        //    //get page nums
        //    -(NSInteger)getTotalPDFPages:(NSString *)strPDFFilePath
        //    {
        //    NSURL *pdfUrl = [NSURL fileURLWithPath:strPDFFilePath];
        //    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((CFURLRef)pdfUrl);
        //    size_t pageCount = CGPDFDocumentGetNumberOfPages(document);
        //    return pageCount;
        let document = CGPDFDocumentCreateWithURL(self.docUrl)
        let pageCount: size_t = CGPDFDocumentGetNumberOfPages(document!)
        return pageCount
    }
    
    func jumpToPage(targetPage:CGFloat) {
        //then you can jump any page,like the last page
        //[self.webView.scrollView setContentOffset:CGPointMake(0, (self.content_num-1)*(self.content_hetght*1.0 /self.content_num)) animated:YES];
        //self.webview.scrollView.contentOffset = CGPointMake(0, (nPages - 1)*((self.pageHeight * 1.0) / nPages))
        //self.webview.scrollView.contentOffset = CGPointMake(0, (targetPage - 1) * ((self.pageHeight * 1.0) / nPages))
        self.webview.scrollView.contentOffset = CGPointMake(0, (targetPage - 1) * (self.pageHeight / CGFloat(self.totalPages)))
    }
    
    // remove button from top right nav
    func clearNavBtn() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func showNavBtn(title: String, action: Selector) {
        let btn = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        self.navigationItem.rightBarButtonItem = btn
        //self.navigationController?.navigationItem.rightBarButtonItem = btn
    }
    
}

