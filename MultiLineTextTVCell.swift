//
//  MultiLineTextTVCell.swift
//  PilotHandy
//
//  Created by Jerry Walton on 7/23/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import UIKit

class MultiLineTextTVCell: BaseTVCell {
    
    @IBOutlet var textLbl : KILabel!
    
    override class func identifier() -> String {
        return "MultiLineTextTVCell"
    }
}