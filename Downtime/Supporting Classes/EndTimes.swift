//
//  EndTimes.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/9/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class EndTimes: NSObject, NSComboBoxDataSource {

    var date = Date()
    
    var times = [String]()
    let suffixes = ["00","06","12","18","24","30","36","42","48","54"]
    
    func fetchEndTimes() {
        date = Date()
        for suffix in suffixes {
            times.append(date.hour() + suffix)
        }
    }
    
    @objc func updateEndTimes() {
        date = Date()
        times.removeAll()
        
        for suffix in suffixes {
            times.append(date.hour() + suffix)
        }
    }
    
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return suffixes.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return times[index]
    }


}
