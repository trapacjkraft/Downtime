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
    
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let _indices = indices(of: searchString)
        let count = searchString.count
        return _indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
    
    func withBoldText(boldPartsOfString: Array<NSString>, font: NSFont!, boldFont: NSFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont!]
        let boldString = NSMutableAttributedString(string: self as String, attributes:nonBoldFontAttribute)
        for i in 0 ..< boldPartsOfString.count {
            boldString.addAttributes(boldFontAttribute, range: (self as NSString).range(of: boldPartsOfString[i] as String))
        }
        return boldString
    }
    
}

extension Dictionary where Key == String, Value == String {
    
    func hasStartTime() -> Bool {
        if !self["startTime"]!.isEmpty {
            return true
        } else { return false }
    }
    
    func hasEndTime() -> Bool {
        if !self["endTime"]!.isEmpty {
            return true
        } else { return false }
    }
    
    func isANote() -> Bool {
        if self["category"] == "Note" {
            return true
        } else { return false }
    }
}

extension Notification.Name {
    static let entryIsNotPrefixed = Notification.Name("entryIsNotPrefixed")
    static let entryIsMechanical = Notification.Name("entryIsMechanical")
    static let entryIsOperational = Notification.Name("entryIsOperational")
    static let entryIsEStop = Notification.Name("entryIsEStop")
    static let entryIsSystem = Notification.Name("entryIsSystem")
    static let entryIsDeadtime = Notification.Name("entryIsDeadtime")
    static let entryIsNote = Notification.Name("entryIsNote")
    
    static let checkEntriesForSaveCharacters = Notification.Name("checkEntriesForSaveCharacters")
    static let entriesContainSaveCharacters = Notification.Name("entriesContainSaveCharacters")
    static let entriesDoNotContainSaveCharacters = Notification.Name("entriesDoNotContainSaveCharacters")
    
    static let downtimeEntriesChanged = Notification.Name("downtimeEntriesChanged")
    
    static let indicateBadEntries = Notification.Name("indicateBadEntries")
}

class SharedCode: NSObject {

}
