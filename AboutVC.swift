//
//  AboutVC.swift
//  PilotHandy
//
//  Created by Jerry Walton on 8/7/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import UIKit

class AboutVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    let nRows = 5
    
    // Block to handle all our taps, we attach this to all the label's handlers
    //        KILinkTapHandler tapHandler = ^(KILabel *label, NSString *string, NSRange range) {
    //            [self tappedLink:string cellForRowAtIndexPath:indexPath];
    //        };
    let tapHandler: KILinkTapHandler = { (label: KILabel, string: String, range: NSRange) -> () in
        print("label: \(label) string: \(string) range: \(range)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleCancelBtn() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nRows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var ht: CGFloat!
        switch indexPath.row {
        case 0,2,3,4:
            ht = 66
            break
        default:
            ht = 44
        }
        return ht
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = nil
        
        switch indexPath.row {
        case 0:
            if let mCell: MultiLineTextTVCell! = self.createMultiLineTextCell(tableView) {
                mCell.textLbl.text = "Practice for the\n\"Unmanned Aircraft General - Small\"\nExam"
                mCell.textLbl.textAlignment = .Center
                mCell.textLbl.font = UIFont(name: "Helvetica Bold", size: 16.0)
                cell = mCell
            }
            break
        case 1:
            if let sCell: SingleLineTextTVCell! = self.createSingleLineTextCell(tableView) {
                sCell.textLbl.text = "A study aid for the Remote Pilot Certification test."
                sCell.textLbl.textAlignment = .Center
                cell = sCell
            }
            break
        case 2:
            if let mCell: MultiLineTextTVCell! = self.createMultiLineTextCell(tableView) {
                mCell.textLbl.text = "Developer: Jerry Walton\nSymbolic Languages LLC\nhttp://www.symboliclanguages.com"
                mCell.textLbl.textAlignment = .Center
                mCell.textLbl.urlLinkTapHandler = tapHandler
                //mCell.contentView.layer.backgroundColor = UIColor.init(red: 224.0, green: 224.0, blue: 224.0, alpha: 1.0).CGColor
                //mCell.textLbl.textColor = UIColor.whiteColor()
                //mCell.contentView.layer.cornerRadius = 9.0
                cell = mCell
            }
            break
        case 3:
            if let mCell: MultiLineTextTVCell! = self.createMultiLineTextCell(tableView) {
                mCell.textLbl.text = "Sample quiz answers provided\nby Sarah Nilsson, JD, PhD, MAS\nhttp://www.sarahnilsson.org/"
                mCell.textLbl.textAlignment = .Center
                mCell.textLbl.urlLinkTapHandler = tapHandler
                //mCell.contentView.layer.backgroundColor = UIColor.grayColor().CGColor
                //mCell.textLbl.textColor = UIColor.whiteColor()
                //mCell.contentView.layer.cornerRadius = 9.0
                cell = mCell
            }
            break
        case 4:
            if let mCell: MultiLineTextTVCell! = self.createMultiLineTextCell(tableView) {
                mCell.textLbl.text = "Uses \"CircularProgressView\" code\nby Wagner Truppel\nhttp://www.restlessbrain.com/wagner/"
                mCell.textLbl.textAlignment = .Center
                mCell.textLbl.urlLinkTapHandler = tapHandler
                //mCell.contentView.layer.backgroundColor = UIColor.lightGrayColor().CGColor
                //mCell.contentView.layer.cornerRadius = 9.0
                cell = mCell
            }
            break
        default:
            break
        }
        
        return cell
    }
    
    func createSingleLineTextCell(tableView: UITableView) -> SingleLineTextTVCell {
        
        return tableView.dequeueReusableCellWithIdentifier(SingleLineTextTVCell.identifier()) as! SingleLineTextTVCell
    }
    
    func createMultiLineTextCell(tableView: UITableView) -> MultiLineTextTVCell {
        
        return tableView.dequeueReusableCellWithIdentifier(MultiLineTextTVCell.identifier()) as! MultiLineTextTVCell
    }
    
}
