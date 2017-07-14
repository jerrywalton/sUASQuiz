//
//  QuizTVCell.swift
//  PilotHandy
//
//  Created by Jerry Walton on 8/2/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import UIKit

class QuizTVCell: BaseTVCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var questionsTitle: UILabel!
    @IBOutlet var questionsTotalTitle: UILabel!
    @IBOutlet var questionsTotal: UILabel!
    @IBOutlet var questionsIncorrectTitle: UILabel!
    @IBOutlet var questionsIncorrect: UILabel!
    @IBOutlet var circularView: CircularProgressView!
    @IBOutlet var score: UILabel!
    @IBOutlet var passFail: UILabel!
    @IBOutlet var resumeBtn: UIButton!
    @IBOutlet var reviewBtn: UIButton!
    
    override class func identifier() -> String {
        return "QuizTVCell"
    }
}
