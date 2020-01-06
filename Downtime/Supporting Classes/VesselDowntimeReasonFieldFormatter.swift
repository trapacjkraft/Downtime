//
//  ReasonFieldFormatter.swift
//  Downtime
//
//  Created by Joshua Kraft on 8/16/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class VesselDowntimeReasonFieldFormatter: Formatter {

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
        
        if partialString.lowercased().hasPrefix("#mech") || partialString.lowercased() == "#mech" {
            nc.post(name: .entryIsMechanical, object: nil)
        } else if partialString.lowercased().hasPrefix("#op") || partialString.lowercased() == "#op" {
            nc.post(name: .entryIsOperational, object: nil)
        } else if partialString.lowercased().hasPrefix("#estop") || partialString.lowercased() == "#estop" {
            nc.post(name: .entryIsEStop, object: nil)
        } else if partialString.lowercased().hasPrefix("#sys") || partialString.lowercased() == "#sys" {
            nc.post(name: .entryIsSystem, object: nil)
        } else if partialString.lowercased().hasPrefix("#dead") || partialString.lowercased() == "#dead" {
            nc.post(name: .entryIsDeadtime, object: nil)
        } else if partialString.lowercased().hasPrefix("#note") || partialString.lowercased() == "#note" {
            nc.post(name: .entryIsNote, object: nil)
        } else {
            nc.post(name: .entryIsNotPrefixed, object: nil)
        }
        
        return true
        
    }
    
}
