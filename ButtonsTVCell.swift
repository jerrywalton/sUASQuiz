//
//  ButtonsTVCell.swift
//  sUASQuiz
//
//  Created by Jerry Walton on 12/18/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation

class ButtonsTVCell: BaseTVCell {
    
    @IBOutlet var leftButton : UIButton!
    @IBOutlet var rightButton : UIButton!
    
    override class func identifier() -> String {
        return "ButtonsTVCell"
    }
}
