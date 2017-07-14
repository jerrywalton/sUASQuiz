//
//  QuizzesVC.swift
//  PilotHandy
//
//  Created by Jerry Walton on 8/1/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation
import UIKit

class QuizzesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    var quizzes: NSArray!
    let passColor = UIColor.init(red: 76.0, green: 217.0, blue: 100.0, alpha: 1.0)
    let failColor = UIColor.init(red: 255.0, green: 45.0, blue: 85.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadQuizzes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadQuizzes() {
        quizzes = DataMgr.sharedInstance.quizzes()
        self.tableView.reloadData()
    }
    
    @IBAction func handleAddBtn() {

        //Create the alert controller
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Take a quiz?", preferredStyle: .ActionSheet)
        
        //Create and add the "Cancel" action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        var action: UIAlertAction!
        
        for quizType in QuizModel.sharedInstance.quizTypes {
            
            //Create an action
            action = UIAlertAction(title: quizType.rawValue, style: .Default) { action -> Void in
                let quizType = QuizType(rawValue: action.title!)

                QuizModel.sharedInstance.loadQuizNew(quizType!)
                
                self.performSegueWithIdentifier("ShowQuiz", sender: nil)
            }
            actionSheetController.addAction(action)
            
        }
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func handleResumeBtn() {
        
    }
    
    @IBAction func handleReviewBtn() {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0
        if (self.quizzes != nil) {
            rows = self.quizzes.count
        }
        print("rows: \(rows)")
        return rows
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = nil

        //if let quizCell: QuizTVCell! = tableView.dequeueReusableCellWithIdentifier(QuizTVCell.identifier()) as! QuizTVCell {
        if let quizCell: QuizTVCell! = tableView.dequeueReusableCellWithIdentifier("QuizTVCell_2") as! QuizTVCell {
            
            let quiz: Quiz! = self.quizzes.objectAtIndex(indexPath.row) as! Quiz
            
            //let scoreStr = String.localizedStringWithFormat("%.0f%%", (quiz.score?.floatValue)!)
            //let score = CGFloat((quiz.score?.floatValue)! / 100)
            let passed = QuizModel.sharedInstance.isPassed(quiz)
            //let scoreColor = passed ? UIColor.greenColor() : UIColor.redColor()
            let totalQuestions = (quiz.totalQuestions?.intValue)!
            let correctAnswers = (quiz.correctAnswers?.intValue)!
            let incorrectAnswers = totalQuestions - correctAnswers
            
            quizCell.title.text = quiz.title
            quizCell.date.text = DataMgr.sharedInstance.dateFormatter.stringFromDate(quiz.date!)
            quizCell.questionsTotal.text = "\(totalQuestions)"
            quizCell.questionsIncorrect.text = "\(incorrectAnswers)"
            
            self.stlyeLabel(quizCell.questionsTitle)
            self.stlyeLabel(quizCell.questionsTotalTitle)
            self.stlyeLabel(quizCell.questionsTotal)
            self.stlyeLabel(quizCell.questionsIncorrectTitle)
            self.stlyeLabel(quizCell.questionsIncorrect)

            /*
            quizCell.circularView.percentLabel?.text = scoreStr
            quizCell.circularView.value = CGFloat(score)
            quizCell.circularView.percentBold = true
            quizCell.circularView.progressTint = scoreColor
            quizCell.circularView.trackTint = UIColor.lightGrayColor()
             */
            quizCell.score.text = String(format: "%.2f", (quiz.score?.floatValue)!)
            quizCell.passFail.text = passed ? "👍" : "👎"
            
            quizCell.resumeBtn.hidden = quiz.complete == true
            quizCell.reviewBtn.hidden = quiz.complete != true
            
            //quizCell.accessoryType = passed ? .None : .DisclosureIndicator
            quizCell.accessoryType = .None
            
            cell = quizCell
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let quiz: Quiz! = self.quizzes.objectAtIndex(indexPath.row) as! Quiz
        
        if (quiz.quizToIncorrectAnswer?.count > 0) {
            
            QuizModel.sharedInstance.loadQuizForReview(quiz)
            
            self.performSegueWithIdentifier("ShowQuiz", sender: nil)
            
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle:   UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            //delete the quiz
            let quiz: Quiz! = self.quizzes.objectAtIndex(indexPath.row) as! Quiz
            DataMgr.sharedInstance.deleteQuiz(quiz)
            // reload quizzes
            self.loadQuizzes()
        }
    }
    
    func stlyeLabel(label: UILabel) {
        label.layer.borderColor = UIColor.blackColor().CGColor
        label.layer.borderWidth = 1.0
    }
    
}
