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
    let totalTimes = EnteredTotalTimes()
    
    let reporter = VesselDowntimeReporter()
    
    var downtimeEntries = [[String: String]]() {
        didSet {
            downtimeEntries = downtimeEntries.sorted(by: {
                if $0["startTime"]! != $1["startTime"]! {
                    return $0["startTime"]! < $1["startTime"]!
                } else {
                    return $0["endTime"]! < $1["endTime"]!
                }
            })
            
            if downtimeValuesChangedBetween(newValues: downtimeEntries, oldValues: oldValue) {
                downtimeTableView.reloadData()
            }
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
        
        downtimeTableView.rowHeight = 26
        
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
    
    func downtimeValuesChangedBetween(newValues: [[String: String]], oldValues: [[String: String]]) -> Bool {
        
        var index = 0
        
        for _ in newValues {
            if oldValues.isEmpty {
                return true
            }
            if oldValues.count < newValues.count {
                return true
            }
            if newValues[index] != oldValues[index] && index < oldValues.count {
                return true
            }
            index += 1
        }
        
        return false
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
        
        if endTimeComboBox.stringValue.length == 4 && endTimeComboBox.stringValue.isNumeric {
            totalTimes.getTotalTimes(start: startTimeComboBox.stringValue, end: endTimeComboBox.stringValue)
            hasEndTime = true
        }
        
        totalTimeComboBox.reloadData()
    }
    
    @IBAction func addDowntimeEntry(_ sender: Any) {
        
        var entry: [String: String] = [
            "startTime":"",
            "endTime":"",
            "downtimeReason":"",
            "totalTime":"",
            "category":""
        ]
        
        if !startTimeComboBox.stringValue.isEmpty {
            entry.updateValue(startTimeComboBox.stringValue, forKey: "startTime")
        }
        
        if endTimeComboBox.stringValue.isEmpty {
            entry.updateValue("missing", forKey: "endTime")
        } else {
            entry.updateValue(endTimeComboBox.stringValue, forKey: "endTime")
        }
        
        if !downtimeReasonField.stringValue.isEmpty {
            entry.updateValue(downtimeReasonField.stringValue, forKey: "downtimeReason")
        }
        
        if !totalTimeComboBox.stringValue.isEmpty {
            entry.updateValue(totalTimeComboBox.stringValue, forKey: "totalTime")
        }
        
        if !categoryComboBox.stringValue.isEmpty {
            entry.updateValue(categoryComboBox.stringValue, forKey: "category")
        }
        
        downtimeEntries.append(entry)
        
        clearBoxes()
        
    }
    
    @IBAction func tableCellValueEdited(_ sender: NSTextField) {
        
        let selectedRow = downtimeTableView.row(for: sender)
        
        if let columnIdentifier: String = sender.superview?.identifier?.rawValue {
            if selectedRow != -1 {
                downtimeEntries[selectedRow].updateValue(sender.stringValue, forKey: columnIdentifier)
            }
        }
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
        
        if cell!.identifier!.rawValue == "category" {
            let comboCell = cell as? CategoryComboTableCellView
            comboCell?.categoryComboBox.stringValue = item[(tableColumn!.identifier.rawValue)]!
            return comboCell
        }
        
        if cell!.identifier!.rawValue == "totalTime" {
            let comboCell = cell as! TotalTimesTableCellView
            
            comboCell.totalTimes.startTime = item["startTime"]!
            comboCell.totalTimes.endTime = item["endTime"]!
            
            comboCell.totalTimesComboBox.dataSource = comboCell.totalTimes
            comboCell.totalTimesComboBox.delegate = comboCell.totalTimes
            
            if item["endTime"]!.length == 4 && item["endTime"]!.isNumeric {
                comboCell.totalTimes.getTotalTimes(start: comboCell.totalTimes.startTime, end: comboCell.totalTimes.endTime)
                comboCell.totalTimesComboBox.reloadData()
            }
        
            comboCell.totalTimesComboBox.stringValue = item[(tableColumn!.identifier.rawValue)]!
            
            return comboCell
        }
        
        cell?.textField?.stringValue = item[(tableColumn?.identifier.rawValue)!]!
        return cell
    }
    

    /*func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        return downtimeEntries[row]
    }*/
    
    
}
