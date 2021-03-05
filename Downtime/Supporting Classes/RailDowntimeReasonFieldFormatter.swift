//
//  RailDowntimeReasonFieldFormatter.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/17/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class RailDowntimeReasonFieldFormatter: Formatter {
    
    let nc = NotificationCenter.default
    let regex = try! NSRegularExpression(pattern: #"(\d{4}/\d{2}/\d{2}).*?(\d{2}:\d{2})"#)
    
    
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
        } else if partialString.lowercased().hasPrefix("#rmg") || partialString.lowercased() == "#rmg" {
            nc.post(name: .entryIsRMGfault, object: nil)
        } else if partialString.lowercased().hasPrefix("#dead") || partialString.lowercased() == "#dead" {
            nc.post(name: .entryIsDeadtime, object: nil)
        } else if partialString.lowercased().hasPrefix("#note") || partialString.lowercased() == "#note" {
            nc.post(name: .entryIsNote, object: nil)
        } else {
            nc.post(name: .entryIsNotPrefixed, object: nil)
        }
        
        if partialString.lowercased().contains("operator") && partialString.lowercased().contains("received") {
            let range = NSRange(location: 0, length: partialString.count)
            if regex.numberOfMatches(in: partialString, options: [], range: range) > 0 {
                let matches = regex.matches(in: partialString, options: [], range: range)
                if let match = matches.first {
                    if let swiftRange = Range(match.range(at: 2), in: partialString) {
                        let theMatchString = partialString[swiftRange]
                        let startTime = theMatchString.replacingOccurrences(of: ":", with: "")
                        var startTimeForSTAARSnotification: [String: String] = ["startTime":startTime]
                        nc.post(name: .entryIsCopiedFromSTAARS, object: nil, userInfo: startTimeForSTAARSnotification)
                        
                    }
                }
            }
        }
        
        //Old bad code that previously determined if the entry was copied from STAARS
        
        /*if partialString.lowercased().contains("call received") && partialString.lowercased().contains(", error") {
            
            var startTimeForSTAARSnotification: [String: String] = ["startTime":""]
            let timeIndexStart = String.Index(utf16Offset: 11, in: partialString)
            let timeIndexEnd = String.Index(utf16Offset: 18, in: partialString)
            let theStartTime = partialString[timeIndexStart...timeIndexEnd].replacingOccurrences(of: ":", with: "").substring(toIndex: 4)
            startTimeForSTAARSnotification.updateValue(theStartTime, forKey: "startTime")
            nc.post(name: .entryIsCopiedFromSTAARS, object: nil, userInfo: startTimeForSTAARSnotification)
        }*/
        
        if partialString.isEmpty {
            
        }
        
        return true
        
    }

}
