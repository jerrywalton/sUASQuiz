//
//  Utils.swift
//  PilotHandy
//
//  Created by Jerry Walton on 4/1/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation

class Utils {
    
    class func jsonFromFile(file: String, type: String) -> NSDictionary! {
        
        var json: NSDictionary!
        
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: type) {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    //json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments) as! NSDictionary
                } catch {}
            } catch {}
        }
        
        return json
    }
    
}
