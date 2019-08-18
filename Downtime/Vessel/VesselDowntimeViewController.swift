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
    
    @IBOutlet var dayShiftRadioButton: NSButton!
    @IBOutlet var nightShiftRadioButton: NSButton!
    
    @IBOutlet var spreadsheetGeneratorButton: NSButton!
    @IBOutlet var textReportGeneratorButton: NSButton!
    @IBOutlet var removalButton: NSButton!
    
    let startTimes = StartTimes()
    let endTimes = EndTimes()
    let totalTimes = EnteredTotalTimes()
    
    let spreadsheetGenerator = VesselDowntimeSpreadsheetGenerator()
    let textReportGenerator = VesselDowntimeTextReportGenerator()
    
    let selectionChangedNotication = NSTableView.selectionDidChangeNotification
    let popupWillAppearNotification = NSComboBox.willPopUpNotification
    
    let nc = NotificationCenter.default
    let fm = FileManager.default
    
    var downtimeEntries = [[String: String]]() {
        didSet {
            downtimeEntries = downtimeEntries.sorted(by: {
                
                if $0.isANote() && $0["sortTime"]!.isEmpty && $0["endTime"]!.isEmpty { //If entry is a note with no times, sort to the end of the table
                    return false
                } else if $1.isANote() && $1["sortTime"]!.isEmpty && $1["endTime"]!.isEmpty { //If entry is a note with no times, sort to the end of the table
                    return true
                }
                
                if $0["sortTime"]! != $1["sortTime"]! {  //If sort times (start times) are not the same, sort by start time
                    return $0["sortTime"]! < $1["sortTime"]!
                } else { //If sort times are the same, sort by end time
                    return $0["endTime"]! < $1["endTime"]!
                }
            })
            
            if downtimeValuesChangedBetween(newValues: downtimeEntries, oldValues: oldValue) {
                downtimeTableView.reloadData()
            }
        }
    }
    
    var dateFetcherTimer = Timer()
    var saveDataTimer = Timer()
    
    var timeFieldFormatter = TimeFieldFormatter()
    var reasonFieldFormatter = ReasonFieldFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downtimeTableView.rowHeight = 26
        
        fetchTimes()
        
        startTimeComboBox.usesDataSource = true
        startTimeComboBox.dataSource = startTimes
        startTimeComboBox.formatter = timeFieldFormatter
        startTimeComboBox.reloadData()
        
        endTimeComboBox.usesDataSource = true
        endTimeComboBox.dataSource = endTimes
        endTimeComboBox.formatter = timeFieldFormatter
        endTimeComboBox.reloadData()
        
        downtimeReasonField.formatter = reasonFieldFormatter
        
        totalTimeComboBox.usesDataSource = true
        totalTimeComboBox.dataSource = totalTimes
        totalTimeComboBox.reloadData()
        
        dateFetcherTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimes), userInfo: nil, repeats: true)
        saveDataTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(saveData), userInfo: nil, repeats: true)
        
        nc.addObserver(self, selector: #selector(enableRemovalButton), name: selectionChangedNotication, object: nil)
        nc.addObserver(self, selector: #selector(fetchTotalTimes), name: popupWillAppearNotification, object: nil)
        
        nc.addObserver(self, selector: #selector(saveData), name: NSApplication.willTerminateNotification, object: nil)
        nc.addObserver(self, selector: #selector(loadData), name: NSApplication.didFinishLaunchingNotification, object: nil)
        
        nc.addObserver(self, selector: #selector(selectMechanical), name: .entryIsMechanical, object: nil)
        nc.addObserver(self, selector: #selector(selectOperational), name: .entryIsOperational, object: nil)
        nc.addObserver(self, selector: #selector(selectEStop), name: .entryIsEStop, object: nil)
        nc.addObserver(self, selector: #selector(selectSystem), name: .entryIsSystem, object: nil)
        nc.addObserver(self, selector: #selector(selectDeadtime), name: .entryIsDeadtime, object: nil)
        nc.addObserver(self, selector: #selector(selectNote), name: .entryIsNote, object: nil)
        nc.addObserver(self, selector: #selector(deselectCategory), name: .entryIsNotPrefixed, object: nil)
    }
    
    @objc func saveData() {
        
        let saveDirectory: String = NSHomeDirectory() + "/Documents/"
        var sessionDataContents = [String]()
        
        for entry in downtimeEntries {
            var data = String()
            data.append("\(entry["startTime"]!)|")
            data.append("\(entry["sortTime"]!)|")
            data.append("\(entry["endTime"]!)|")
            data.append("\(entry["downtimeReason"]!)|")
            data.append("\(entry["totalTime"]!)|")
            data.append("\(entry["category"]!)|+")
            
            sessionDataContents.append(data)
            
        }
        
        let fileContents = sessionDataContents.joined()
        let fileName = "downtime_session_data.txt"
        
        let destination = saveDirectory + fileName
        
        do {
            try fileContents.write(to: URL(fileURLWithPath: destination), atomically: true, encoding: .utf8)
        } catch {
            Swift.print(error)
        }
        
    }
    
    @objc func loadData() {
        var fileContents = String()
        var fileCreationDate = Date()
        let loadPath: String = NSHomeDirectory() + "/Documents/downtime_session_data.txt"

        if fm.fileExists(atPath: loadPath) {
            do {
                let fileAttributes = try fm.attributesOfItem(atPath: loadPath) as [FileAttributeKey:Any]
                fileCreationDate = fileAttributes[FileAttributeKey.creationDate] as! Date
            } catch {
                Swift.print(error)
            }
            
            let now = Date()
            
            let difference = now.timeIntervalSince(fileCreationDate)
            
            if difference < 28800 {
                fileContents = String(data: fm.contents(atPath: loadPath)!, encoding: .utf8) ?? ""
                var downtimeData = fileContents.components(separatedBy: "+")
                downtimeData.removeLast()
                
                for dataEntry in downtimeData {
                    
                    var data = dataEntry.components(separatedBy: "|")
                    data.removeLast()
                    
                    var entry: [String: String] = [
                        "startTime":"",
                        "sortTime":"",
                        "endTime":"",
                        "downtimeReason":"",
                        "totalTime":"",
                        "category":""
                    ]

                    entry.updateValue(data[0], forKey: "startTime")
                    entry.updateValue(data[1], forKey: "sortTime")
                    entry.updateValue(data[2], forKey: "endTime")
                    entry.updateValue(data[3], forKey: "downtimeReason")
                    entry.updateValue(data[4], forKey: "totalTime")
                    entry.updateValue(data[5], forKey: "category")
                    
                    downtimeEntries.append(entry)
                    
                }
                
            } else {
                do {
                    try fm.removeItem(at: URL(fileURLWithPath: loadPath))
                } catch {
                    Swift.print(error)
                }
            }
        
            
        }
        
        
    }
    
    @objc func selectMechanical() {
        categoryComboBox.selectItem(at: 0)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectOperational() {
        categoryComboBox.selectItem(at: 1)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectEStop() {
        categoryComboBox.selectItem(at: 2)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectSystem() {
        categoryComboBox.selectItem(at: 3)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectDeadtime() {
        categoryComboBox.selectItem(at: 4)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectNote() {
        categoryComboBox.selectItem(at: 5)
        categorySelected(categoryComboBox)
    }
    
    @objc func deselectCategory() {
        categoryComboBox.deselectItem(at: categoryComboBox.indexOfSelectedItem)
        categorySelected(categoryComboBox)
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
            if newValues.count < oldValues.count {
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
    
    func enableAddDowntimeButton() {
        addDowntimeButton.isEnabled = true
    }
    
    func contentIsValid(cbx: NSComboBox) -> Bool {
        if cbx.stringValue.length == 4 && cbx.stringValue.isNumeric {
            return true
        } else { return false }
    }
    
    @objc func fetchTotalTimes() {
        if contentIsValid(cbx: startTimeComboBox) && contentIsValid(cbx: endTimeComboBox) {
            totalTimes.getTotalTimes(start: startTimeComboBox.stringValue, end: endTimeComboBox.stringValue)
        }
        totalTimeComboBox.reloadData()
    }
    
    func getSortingTime(for time: String) -> String {
        
        guard time.length == 4 else { return time }
        
        let minutes = time.substring(fromIndex: 2)
        var hour = Int(time.substring(toIndex: time.length - 2))!
        
        if hour >= 0 && hour <= 7 {
            hour += 24
        }
        
        var strHour = String(hour)
        if strHour.length == 1 {
            strHour.insert("0", at: String.Index.init(utf16Offset: 0, in: strHour))
        }
        
        let sortTime = strHour + minutes
        
        return sortTime
    }
    
    @IBAction func addDowntimeEntry(_ sender: Any) {
        
        let prefixes: [String: String] = [
            "Mechanical":"#mech",
            "Operational Scenario":"#op",
            "E-Stop":"#estop",
            "System / Tech":"#sys",
            "Deadtime":"#dead",
            "Note":"#note"
        ]
        
        var entry: [String: String] = [
            "startTime":"",
            "sortTime":"",
            "endTime":"",
            "downtimeReason":"",
            "totalTime":"",
            "category":""
        ]
        
        if !categoryComboBox.stringValue.isEmpty {
            entry.updateValue(categoryComboBox.stringValue, forKey: "category")
        }

        
        if !startTimeComboBox.stringValue.isEmpty {
            entry.updateValue(startTimeComboBox.stringValue, forKey: "startTime")
            
            if entry.isANote() {
                let hour = startTimeComboBox.stringValue.substring(toIndex: 2)
                let time = hour + "59"
                entry.updateValue(time, forKey: "sortTime")
            } else {
                entry.updateValue(getSortingTime(for: startTimeComboBox.stringValue), forKey: "sortTime")
            }
        }
        
        if endTimeComboBox.stringValue.isEmpty {
            if !entry.isANote() {
                entry.updateValue("missing", forKey: "endTime")
            }
        } else {
            entry.updateValue(endTimeComboBox.stringValue, forKey: "endTime")
        }
        
        if !downtimeReasonField.stringValue.isEmpty {
            
            var reason = downtimeReasonField.stringValue
            
            if let category = entry["category"] {
                
                let prefix = prefixes[category]!
                
                switch category {
                    
                case "Mechanical":
                    if reason.lowercased().hasPrefix(prefix) { //If the string contains the prefix category command
                        let range = reason.lowercased().range(of: prefix)! //Find the range of the prefix
                        reason.removeSubrange(range) //Remove the range of the prefix
                        reason = reason.trimmingCharacters(in: .whitespaces) //Remove any possible leading whitespace
                    }
                case "Operational Scenario":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                case "E-Stop":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                case "System / Tech":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                case "Deadtime":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                case "Note":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                default:
                    break //Should not be reached
                    
                }
            }
            
            entry.updateValue(reason, forKey: "downtimeReason")
        }
        
        if !totalTimeComboBox.stringValue.isEmpty {
            entry.updateValue(totalTimeComboBox.stringValue, forKey: "totalTime")
        }
        
        downtimeEntries.append(entry)
        
        clearBoxes()
        
        if entry.isANote() {
            totalTimeComboBox.isEnabled = true
        }
        
        addDowntimeButton.keyEquivalent = String("")
    }
    
    @IBAction func tableCellValueEdited(_ sender: NSTextField) {
        
        let selectedRow = downtimeTableView.row(for: sender)
        
        if let columnIdentifier: String = sender.superview?.identifier?.rawValue {
            if selectedRow != -1 {
                downtimeEntries[selectedRow].updateValue(sender.stringValue, forKey: columnIdentifier)
                
                if columnIdentifier == "startTime" {
                    downtimeEntries[selectedRow].updateValue(getSortingTime(for: sender.stringValue), forKey: "sortTime")
                }
                
            }
        }
    }
    
    @IBAction func categorySelected(_ sender: NSComboBox) {
        if !categoryComboBox.stringValue.isEmpty {
            
            let array = [unichar(NSCarriageReturnCharacter)]
            addDowntimeButton.keyEquivalent = String(utf16CodeUnits: array, count: 1)
            
        }
        
        if categoryComboBox.stringValue == "Note" {
            if totalTimeComboBox.indexOfSelectedItem != -1 {
                totalTimeComboBox.deselectItem(at: totalTimeComboBox.indexOfSelectedItem)
            }
            totalTimeComboBox.isEnabled = false
        } else if categoryComboBox.indexOfSelectedItem == -1 || categoryComboBox.stringValue != "Note" {
            totalTimeComboBox.isEnabled = true
        }
        
        
    }
    
    func clearBoxes() {
        startTimeComboBox.stringValue.removeAll()
        endTimeComboBox.stringValue.removeAll()
        downtimeReasonField.stringValue.removeAll()
        totalTimeComboBox.stringValue.removeAll()
        categoryComboBox.stringValue.removeAll()
    }
    
    @IBAction func shiftSelected(_ sender: Any) {
        textReportGeneratorButton.isEnabled = true
        spreadsheetGeneratorButton.isEnabled = true
    }
    
    func tableContentIsValidForExport() -> Bool {
        
        for entry in downtimeEntries {
            
            if !entry.isANote() {
                guard entry["startTime"]!.count == 4 && entry["startTime"]!.isNumeric else { return false }
                guard entry["endTime"]!.count == 4 && entry["endTime"]!.isNumeric else { return false }
                guard !entry["totalTime"]!.isEmpty else { return false }
            }
            
            guard !entry["downtimeReason"]!.isEmpty else { return false }
            guard !entry["category"]!.isEmpty else { return false }
        }
        
        return true
    }
    
    @IBAction func generateTextReport(_ sender: Any) {
        if tableContentIsValidForExport() {
            if dayShiftRadioButton.state == .on {
                textReportGenerator.getDowntimeEntries(data: downtimeEntries, shift: "day")
            } else if nightShiftRadioButton.state == .on {
                textReportGenerator.getDowntimeEntries(data: downtimeEntries, shift: "night")
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "Missing values!"
            alert.informativeText = "You are missing values for one or more downtime entries. Please check the downtime you've entered and make sure you have all values entered before exporting."
            alert.runModal()
        }
    }
    
    @IBAction func generateSpreadsheet(_ sender: Any) {
        
        if tableContentIsValidForExport() {
            if dayShiftRadioButton.state == .on {
                spreadsheetGenerator.getDowntimeEntries(data: downtimeEntries, shift: "day")
            } else if nightShiftRadioButton.state == .on {
                spreadsheetGenerator.getDowntimeEntries(data: downtimeEntries, shift: "night")
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "Missing values!"
            alert.informativeText = "You are missing values for one or more downtime entries. Please check the downtime you've entered and make sure you have all values entered before exporting."
            alert.runModal()
        }
    }
    
    @objc func enableRemovalButton() {
        
        let selectedRows = downtimeTableView.selectedRowIndexes
        
        if !selectedRows.isEmpty {
            removalButton.isEnabled = true
        } else { removalButton.isEnabled = false }
        
    }
    
    @IBAction func removeDowntimeEntries(_ sender: Any) {
        
        let selectedRows = downtimeTableView.selectedRowIndexes
        let indicesToRemove = selectedRows.reversed()
        
        for index in indicesToRemove {
            downtimeEntries.remove(at: index)
        }
        
        downtimeTableView.reloadData()
        removalButton.isEnabled = false
        
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
    
    
}
