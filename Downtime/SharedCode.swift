//
//  SharedCode.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/8/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

extension Date {
    func hour() -> String {
        let hour = Calendar.current.component(.hour, from: self)
        
        if hour < 10 {
            return "0" + String(hour)
        } else {
            return String(hour)
        }
    }
}

extension String {
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let numbers: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: numbers)
    }
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
}


class SharedCode: NSObject {

}
