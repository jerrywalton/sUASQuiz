//
//  QuestionVC.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/22/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        //let constraintRect = CGSize(width: width, height: greatestFiniteMagnitude)
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        //let boundingBox = self.boundingRectWithSize(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        let boundingBox = self.boundingRectWithSize(constraintRect, options:.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context:nil)
        return boundingBox.height
    }
}

enum QuestionMode : String {
    case Quiz, Review
}

let NO_ANSWER_SELECTED_INDEX: Int = -1

class QuestionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolbar: UIToolbar!
    var checkBtn: UIBarButtonItem!
    var prevBtn: UIBarButtonItem!
    var nextBtn: UIBarButtonItem!
    var questions: NSArray!
    var question: QuizQuestion!
    var rand: Int!
    var shouldHighlightCorrectAnswer: Bool = false
    var selectedAnswerIndex: Int = NO_ANSWER_SELECTED_INDEX
    var viewControllers: [UIViewController] = []
    var questionsCount = 0
    var subtitleLbl: UILabel!
    var titleView: UIView!
    var referToAction: Selector!
    var buttonAction: Selector!
    var buttonActionText: String!
    var questionMode: QuestionMode!
    var incorrectAnswer: IncorrectAnswer!
    var reviewAnswerIndex: Int!
    let answerKeysDict = ["A", "B", "C", "D", "E", "F"]         // initial support for max 6 answers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.viewControllers = (self.navigationController?.tabBarController?.viewControllers)!

        questionMode = QuizModel.sharedInstance.questionMode
        initToolbar()
        
        switch questionMode! {
        case .Quiz:
            self.questionsCount = QuizModel.sharedInstance.questions.count
            loadQuestion()
            break
        case .Review:
            self.questionsCount = (QuizModel.sharedInstance.currentQuiz.quizToIncorrectAnswer?.count)!
            reviewAnswerIndex = 0
            loadQuestionForReview()
            break
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshUI() {
        self.tableView.reloadData()
        self.updateToolbar()
    }
    
    func loadQuestion() {
        
        QuizModel.sharedInstance.loadRandomQuestion()
        question = QuizModel.sharedInstance.currentQuestion
        configReferTo(question)
        selectedAnswerIndex = NO_ANSWER_SELECTED_INDEX
        shouldHighlightCorrectAnswer = false
        refreshUI()
        clearNavBtn()
        showLeftPauseBtn()
        updateNavArea()
    }
    
    func loadQuestionForReview() {

        QuizModel.sharedInstance.loadIncorrectAnswer(reviewAnswerIndex)
        question = QuizModel.sharedInstance.currentQuestion
        configReferTo(question)
        selectedAnswerIndex = answerKeysDict.indexOf(QuizModel.sharedInstance.currentIncorrectAnswer.answerKey!)!
        shouldHighlightCorrectAnswer = true
        
        refreshUI()
        showLeftDoneBtn()
        updateNavArea()
    }

    func configReferTo(question: QuizQuestion) {
        if (!question.hasReferTo()) {
            self.navigationController?.tabBarController?.viewControllers = [self.viewControllers[0]]
        } else{
            self.navigationController?.tabBarController?.viewControllers = self.viewControllers
        }
    }
    
    func updateNavArea() {
        if (titleView == nil) {
            
            // title
            let titleLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
            titleLbl.textAlignment = .Center
            
            switch questionMode! {
            case .Quiz:
                titleLbl.text = QuizModel.sharedInstance.quizTitle
                break
            case .Review:
                titleLbl.text = "Review -" + QuizModel.sharedInstance.quizTitle
                break
            }
            
            // sub title
            subtitleLbl = UILabel(frame: CGRect(x: 0, y: 20, width: 200, height: 20))
            subtitleLbl.font = UIFont(name: "Helvetica", size: 15)
            subtitleLbl.textAlignment = .Center
            
            // custom title view
            titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
            titleView.addSubview(titleLbl)
            titleView.addSubview(subtitleLbl)
            
            // set the title view to our custom view
            self.navigationItem.titleView = titleView
        }
        
        let questionNbr = QuizModel.sharedInstance.currentQuestionNbr
        subtitleLbl.text = "Question \(questionNbr) of \(questionsCount)"
    }
    
    func initToolbar() {
        checkBtn = UIBarButtonItem(title: "Check", style: .Plain, target: self, action: #selector(handleCheckBtn))
        prevBtn = UIBarButtonItem(title: "Prev", style: .Plain, target: self, action: #selector(handlePrevBtn))
        nextBtn = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(handleNextBtn))
        toolbar.hidden = true
    }
    
    func updateToolbar() {
        var items: [UIBarButtonItem] = []
        items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action:  nil))
        
        switch questionMode! {
        case .Quiz:
            if shouldHighlightCorrectAnswer {
                toolbar.hidden = false
                items.append(nextBtn)
            } else{
                if (hasUserSelectedAnAnswer()) {
                    toolbar.hidden = false
                    items.append(checkBtn)
                } else{
                    toolbar.hidden = true
                }
            }
            break
        case .Review:
            toolbar.hidden = false
            if (reviewAnswerIndex != 0) {
                items.append(prevBtn)
            }
            
            if (reviewAnswerIndex != (questionsCount - 1)) {
                if (items.count > 1) {
                    items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action:  nil))
                }
                items.append(nextBtn)
            }
            break
        }
        
        items.append(UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action:  nil))
        toolbar.setItems(items, animated: true)
    }
    
    func handleReferToBtn() {
        self.navigationController?.tabBarController?.selectedIndex = 1
    }
    
    func handleCheckBtn() {
        self.shouldHighlightCorrectAnswer = true
        let quiz = QuizModel.sharedInstance.currentQuiz
        let correctAnswerKey = question?.correctAnswer.objectForKey("key") as? String
        let answer = question?.answers.objectAtIndex(self.selectedAnswerIndex) as? NSDictionary
        let answerKey = answer?.objectForKey("key") as? String
        let isCorrect = correctAnswerKey == answerKey
        //print("correctAnswerKey: \(correctAnswerKey) answerKey: \(answerKey)")
        DataMgr.sharedInstance.saveQuizAnswer(quiz, questionKey: question.key, answerKey: answerKey!, correct: isCorrect)
        DataMgr.sharedInstance.updateQuizAskedQuestion(quiz, questionKey: question.key)
        refreshUI()
    }
    
    func handlePrevBtn() {
        switch questionMode! {
        case .Quiz:
            break
        case .Review:
            reviewAnswerIndex = reviewAnswerIndex - 1
            self.loadQuestionForReview()
            break
        }
    }
    
    func handleNextBtn() {
        
        switch questionMode! {
        case .Quiz:
            if (QuizModel.sharedInstance.currentQuestionNbr < QuizModel.sharedInstance.totalQuestionsCnt) {
                self.loadQuestion()
            } else{
                let score = DataMgr.sharedInstance.determineQuizScore(QuizModel.sharedInstance.currentQuiz)
                let scoreStr = String.localizedStringWithFormat("%.0f", score)
                let alertController = UIAlertController.init(title: "Quiz Complete", message: "Your score: \(scoreStr)%", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
                    self.navigationController?.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
                })
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            break
        case .Review:
            reviewAnswerIndex = reviewAnswerIndex + 1
            self.loadQuestionForReview()
            break
        }

    }
    
    func handleDoneBtn() {
        self.navigationController?.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handlePauseBtn() {
        self.navigationController?.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func hasUserSelectedAnAnswer() -> Bool {
        return (self.selectedAnswerIndex != NO_ANSWER_SELECTED_INDEX)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let plusRows = hasUserSelectedAnAnswer() ? 3 : 2
        let plusRows = 2
        let nRows = (question?.answers.count)! + plusRows
        return nRows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var ht: CGFloat!
        let hasReferTo = question != nil && question!.hasReferTo()
        switch indexPath.row {
        case 0:
            ht = hasReferTo ? 56 : 0
            break
        case 1:
            ht = rowHeight(question.question, style: UIFontTextStyleHeadline)
            break
        case 2,3,4:
            let ansNdx = indexPath.row - 2
            let ans = String(self.question.answers[ansNdx])
            ht = rowHeight(ans, style: UIFontTextStyleSubheadline)
                break;
        default:
            ht = 56
        }
        return ht
    }
    
    func rowHeight(text: String, style: String) -> CGFloat
    {
        let font = UIFont.preferredFontForTextStyle(style)
        let ht = text.heightWithConstrainedWidth(tableView.frame.size.width, font: font)
        return ht
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = nil
        
        //print("question: \(question?.question) \nanswers: \(question?.answers)")
        let requiredRows = 3 + (question?.answers.count)!
        
        if (indexPath.row == 0) {
            // referTo cell
            cell = self.createReferToCell(tableView, question: question)
            cell.contentView.layer.cornerRadius = 4.0
            cell.contentView.layer.borderColor = UIColor.darkTextColor().CGColor
            cell.contentView.layer.borderWidth = self.question.hasReferTo() ? 1.0 : 0.0
        } else{
            // if here, indexPath row must be > zero
            if (indexPath.row == 1) {
                // question cell
                cell = self.createQuestionCell(tableView, question: question)
            } else{
                //
                if (indexPath.row == requiredRows - 1) {
                    // next/continue button cell
                    switch questionMode! {
                    case .Quiz:
                        cell = self.createQuizButtonsCell(tableView, question: question)
                        break
                    case .Review:
                        cell = self.createReviewButtonsCell(tableView, question: question)
                        break
                    }
                } else{
                    // row is an answer cell
                    if let answerCell: AnswerTVCell! = self.createAnswerCell(tableView) {
                        
                        let ndx = indexPath.row - 2
                        //print("ndx: \(ndx)")
                        if let answer = question?.answers.objectAtIndex(ndx) as? NSDictionary {
                            
                            let key = answer.objectForKey("key") as? String
                            let ans = answer.objectForKey("text") as? String
                            answerCell.answerLbl.text = "\(key!). \(ans!)"

                            if (ndx == selectedAnswerIndex) {
                                answerCell.answerLbl.textColor = UIColor.whiteColor()
                                answerCell.contentView.layer.borderColor = UIColor.whiteColor().CGColor
                                answerCell.contentView.backgroundColor = UIColor.blueColor()
                            } else{
                                answerCell.answerLbl.textColor = UIColor.darkTextColor()
                                answerCell.contentView.layer.borderColor = UIColor.darkTextColor().CGColor
                                answerCell.contentView.backgroundColor = UIColor.lightGrayColor()
                            }
                            
                            if shouldHighlightCorrectAnswer {
                                let correctAnswerKey = question?.correctAnswer.objectForKey("key") as? String
                                if (correctAnswerKey == key) {
                                    answerCell.contentView.backgroundColor = UIColor.greenColor()
                                } else{
                                    if (ndx == selectedAnswerIndex) {
                                        answerCell.contentView.backgroundColor = UIColor.redColor()
                                    } else{
                                        answerCell.contentView.backgroundColor = UIColor.lightGrayColor()
                                    }
                                }
                            } else{
                                answerCell.contentView.layer.borderWidth = 1.0
                            }

                        }
                        
                        answerCell.contentView.layer.cornerRadius = 4.0
                        
                        cell = answerCell
                        
                    }
                }
                
            }
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        switch questionMode! {
        case .Quiz:
            switch indexPath.row {
                case 0:         // referTo row
                    if (question.hasReferTo()) {
                        print("refer to row")
                        performSelector(referToAction)
                    }
                    break
                    //case 1:         // question row
                //break
                case 2,3,4:     // answer rows
                    // determine which answer row selected and reload for highlight
                    let ndx = indexPath.row - 2
                    print("answer row ndx: \(ndx)")
                    self.selectedAnswerIndex = ndx
                    refreshUI()
                    break
                case 5:         // row 5 is the next/continue button
                    print("next/continue button row")
                    performSelector(buttonAction)
                    break
                default:
                    break
            }
            break
        case .Review:
            break
        }
        
    }
    
    //
    
    func createReferToCell(tableView: UITableView, question: QuizQuestion?) -> UITableViewCell {

        let referToCell: ButtonTVCell! = tableView.dequeueReusableCellWithIdentifier(ButtonTVCell.identifier()) as? ButtonTVCell
        if referToCell != nil {
            
            referToAction = #selector(QuestionVC.handleReferToBtn)
            referToCell.button.addTarget(self, action: referToAction, forControlEvents: UIControlEvents.TouchUpInside)
            
            var referTo: String = ""
            if ((question?.hasReferTo()) != nil) {
                referTo = (question?.referTo)!
                referToCell.button.setTitle(referTo, forState: UIControlState.Normal)
                referToCell.button.hidden = false
            } else{
                referToCell.button.hidden = true
            }
            
        }
        
        return referToCell
    }
    
    func createQuestionCell(tableView: UITableView, question: QuizQuestion?) -> QuestionTVCell {

        let questionCell: QuestionTVCell! = tableView.dequeueReusableCellWithIdentifier(QuestionTVCell.identifier()) as? QuestionTVCell
        if (questionCell != nil) {
            questionCell.questionLbl.text = question?.question
        }
        
        return questionCell
    }
    
    func createAnswerCell(tableView: UITableView) -> AnswerTVCell {

        return tableView.dequeueReusableCellWithIdentifier(AnswerTVCell.identifier()) as! AnswerTVCell
    }
    
    func createQuizButtonsCell(tableView: UITableView, question: QuizQuestion?) -> UITableViewCell {
        
        let quizButtonsCell: ButtonTVCell! = tableView.dequeueReusableCellWithIdentifier(ButtonTVCell.identifier()) as? ButtonTVCell
        if quizButtonsCell != nil {

            print("targets: \(quizButtonsCell.button.allTargets().count)")
            
            // first remove current button targets
            if (quizButtonsCell.button.targetForAction(#selector(QuestionVC.handleNextBtn), withSender: nil)) != nil {
                    quizButtonsCell.button.removeTarget(self, action: #selector(QuestionVC.handleNextBtn), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if (quizButtonsCell.button.targetForAction(#selector(QuestionVC.handleCheckBtn), withSender: nil)) != nil {
                quizButtonsCell.button.removeTarget(self, action: #selector(QuestionVC.handleCheckBtn), forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            // add correct button target
            if shouldHighlightCorrectAnswer {
                quizButtonsCell.button.setTitle("Next Question", forState: UIControlState.Normal)
                buttonAction = #selector(QuestionVC.handleNextBtn)
                showNavBtn("Next", action: buttonAction)
            } else{
                quizButtonsCell.button.setTitle("Check my answer", forState: UIControlState.Normal)
                buttonAction = #selector(QuestionVC.handleCheckBtn)
                showNavBtn("Check", action: buttonAction)
            }
            quizButtonsCell.button.addTarget(self, action: buttonAction, forControlEvents: UIControlEvents.TouchUpInside)
            
            quizButtonsCell.contentView.layer.borderWidth = 1.0
            quizButtonsCell.contentView.layer.borderColor = UIColor.darkTextColor().CGColor
            quizButtonsCell.contentView.layer.cornerRadius = 4.0
        }
        
        return quizButtonsCell
    }

    func createReviewButtonsCell(tableView: UITableView, question: QuizQuestion?) -> UITableViewCell {
        let reviewButtonsCell: ButtonsTVCell! = tableView.dequeueReusableCellWithIdentifier(ButtonsTVCell.identifier()) as? ButtonsTVCell
        
        if reviewButtonsCell != nil {
            
            var hidden = reviewAnswerIndex == 0
            if (!hidden) {
                reviewButtonsCell.leftButton.setTitle("Prev", forState: UIControlState.Normal)
                reviewButtonsCell.leftButton.addTarget(self, action: #selector(QuestionVC.handlePrevBtn), forControlEvents: UIControlEvents.TouchUpInside)
                reviewButtonsCell.leftButton.layer.cornerRadius = 4.0
                reviewButtonsCell.leftButton.layer.borderColor = UIColor.darkTextColor().CGColor
                reviewButtonsCell.leftButton.layer.borderWidth = 1.0
            }
            reviewButtonsCell.leftButton.hidden = hidden
            
            hidden = reviewAnswerIndex == (questionsCount - 1)
            if (!hidden) {
                reviewButtonsCell.rightButton.setTitle("Next", forState: UIControlState.Normal)
                reviewButtonsCell.rightButton.addTarget(self, action: #selector(QuestionVC.handleNextBtn), forControlEvents: UIControlEvents.TouchUpInside)
                reviewButtonsCell.rightButton.layer.cornerRadius = 4.0
                reviewButtonsCell.rightButton.layer.borderColor = UIColor.darkTextColor().CGColor
                reviewButtonsCell.rightButton.layer.borderWidth = 1.0
            }
            reviewButtonsCell.rightButton.hidden = hidden
        }
        
        return reviewButtonsCell
    }

    func createAcsCodesCell(tableView: UITableView, question: QuizQuestion?) -> UITableViewCell  {
        
        let acsCodesCell: MultiLineTextTVCell! = tableView.dequeueReusableCellWithIdentifier(MultiLineTextTVCell.identifier()) as? MultiLineTextTVCell
        if acsCodesCell != nil {
            acsCodesCell.textLbl.text = question?.acsCodes!
        }
        return acsCodesCell
    }

    // remove button from top right nav
    func clearNavBtn() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func showNavBtn(title: String, action: Selector) {
        let btn = UIBarButtonItem(title: title, style: .Plain, target: self, action: action)
        self.navigationItem.rightBarButtonItem = btn
    }
    
    func showPrevNavBtn() {
        let btn = UIBarButtonItem(title: "Prev", style: .Plain, target: self, action: #selector(QuestionVC.handlePrevBtn))
        self.navigationItem.leftBarButtonItem = btn
    }
    
    func clearPrevNavBtn() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func showNextNavBtn() {
        let btn = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(QuestionVC.handleNextBtn))
        self.navigationItem.rightBarButtonItem = btn
    }
    
    func clearNextNavBtn() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func showLeftDoneBtn() {
        let btn = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(QuestionVC.handleDoneBtn))
        self.navigationItem.leftBarButtonItem = btn
    }
    
    func showLeftPauseBtn() {
        let btn = UIBarButtonItem(title: "Pause", style: .Done, target: self, action: #selector(QuestionVC.handlePauseBtn))
        self.navigationItem.leftBarButtonItem = btn
    }
    
}
