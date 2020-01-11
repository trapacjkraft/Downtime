//
//  NumberFieldFormatter.swift
//  Downtime
//
//  Created by Joshua Kraft on 7/20/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class NumberFieldFormatter: Formatter {

    let allowedLength = 4
    
    override func string(for obj: Any?) -> String? {
        
        if let stringValue = obj as? String {
            return stringValue
        }
        
        return nil
        
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if obj != nil {
            obj?.pointee = string as AnyObject
        }
        
        return true
    }
    
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.count == 0 {
            return true
        }
        
        if partialString.count <= 4 {
            if partialString.isNumeric {
                return true
            } else {
                var badCharacters = [Int]()
                var updatedString = String()
                
                for (index, character) in partialString.enumerated() {
                    if !character.isNumber {
                        badCharacters.append(index)
                    }
                }
                
                updatedString = partialString
                
                for index in badCharacters.reversed() {
                    updatedString.remove(at: String.Index(utf16Offset: index, in: updatedString))
                }
                
                newString?.pointee = updatedString as NSString
                error?.pointee = "Found non-numeric text and removed it."
                
                return false
            }
        }
        
        if partialString.count > 4 {
            return false
        }
        
        return true
    }
    
}
