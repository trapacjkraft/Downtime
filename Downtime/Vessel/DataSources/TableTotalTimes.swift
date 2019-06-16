//
//  TableTotalTimes.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/15/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class TableTotalTimes: NSObject, NSComboBoxDataSource, NSComboBoxDelegate {
    
    var times = [String]()
    
    var startTime = String()
    var endTime = String()
    
    func getTotalTimes(start: String, end: String) {
        
        times.removeAll()
        
        startTime = start
        endTime = end
        
        let startingHour = Int(startTime.substring(toIndex: startTime.count - 2))
        var endingHour = Int(endTime.substring(toIndex: endTime.count - 2))
        let endingMinutes = endTime.substring(fromIndex: 2)
        
        if endingHour! < startingHour! {
            endingHour = endingHour! + 24
        }
        
        endTime = String(endingHour!) + endingMinutes
        
        Swift.print(endTime)
        
        let start = Int(startTime)
        let end = Int(endTime)
        
        var hourDiff = end! / 100 - start! / 100 - 1
        var minDiff = end! % 100 + (60 - start! % 100)
        
        if minDiff >= 60 {
            hourDiff += 1
            minDiff -= 60
        }
        
        
        let timeDiff = (Double(minDiff) / 60) + Double(hourDiff)
        
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 1
        
        for index in 1...7 {
            let value = nf.string(from: (NSNumber(value: timeDiff * Double(index))))!
            times.append(value)
        }
        
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return 7
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if !times.isEmpty {
            return times[index]
        }
        return ""
    }
    
    func comboBoxWillPopUp(_ notification: Notification) {
        
        if endTime.length == 4 && endTime.isNumeric {
            getTotalTimes(start: startTime, end: endTime)
        }
    }

}
