//
//  Part_107_Question.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/12/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation

/*
{
    "key": "1",
    "referTo": "(Refer to FAA-CT-8080-2G, Figure 21.)",
    "question": "What airport is located approximately 47 (degrees) 40 (minutes) N latitude and 101 (degrees) 26 (minutes) W longitude?",
    "answers": [{
    "key": "A",
    "text": "Mercer County Regional Airport."
    }, {
    "key": "B",
    "text": "Semshenko Airport."
    }, {
    "key": "C",
    "text": "Garrison Airport."
    }],
    "correctAnswer": {
        "key": "C"
    },
    "acsCodes": "PLT064 / UA.V.B.K6a Sources for airport data: Aeronautical charts."
} 
 */
class QuizQuestion {

    var key: String!
    var referTo: String!
    var referToPage: Int!
    var question: String!
    var answers: NSArray!
    var correctAnswer: NSDictionary!
    var acsCodes: String!
    
    init(key: String, referTo: String?, referToPage: Int, question: String, answers: NSArray, correctAnswer: NSDictionary, acsCodes: String?) {
        
        self.key = key
        self.referTo = referTo
        self.referToPage = referToPage
        self.question = question
        self.answers = answers
        self.correctAnswer = correctAnswer
        self.acsCodes = acsCodes
    }
    
    func hasReferTo() -> Bool {
        return self.referTo != nil  && self.referTo.lengthOfBytesUsingEncoding(NSASCIIStringEncoding) > 0
    }
    
}
