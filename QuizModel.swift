//
//  QuizModel.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/12/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation

let defaultPassingScore: Float = 70

enum QuizType : String {
    case TestQuiz = "Demo Quiz"
    case Part107sUAS = "Part 107 Quiz"
//    case Part61sUAS = "Part 61 Quiz"
    
    func filenameExt() -> (filename: String, ext: String) {
        switch self {
        case .TestQuiz:
            return ("test_questions", "json")
        case .Part107sUAS:
            return ("Part_107_sUAS_questions", "json")
//        case .Part61sUAS:
//          return ("Part_61_sUAS_questions", "json")
        }
    }
}

class QuizModel {
    
    // singleton pattern
    static let sharedInstance = QuizModel()

    let referencePDF_prefix = "sport_rec_private_akts_extract"
    //let quizTypes = [QuizType.TestQuiz, QuizType.Part107sUAS, QuizType.Part61sUAS]
    let quizTypes = [QuizType.TestQuiz, QuizType.Part107sUAS]
    
    var questionsDict = NSMutableDictionary()
    var questions = NSMutableArray()
    var quizzes = NSMutableArray()
    var answeredQuestions = NSMutableArray()
    var quizTitle: String!
    var passingScore: Float! = defaultPassingScore
    
    var currentQuestion: QuizQuestion!
    var currentQuiz: Quiz!
    var totalQuestionsCnt: Int!
    var currentQuestionNbr: Int!
    var currentIncorrectAnswer: IncorrectAnswer!
    var questionMode: QuestionMode!
    
    func loadQuestionsFromFile(file: String, type: String, resumeQuiz: Quiz?) {

        let isLoadForResume = resumeQuiz != nil
        var askedQuestionKeys: [String]!
        
        // if resume, create an array of asked question keys
        if (isLoadForResume) {
            askedQuestionKeys = []
            for askedQuestion in resumeQuiz?.quizToAskedQuestion!.allObjects as! [AskedQuestion] {
                askedQuestionKeys.append(askedQuestion.questionKey!)
            }
        }
        
        // remove current questions
        self.questions.removeAllObjects()
        self.questionsDict.removeAllObjects()

        self.totalQuestionsCnt = 0
        self.currentQuestionNbr = 0
        self.passingScore = 70
        
        let json: NSDictionary! = Utils.jsonFromFile(file, type: type)
        
        if (json != nil) {
            
            print("json: \(json)")
            
            self.quizTitle = json.objectForKey("short-title") as? String
            self.passingScore = json.objectForKey("passingScore") as? Float
            
            if let questions : NSArray! = json.objectForKey("questions") as? NSArray {

                self.totalQuestionsCnt = questions?.count
                
                for question in questions! {
                    
                    print("question: \(question)")

                    let key = question.objectForKey("key") as? String
                    
                    if (isLoadForResume) {
                        // if resume, skip over previously asked questions
                        if (askedQuestionKeys.contains(key!)) {
                            continue
                        }
                    }
                    
                    let referTo = question.objectForKey("referTo") as? String
                    let referToPage = question.objectForKey("referToPage") as? Int
                    let ques = question.objectForKey("question") as? String
                    let correctAnswer = question.objectForKey("correctAnswer") as? NSDictionary
                    let acsCodes = question.objectForKey("acsCodes") as? String
                    
                    var answers: NSArray! = question.objectForKey("answers") as? NSArray
                    if answers != nil {
                        
                        answers = answers?.sortedArrayUsingComparator({ (obj1: AnyObject, obj2: AnyObject) -> NSComparisonResult in
                            let a1 = obj1 as! NSDictionary
                            let a2 = obj2 as! NSDictionary
                            let key1 = a1.objectForKey("key") as? String
                            let key2 = a2.objectForKey("key") as? String
                            return key1!.caseInsensitiveCompare(key2!)
                        })
                    }
                    
                    let questionObj = QuizQuestion(key: key!, referTo: referTo, referToPage: referToPage!, question: ques!, answers: answers!, correctAnswer: correctAnswer!, acsCodes: acsCodes)
                    
                    self.questionsDict.setObject(questionObj, forKey: questionObj.key)
                    self.questions.addObject(questionObj)
                }
            }
        }
        
    }
    
    func questionWithKey(key: String) -> QuizQuestion? {
        
        return self.questionsDict.objectForKey(key) as? QuizQuestion
    }

    func referencePDFFilePath(refToPage: Int) -> String? {

        let res = "\(self.referencePDF_prefix)_figure_\(refToPage)"
        let path = NSBundle.mainBundle().pathForResource(res, ofType: "pdf")
        return path
        
    }
    
    func isPassed(quiz: Quiz) -> Bool {
        let passed = quiz.score?.floatValue >= passingScore
        return passed
    }
    
    func isCompleted(quiz: Quiz) -> Bool {
        let completed = quiz.score != nil
        return completed
    }
    
    func loadRandomQuestion() {
        
        if (self.questions.count == 0) {
            return
        }
        let rand : Int = Int(arc4random_uniform(UInt32(self.questions.count)))
        currentQuestion = self.questions.objectAtIndex(rand) as? QuizQuestion
        questions.removeObjectAtIndex(rand)
        currentQuestionNbr = currentQuestionNbr + 1
    }
    
    func loadIncorrectAnswer(ndx: Int) {
        if (currentQuiz == nil || currentQuiz.quizToIncorrectAnswer == nil || (ndx + 1) > currentQuiz.quizToIncorrectAnswer?.count) {
            return
        }
        
        currentIncorrectAnswer = currentQuiz.quizToIncorrectAnswer?.allObjects[ndx] as? IncorrectAnswer
        currentQuestion = questionsDict.objectForKey(currentIncorrectAnswer.questionKey!) as? QuizQuestion
        currentQuestionNbr = ndx + 1
    }
    
    func loadQuizNew(quizType: QuizType) {
        questionMode = QuestionMode.Quiz
        
        let (filename, ext) = (quizType.filenameExt())
        print("loading quiz new: \(filename).\(ext)")
        loadQuestionsFromFile(filename, type: ext, resumeQuiz: nil)
        
        let quiz = DataMgr.sharedInstance.createQuizWithTitle(quizType.rawValue, filename: filename, ext: ext)
        currentQuiz = quiz
        currentQuiz.totalQuestions = totalQuestionsCnt
    }
    
    func loadQuizForReview(quiz: Quiz) {
        questionMode = QuestionMode.Review

        let segs = quiz.filename?.componentsSeparatedByString(".")
        let filename = segs![0]
        let ext = segs![1]
        print("loading quiz for review: \(filename).\(ext)")
        loadQuestionsFromFile(filename, type: ext, resumeQuiz: nil)
        currentQuiz = quiz
        currentQuiz.totalQuestions = totalQuestionsCnt
    }
    
    func loadQuizForResume(quiz: Quiz) {
        questionMode = QuestionMode.Review
        
        let segs = quiz.filename?.componentsSeparatedByString(".")
        let filename = segs![0]
        let ext = segs![1]
        print("loading quiz for review: \(filename).\(ext)")
        // pass the quiz to the question loader
        loadQuestionsFromFile(filename, type: ext, resumeQuiz: quiz)
        
        currentQuiz = quiz
        currentQuiz.totalQuestions = totalQuestionsCnt
    }
    
}
