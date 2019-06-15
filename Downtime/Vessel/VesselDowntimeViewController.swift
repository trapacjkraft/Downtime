//
//  ViewController.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/4/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class VesselDowntimeViewController: NSTabViewController {

    @IBOutlet var startTimeComboBox: NSComboBox!
    @IBOutlet var endTimeComboBox: NSComboBox!
    @IBOutlet var downtimeReasonField: NSTextField!
    @IBOutlet var totalTimeComboBox: NSComboBox!
    @IBOutlet var categoryComboBox: NSComboBox!
    @IBOutlet var addDowntimeButton: NSButton!
    
    @IBOutlet var downtimeTableView: NSTableView!
    @IBOutlet var exportButton: NSButton!
        
    let startTimes = StartTimes()
    let endTimes = EndTimes()
    let totalTimes = TotalTimes()
    
    let reporter = VesselDowntimeReporter()
    
    var downtimeEntries = [[String: String]]() {
        didSet {
            downtimeTableView.reloadData()
        }
    }
    
    var dateFetcherTimer = Timer()
    
    var hasEndTime = false {
        didSet {
            if hasEndTime {
                enableTTLCBX()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTimes()
        
        startTimeComboBox.usesDataSource = true
        startTimeComboBox.dataSource = startTimes
        startTimeComboBox.reloadData()
        
        endTimeComboBox.usesDataSource = true
        endTimeComboBox.dataSource = endTimes
        endTimeComboBox.reloadData()
        
        totalTimeComboBox.usesDataSource = true
        totalTimeComboBox.dataSource = totalTimes
        totalTimeComboBox.reloadData()
        
        dateFetcherTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimes), userInfo: nil, repeats: true)
    }
    
    func fetchTimes() {
        startTimes.fetchStartTimes()
        endTimes.fetchEndTimes()
    }
    
    @objc func updateTimes() {
        startTimes.updateStartTimes()
        startTimeComboBox.reloadData()
        
        endTimes.updateEndTimes()
        endTimeComboBox.reloadData()
    }
    
    func enableTTLCBX() {
        totalTimeComboBox.isEnabled = true
    }
    
    func enableAddDowntimeButton() {
        addDowntimeButton.isEnabled = true
    }
    
    @IBAction func endTimeDoneEditing(_ sender: Any) {
        
        guard !endTimeComboBox.stringValue.isEmpty && endTimeComboBox.stringValue.length == 4 else {
            return
        }
        
        hasEndTime = true
        
        totalTimes.getTotalTimes(start: startTimeComboBox.stringValue, end: endTimeComboBox.stringValue)
        totalTimeComboBox.reloadData()
    }
    
    @IBAction func addDowntimeEntry(_ sender: Any) {
        
        guard !startTimeComboBox.stringValue.isEmpty else {
            return
        }
        
        guard !endTimeComboBox.stringValue.isEmpty else {
            return
        }
        
        guard !downtimeReasonField.stringValue.isEmpty else {
            return
        }
        
        guard !totalTimeComboBox.stringValue.isEmpty else {
            return
        }
        
        guard !categoryComboBox.stringValue.isEmpty else {
            return
        }
        
        var entry: [String: String] = [
            "startTime":"",
            "endTime":"",
            "downtimeReason":"",
            "totalTime":"",
            "category":""
        ]
        
        entry.updateValue(startTimeComboBox.stringValue, forKey: "startTime")
        entry.updateValue(endTimeComboBox.stringValue, forKey: "endTime")
        entry.updateValue(downtimeReasonField.stringValue, forKey: "downtimeReason")
        entry.updateValue(totalTimeComboBox.stringValue, forKey: "totalTime")
        entry.updateValue(categoryComboBox.stringValue, forKey: "category")
        
        downtimeEntries.append(entry)
        
        clearBoxes()
        
    }
    
    func clearBoxes() {
        startTimeComboBox.stringValue.removeAll()
        endTimeComboBox.stringValue.removeAll()
        downtimeReasonField.stringValue.removeAll()
        totalTimeComboBox.stringValue.removeAll()
        categoryComboBox.stringValue.removeAll()
    }
    
    @IBAction func writeReport(_ sender: Any) {
        reporter.getDowntimeEntries(data: downtimeEntries)
    }
    
    
    
}

extension VesselDowntimeViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return downtimeEntries.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let item = downtimeEntries[row]
        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
        
        cell?.textField?.stringValue = item[(tableColumn?.identifier.rawValue)!]!
        
        return cell
    }
    
    /*func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        return downtimeEntries[row]
    }*/
    
    
}
