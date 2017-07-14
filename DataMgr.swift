//
//  DataMgr.swift
//  PilotHandy
//
//  Created by Jerry Walton on 6/25/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation
import CoreData

class DataMgr {
    // singleton
    static let sharedInstance = DataMgr()
    
    let pilotHandyDB = CoreDataStack.init(modelName: "sUASQuiz")
    let dateFormatter: NSDateFormatter!
    
    init() {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    }
    
    func quizzes() -> [Quiz] {
        return (CoreDataHelper.fetchObjectsWithEntityName("Quiz", predicate: nil, sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)], coreDataStack: pilotHandyDB) as? [Quiz])!
    }

    func createQuizWithTitle(title: String, filename: String, ext: String) -> Quiz {
        
        let quiz = NSEntityDescription.insertNewObjectForEntityForName("Quiz", inManagedObjectContext: pilotHandyDB.managedObjectContext!) as! Quiz

        quiz.title = title
        quiz.date = NSDate()
        quiz.filename = "\(filename).\(ext)"
        
        pilotHandyDB.saveContext()
        
        return quiz
    }
    
    func deleteQuiz(quiz: Quiz) {

        pilotHandyDB.managedObjectContext?.deleteObject(quiz)
        pilotHandyDB.saveContext()
    }
    
    func saveQuizAnswer(quiz: Quiz, questionKey: String, answerKey: String, correct: Bool) {

        if (correct) {
            quiz.correctAnswers = NSNumber(int: (quiz.correctAnswers?.intValue)! + 1)
        } else{
            var responseExists = false
            let incorrectAnswers = quiz.quizToIncorrectAnswer
            for incorrectAnswer in (incorrectAnswers?.allObjects)! {
                let currentAnswer = incorrectAnswer as! IncorrectAnswer
                if currentAnswer.questionKey == questionKey {
                    responseExists = true
                    break
                }
            }
            if !responseExists {
                
                let incorrectAnswer = NSEntityDescription.insertNewObjectForEntityForName("IncorrectAnswer", inManagedObjectContext: pilotHandyDB.managedObjectContext!) as! IncorrectAnswer
                incorrectAnswer.answerKey = answerKey
                incorrectAnswer.questionKey = questionKey
                
                let newIncorrectAnswers = NSMutableSet(set: quiz.quizToIncorrectAnswer!)
                newIncorrectAnswers.addObject(incorrectAnswer)
                quiz.quizToIncorrectAnswer = newIncorrectAnswers
            }
        }
        pilotHandyDB.saveContext()
        
    }
    
    func determineQuizScore(quiz: Quiz) -> Float {
        let correct = (quiz.correctAnswers?.floatValue)!
        let total = (quiz.totalQuestions?.floatValue)!

        let score = correct / total
        //print("\(score) = \(correct) / \(total)")
        let scorePct = score * 100
        
        quiz.score = scorePct
        pilotHandyDB.saveContext()
        
        return scorePct
    }
    
    func updateQuizComplete(quiz: Quiz) {
        quiz.complete = true
        pilotHandyDB.saveContext()
    }
    
    func updateQuizAskedQuestion(quiz: Quiz, questionKey: String) {
        let askedQuestion = NSEntityDescription.insertNewObjectForEntityForName("AskedQuestion", inManagedObjectContext: pilotHandyDB.managedObjectContext!) as! AskedQuestion
        quiz.addToQuizToAskedQuestion(askedQuestion)
        pilotHandyDB.saveContext()
    }

}
