//
//  RailTotalTimesTableCellView.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/17/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class RailTotalTimesTableCellView: NSTableCellView {

    @IBOutlet var totalTimesComboBox: NSComboBox!
    
    var totalTimes = RailTableTotalTimes()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
