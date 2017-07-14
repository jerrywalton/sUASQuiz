//
//  ButtonTVCell.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/28/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import UIKit

class ButtonTVCell: BaseTVCell {
    
    @IBOutlet var button : UIButton!
    
    override class func identifier() -> String {
        return "ButtonTVCell"
    }
}