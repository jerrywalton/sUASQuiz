//
//  AnswerTVCell.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/21/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import UIKit

/*
 class QuizQuestion {
 
 var key: String!
 var referTo: String!
 var question: String!
 var answers: NSArray!
 var correctAnswer: NSDictionary!
 var acsCodes: String!
 */
class AnswerTVCell: BaseTVCell {
    
    @IBOutlet var answerLbl : UILabel!
    
    override class func identifier() -> String {
        return "AnswerTVCell"
    }
}