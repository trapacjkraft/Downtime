//
//  TotalTimesTableCellView.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/15/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class TotalTimesTableCellView: NSTableCellView {

    @IBOutlet var totalTimesComboBox: NSComboBox!
    
    var totalTimes = TableTotalTimes()
    
    override func viewWillDraw() {
        Swift.print("x")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
