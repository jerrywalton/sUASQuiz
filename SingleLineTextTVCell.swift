//
//  SingleLineTextTVCell.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/23/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import UIKit

class SingleLineTextTVCell: BaseTVCell {
    
    @IBOutlet var textLbl : UILabel!
    
    override class func identifier() -> String {
        return "SingleLineTextTVCell"
    }
}