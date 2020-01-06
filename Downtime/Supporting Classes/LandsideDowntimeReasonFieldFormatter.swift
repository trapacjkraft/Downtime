//
//  LandsideDowntimeReasonFieldFormatter.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/4/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class LandsideDowntimeReasonFieldFormatter: Formatter {

    let nc = NotificationCenter.default
    
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
        
        if partialString.lowercased().hasPrefix("#light") || partialString.lowercased() == "#light" {
            nc.post(name: .entryIsLightCurtainBreak, object: nil)
        } else if partialString.lowercased().hasPrefix("#reland") || partialString.lowercased() == "#reland" {
            nc.post(name: .entryIsReland, object: nil)
        } else if partialString.lowercased().hasPrefix("#flip") || partialString.lowercased() == "#flip" {
            nc.post(name: .entryIsFlip, object: nil)
        } else if partialString.lowercased().hasPrefix("#asc") || partialString.lowercased() == "#asc" {
            nc.post(name: .entryIsASCfault, object: nil)
        } else if partialString.lowercased().hasPrefix("#note") || partialString.lowercased() == "#note" {
            nc.post(name: .entryIsNote, object: nil)
        } else {
            nc.post(name: .entryIsNotPrefixed, object: nil)
        }
        
        return true
        
    }
    
}
