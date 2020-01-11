//
//  LandsideDowntimeViewController.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/4/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class LandsideDowntimeViewController: NSTabViewController {

    @IBOutlet var startTimeComboBox: NSComboBox!
    @IBOutlet var endTimeComboBox: NSComboBox!
    @IBOutlet var downtimeReasonTextField: NSTextField!
    @IBOutlet var categoryComboBox: NSComboBox!
    @IBOutlet var addDowntimeButton: NSButton!
    
    @IBOutlet var downtimeTableView: NSTableView!
    
    @IBOutlet var removeDowntimeButton: NSButton!
    
    @IBOutlet var flexHourCheckBox: NSButton!
    @IBOutlet var extendedCheckBox: NSButton!
    
    @IBOutlet var dayShiftRadioButton: NSButton!
    @IBOutlet var nightShiftRadioButton: NSButton!
    @IBOutlet var hootShiftRadioButton: NSButton!
    
    @IBOutlet var generateTextReportButton: NSButton!
    
    let startTimes = StartTimes()
    let endTimes = EndTimes()
    
    let selectionChangedNotification = NSTableView.selectionDidChangeNotification
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
                
                if $0.isAFlip() { //If entry is a flip, sort to the end of the table
                    return false
                } else if $1.isAFlip() {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.nc.post(name: .downtimeEntriesChanged, object: nil)
                })
            }
            
            checkFieldsForSaveCharacters()
        }
    }
    
    var badEntries = [[String: String]]()
    
    let columnNumbers = [
        "startTime": 0,
        "endTime": 1,
        "downtimeReason": 2,
        "category": 3
    ]

    var shiftOptions = [
        "flex": true,
        "extended": false,
    ]

    var entriesHaveSaveCharacters = false
    
    var dateFetcherTimer = Timer()
    var saveDataTimer = Timer()
    
    var timeFieldFormatter = NumberFieldFormatter()
    var landsideReasonFieldFormatter = LandsideDowntimeReasonFieldFormatter()
    
    let lsTotalsView: LandsideTotalsViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("LandsideTotalsViewController")) as! LandsideTotalsViewController

    let saveDataDragWellView: SaveDataDragWellViewController = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SaveDataDragWellViewController")) as! SaveDataDragWellViewController
    var saveDataPath = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetch the start and end times
        fetchTimes()
        
        //set up start and end time combo boxes
        startTimeComboBox.usesDataSource = true
        startTimeComboBox.dataSource = startTimes
        startTimeComboBox.formatter = timeFieldFormatter
        startTimeComboBox.reloadData()
        
        endTimeComboBox.usesDataSource = true
        endTimeComboBox.dataSource = endTimes
        endTimeComboBox.formatter = timeFieldFormatter
        endTimeComboBox.reloadData()
        
        downtimeReasonTextField.formatter = landsideReasonFieldFormatter
        
        dateFetcherTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTimes), userInfo: nil, repeats: true)
        saveDataTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(saveData), userInfo: nil, repeats: true)

        nc.addObserver(self, selector: #selector(enableRemovalButton), name: selectionChangedNotification, object: nil)
                
        nc.addObserver(self, selector: #selector(checkDataAfterEntriesChanged), name: .downtimeEntriesChanged, object: nil)
        nc.addObserver(self, selector: #selector(checkFieldsForSaveCharacters), name: Notification.Name.checkEntriesForSaveCharacters, object: nil)
        nc.addObserver(self, selector: #selector(indicateFromAppDelegate), name: Notification.Name.indicateBadEntries, object: nil)

        nc.addObserver(self, selector: #selector(saveData), name: NSApplication.willTerminateNotification, object: nil)
        nc.addObserver(self, selector: #selector(loadData), name: NSApplication.didFinishLaunchingNotification, object: nil)

        nc.addObserver(self, selector: #selector(selectLightCurtainBreak), name: .entryIsLightCurtainBreak, object: nil)
        nc.addObserver(self, selector: #selector(selectReland), name: .entryIsReland, object: nil)
        nc.addObserver(self, selector: #selector(selectFlip), name: .entryIsFlip, object: nil)
        nc.addObserver(self, selector: #selector(selectASCfault), name: .entryIsASCfault, object: nil)
        nc.addObserver(self, selector: #selector(selectNote), name: .entryIsNote, object: nil)
        nc.addObserver(self, selector: #selector(deselectCategory), name: .entryIsNotPrefixed, object: nil)
        
        nc.addObserver(self, selector: #selector(receiveHandoff), name: .displayLandsideSaveDataView, object: nil)
        nc.addObserver(self, selector: #selector(loadHandoffData(_:)), name: .loadLandsideSaveData, object: nil)
                
        checkFieldsForSaveCharacters()
        
    }
    
    @objc func saveData() {
        
        let saveDirectory: String = NSHomeDirectory() + "/Documents/"
        var sessionDataContents = [String]()

        for entry in downtimeEntries {
            var data = String()
            data.append("\(entry["startTime"]!)%$")
            data.append("\(entry["sortTime"]!)%$")
            data.append("\(entry["endTime"]!)%$")
            data.append("\(entry["downtimeReason"]!)%$")
            data.append("\(entry["category"]!)%$&#~")
            
            sessionDataContents.append(data)
            
        }
        
        let fileContents = sessionDataContents.joined()
        let fileName = "landside_downtime_session_data.txt"

        let destination = saveDirectory + fileName
        
        do {
            try fileContents.write(to: URL(fileURLWithPath: destination), atomically: true, encoding: .utf8)
        } catch {
            Swift.print(error)
        }
        
    }
    
    @objc func loadData() {
        var fileContents = String()
        var fileModificationDate = Date()
        let loadPath: String = NSHomeDirectory() + "/Documents/landside_downtime_session_data.txt"

        if fm.fileExists(atPath: loadPath) {
            do {
                let fileAttributes = try fm.attributesOfItem(atPath: loadPath) as [FileAttributeKey:Any]
                fileModificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            } catch {
                Swift.print(error)
            }
            
            let now = Date()
            
            let difference = now.timeIntervalSince(fileModificationDate)
            
            if difference < 43200 {
                fileContents = String(data: fm.contents(atPath: loadPath)!, encoding: .utf8) ?? ""
                var downtimeData = fileContents.components(separatedBy: "&#~")
                downtimeData.removeLast()
                
                for dataEntry in downtimeData {
                    
                    var data = dataEntry.components(separatedBy: "%$")
                    data.removeLast()
                    
                    var entry: [String: String] = [
                        "startTime":"",
                        "sortTime":"",
                        "endTime":"",
                        "downtimeReason":"",
                        "category":""
                    ]

                    entry.updateValue(data[0], forKey: "startTime")
                    entry.updateValue(data[1], forKey: "sortTime")
                    entry.updateValue(data[2], forKey: "endTime")
                    entry.updateValue(data[3], forKey: "downtimeReason")
                    entry.updateValue(data[4], forKey: "category")
                    
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
    
    @objc func loadHandoffData(_ notification: Notification) {
        var fileContents = String()
        var fileModificationDate = Date()
        var loadPath = String()
        
        if let dict = notification.userInfo as NSDictionary? {
            if let path = dict["path"] as? String {
                loadPath = path
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "No save path!"
            alert.informativeText = "The save path was empty."
            alert.runModal()
        }
        
        if fm.fileExists(atPath: loadPath) {
            do {
                let fileAttributes = try fm.attributesOfItem(atPath: loadPath) as [FileAttributeKey:Any]
                fileModificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            } catch {
                Swift.print(error)
            }
            
            let now = Date()
            
            let difference = now.timeIntervalSince(fileModificationDate)
            
            if difference < 43200 {
                fileContents = String(data: fm.contents(atPath: loadPath)!, encoding: .utf8) ?? ""
                var downtimeData = fileContents.components(separatedBy: "&#~")
                downtimeData.removeLast()
                
                for dataEntry in downtimeData {
                    
                    var data = dataEntry.components(separatedBy: "%$")
                    data.removeLast()
                    
                    var entry: [String: String] = [
                        "startTime":"",
                        "sortTime":"",
                        "endTime":"",
                        "downtimeReason":"",
                        "category":""
                    ]

                    entry.updateValue(data[0], forKey: "startTime")
                    entry.updateValue(data[1], forKey: "sortTime")
                    entry.updateValue(data[2], forKey: "endTime")
                    entry.updateValue(data[3], forKey: "downtimeReason")
                    entry.updateValue(data[4], forKey: "category")
                    
                    if !downtimeEntries.contains(entry) {
                        downtimeEntries.append(entry)
                    }

                }
                
            } else {
                do {
                    try fm.removeItem(at: URL(fileURLWithPath: loadPath))
                } catch {
                    Swift.print(error)
                }
            }
        
            
        }

        saveDataDragWellView.dismissView(saveDataDragWellView)

    }

    @objc func receiveHandoff() {
        presentAsSheet(saveDataDragWellView)
    }
        
    @objc func checkFieldsForSaveCharacters() {
        
        var badFieldCount = 0
            
        if downtimeEntries.isEmpty {
            nc.post(name: .landsideEntriesDoNotContainSaveCharacters, object: nil)
            entriesHaveSaveCharacters = false
        } else {
            for entry in downtimeEntries {
                
                if entry["downtimeReason"]!.contains("%$") || entry["downtimeReason"]!.contains("&#~") {
                    badFieldCount += 1
                }
                
                if badFieldCount > 0 {
                    nc.post(name: Notification.Name.landsideEntriesContainSaveCharacters, object: nil)
                    entriesHaveSaveCharacters = true
                } else {
                    nc.post(name: Notification.Name.landsideEntriesDoNotContainSaveCharacters, object: nil)
                    entriesHaveSaveCharacters = false
                }
            }
        }

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

    func getSortingTime(for time: String) -> String {
        
        guard time.length == 4 else { return time }
        
        let minutes = time.substring(fromIndex: 2)
        var hour = Int(time.substring(toIndex: time.length - 2))!
        
        if hootShiftRadioButton.state == .on {
            /*if hour >= 0 && hour <= 8 {
                hour += 24
            }*/
        } else if hour >= 0 && hour <= 4 {
            hour += 24
        }
        
        var strHour = String(hour)
        if strHour.length == 1 {
            strHour.insert("0", at: String.Index.init(utf16Offset: 0, in: strHour))
        }
        
        let sortTime = strHour + minutes
        
        return sortTime
    }
    
    @objc func selectLightCurtainBreak() {
        categoryComboBox.selectItem(at: 0)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectReland() {
        categoryComboBox.selectItem(at: 1)
        categorySelected(categoryComboBox)
        
        endTimeComboBox.stringValue.removeAll()
        endTimeComboBox.isEnabled = false
        
    }
    
    @objc func selectFlip() {
        categoryComboBox.selectItem(at: 2)
        categorySelected(categoryComboBox)

        startTimeComboBox.stringValue.removeAll()
        startTimeComboBox.isEnabled = false
        
        endTimeComboBox.stringValue.removeAll()
        endTimeComboBox.isEnabled = false

    }
    
    @objc func selectASCfault() {
        categoryComboBox.selectItem(at: 3)
        categorySelected(categoryComboBox)
    }
    
    @objc func selectNote() {
        categoryComboBox.selectItem(at: 4)
        categorySelected(categoryComboBox)
    }
    
    @objc func deselectCategory() {
        categoryComboBox.deselectItem(at: categoryComboBox.indexOfSelectedItem)
        categorySelected(categoryComboBox)
        
        startTimeComboBox.isEnabled = true
        endTimeComboBox.isEnabled = true
    }
    
    @IBAction func categorySelected(_ sender: NSComboBox) {
        if !categoryComboBox.stringValue.isEmpty {
            
            let array = [unichar(NSCarriageReturnCharacter)]
            addDowntimeButton.keyEquivalent = String(utf16CodeUnits: array, count: 1)
            
        }
    }
    
    @IBAction func addDowntimeEntry(_ sender: Any) {
        
        let prefixes: [String: String] = [
            "Light Curtain Break":"#light",
            "Reland":"#reland",
            "Flip":"#flip",
            "ASC Fault":"#asc",
            "Note":"#note",
        ]
        
        var entry: [String: String] = [
            "startTime":"",
            "sortTime":"",
            "endTime":"",
            "downtimeReason":"",
            "category":"",
        ]
        
        if !categoryComboBox.stringValue.isEmpty {
            entry.updateValue(categoryComboBox.stringValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "category")
        }
        
        if !startTimeComboBox.stringValue.isEmpty {
            entry.updateValue(startTimeComboBox.stringValue, forKey: "startTime")
            
            if entry.isANote() {
                let hour = startTimeComboBox.stringValue.substring(toIndex: 2)
                let time = hour + "59"
                let sortTime = getSortingTime(for: time)
                entry.updateValue(sortTime, forKey: "sortTime")
            } else {
                entry.updateValue(getSortingTime(for: startTimeComboBox.stringValue), forKey: "sortTime")
            }
        }
        
        if endTimeComboBox.stringValue.isEmpty {
            if entry.isLightCurtainBreak() {
                entry.updateValue("missing", forKey: "endTime")
            }
        } else {
            entry.updateValue(endTimeComboBox.stringValue, forKey: "endTime")
        }
        
        if !downtimeReasonTextField.stringValue.isEmpty {
            
            var reason = downtimeReasonTextField.stringValue
            
            if let category = entry["category"] {
                
                var prefix = ""
                
                if !category.isEmpty {
                    prefix = prefixes[category]!
                }
                
                switch category {
                    
                case "Light Curtain Break":
                    if reason.lowercased().hasPrefix(prefix) { //If the string contains the prefix category command
                        let range = reason.lowercased().range(of: prefix)! //Find the range of the prefix
                        reason.removeSubrange(range) //Remove the range of the prefix
                        reason = reason.trimmingCharacters(in: .whitespaces) //Remove any possible leading whitespace
                    }
                case "Reland":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                case "Flip":
                    if reason.lowercased().hasPrefix(prefix) {
                        let range = reason.lowercased().range(of: prefix)!
                        reason.removeSubrange(range)
                        reason = reason.trimmingCharacters(in: .whitespaces)
                    }
                case "ASC Fault":
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
        
        downtimeEntries.append(entry)
        clearBoxes()
        addDowntimeButton.keyEquivalent = String("")
        startTimeComboBox.isEnabled = true
        endTimeComboBox.isEnabled = true


    }
    
    @IBAction @objc func tableCellValueEdited(_ sender: NSTextField) {
        
        let selectedRow = downtimeTableView.row(for: sender)
        
        if let columnIdentifier: String = sender.superview?.identifier?.rawValue {
            if selectedRow != -1 {
                downtimeEntries[selectedRow].updateValue(sender.stringValue, forKey: columnIdentifier) //update the data source
                
                if columnIdentifier == "startTime" { //if the user is updating a start time, appropriately update the sort time (which is not displayed in the table)
                    
                    if downtimeEntries[selectedRow].isANote() { //Use a time ending in 59 for the sort time, for timed notes
                        let hour = downtimeEntries[selectedRow]["startTime"]!.substring(toIndex: 2)
                        let time = hour + "59"
                        let sortTime = getSortingTime(for: time)
                        downtimeEntries[selectedRow].updateValue(sortTime, forKey: "sortTime")
                    } else {
                        downtimeEntries[selectedRow].updateValue(getSortingTime(for: sender.stringValue), forKey: "sortTime")
                    }
                }
                
                if columnIdentifier == "startTime" || columnIdentifier == "endTime" || columnIdentifier == "downtimeReason" {
                    let cell = downtimeTableView.view(atColumn: columnNumbers[columnIdentifier]!, row: selectedRow, makeIfNecessary: false) as? NSTableCellView
                    if selectedRow % 2 == 0 {
                        cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[0]
                    } else {
                        cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[1]
                    }
                    cell?.textField?.textColor = .textColor
                } else if let comboCell = sender.superview as? CategoryComboTableCellView {
                    if selectedRow % 2 == 0 {
                        comboCell.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[0]
                    } else {
                        comboCell.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[1]
                    }
                }

            }
        }
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

    func clearBoxes() {
        startTimeComboBox.stringValue.removeAll()
        endTimeComboBox.stringValue.removeAll()
        downtimeReasonTextField.stringValue.removeAll()
        categoryComboBox.stringValue.removeAll()
    }

    @IBAction func optionsSelected(_ sender: NSButton) {
        if sender.state == .on {
            shiftOptions.updateValue(true, forKey: sender.identifier!.rawValue)
        } else if sender.state == .off {
            shiftOptions.updateValue(false, forKey: sender.identifier!.rawValue)
        }
    }

    @IBAction func shiftSelected(_ sender: Any) {
        generateTextReportButton.isEnabled = true
        
        
        for entry in downtimeEntries {
            if !entry.isANote() {
                downtimeEntries[downtimeEntries.firstIndex(of: entry)!].updateValue(getSortingTime(for: entry["startTime"]!), forKey: "sortTime")
            }
        }
                
        downtimeTableView.reloadData()
        
    }

    @objc func enableRemovalButton() {
        
        let selectedRows = downtimeTableView.selectedRowIndexes
        
        if !selectedRows.isEmpty {
            removeDowntimeButton.isEnabled = true
        } else { removeDowntimeButton.isEnabled = false }
        
    }
    
    @IBAction func removeDowntimeEntries(_ sender: Any) {
        
        let selectedRows = downtimeTableView.selectedRowIndexes
        let indicesToRemove = selectedRows.reversed()
        
        for index in indicesToRemove {
            downtimeEntries.remove(at: index)
        }
        
        downtimeTableView.reloadData()
        removeDowntimeButton.isEnabled = false
        
    }

    @IBAction func displayLSTotalsView(_ sender: NSButton) {
        
        guard tableContentIsValidForExport() else {
            let alert = NSAlert()
            alert.messageText = "Bad values!"
            alert.informativeText = "Some of the values you entered are invalid for exporting or missing. The bad values have turned red - the missing values have been highlighted in yellow. Please correct these before attempting to export again. For guidelines on what the values must be, click Help > Downtime Help, or press Shift-Command-? on your keyboard."
            
            if entriesHaveSaveCharacters {
                alert.informativeText += "\n\nYou also have the characters %$ and &#~ appearing in your downtime entries. These values cannot be used in downtime entries as Downtime uses them to save your data."
            }
            
            alert.runModal()
            return
        }
        
        lsTotalsView.getDowntimeEntries(data: downtimeEntries)
        presentAsSheet(lsTotalsView)
    }
    
    
    
    func tableContentIsValidForExport() -> Bool {
        
        var hasBadEntries = false
        
        for entry in downtimeEntries {
            
            if entry.isLightCurtainBreak() {
                if !entry.hasStartTime() || !entry.hasEndTime() {
                    if !badEntries.contains(entry) {
                        badEntries.append(entry)
                        hasBadEntries = true
                    }
                    if entry["startTime"]!.count != 4 || !entry["startTime"]!.isNumeric {
                        if !badEntries.contains(entry) {
                            badEntries.append(entry)
                            hasBadEntries = true
                        }
                    }
                    if entry["endTime"]!.count != 4 || !entry["endTime"]!.isNumeric {
                        if !badEntries.contains(entry) {
                            badEntries.append(entry)
                            hasBadEntries = true
                        }
                    }
                }
            }
            
            if entry.isReland() {
                if !entry.hasStartTime() {
                    if !badEntries.contains(entry) {
                        badEntries.append(entry)
                        hasBadEntries = true
                    }
                }
                if entry["startTime"]!.count != 4 || !entry["startTime"]!.isNumeric {
                    if !badEntries.contains(entry) {
                        badEntries.append(entry)
                        hasBadEntries = true
                    }
                }
            }
            
            if entry.isASCfault() {
                if !entry.hasStartTime() {
                    if !badEntries.contains(entry) {
                        badEntries.append(entry)
                        hasBadEntries = true
                    }
                }
                if entry["startTime"]!.count != 4 || !entry["startTime"]!.isNumeric {
                    if !badEntries.contains(entry) {
                        badEntries.append(entry)
                        hasBadEntries = true
                    }
                }
                if entry.hasEndTime() {
                    if entry["endTime"]!.count != 4 || !entry["endTime"]!.isNumeric {
                        if !badEntries.contains(entry) {
                            badEntries.append(entry)
                            hasBadEntries = true
                        }
                    }
                }
            }
                        
            if entry["downtimeReason"]!.isEmpty || entry["downtimeReason"]!.contains("%$") || entry["downtimeReason"]!.contains("&#~") {
                if !badEntries.contains(entry) {
                    badEntries.append(entry)
                }
                hasBadEntries = true

            }

            if entry["category"]!.isEmpty {
                if !badEntries.contains(entry) {
                    badEntries.append(entry)
                }
                hasBadEntries = true

            }
        }
        
        if hasBadEntries {
            indicateBadValues()
            return false
        } else if !hasBadEntries {
            badEntries.removeAll()
        }

        checkFieldsForSaveCharacters()
        return true
    }
    
    func indicateBadValues() {
        
        var valuesToHighlight = [Int: [String]]()

        for badEntry in badEntries {
            
            var keysForBadValues = [String]()

            if downtimeEntries.contains(badEntry) {
                
                if badEntry.isLightCurtainBreak() {
                    if badEntry["startTime"]!.count != 4 || !badEntry["startTime"]!.isNumeric {
                        keysForBadValues.append("startTime")
                    }
                
                    if badEntry["endTime"]!.count != 4 || !badEntry["endTime"]!.isNumeric {
                        keysForBadValues.append("endTime")
                    }

                }
                
                if badEntry.isReland() {
                    if badEntry["startTime"]!.count != 4 || !badEntry["startTime"]!.isNumeric {
                        keysForBadValues.append("startTime")
                    }
                }
                
                if badEntry.isASCfault() {
                    if badEntry["startTime"]!.count != 4 || !badEntry["startTime"]!.isNumeric {
                        keysForBadValues.append("startTime")
                    }
                }
                
                if badEntry["downtimeReason"]!.isEmpty {
                    if !keysForBadValues.contains("downtimeReason") {
                        keysForBadValues.append("downtimeReason")
                    }
                }
                
                if badEntry["downtimeReason"]!.contains("%$") {
                    if !keysForBadValues.contains("downtimeReason") {
                        keysForBadValues.append("downtimeReason")
                    }
                }
                
                if badEntry["downtimeReason"]!.contains("&#~") {
                    if !keysForBadValues.contains("downtimeReason") {
                        keysForBadValues.append("downtimeReason")
                    }
                }

                if badEntry["category"]!.isEmpty {
                    keysForBadValues.append("category")
                }

            }
            
            valuesToHighlight.updateValue(keysForBadValues, forKey: downtimeEntries.firstIndex(of: badEntry)!)
            
        }
        
        for entry in downtimeEntries {
            
            for (columnIdentifier, columnIndex) in columnNumbers {
                
                switch columnIdentifier {
                    
                case "startTime":
                    if entry[columnIdentifier]!.count == 4 && entry[columnIdentifier]!.isNumeric {
                        let cell = downtimeTableView.view(atColumn: columnIndex, row: downtimeEntries.firstIndex(of: entry)!, makeIfNecessary: false) as? NSTableCellView
                        cell?.textField?.textColor = .textColor
                        if let row = downtimeEntries.firstIndex(of: entry) {
                            if row % 2 == 0 {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[0]
                            } else {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[1]
                            }
                        }
                    }
                case "endTime":
                    if entry[columnIdentifier]!.count == 4 && entry[columnIdentifier]!.isNumeric {
                        let cell = downtimeTableView.view(atColumn: columnIndex, row: downtimeEntries.firstIndex(of: entry)!, makeIfNecessary: false) as? NSTableCellView
                        cell?.textField?.textColor = .textColor
                        if let row = downtimeEntries.firstIndex(of: entry) {
                            if row % 2 == 0 {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[0]
                            } else {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[1]
                            }
                        }
                    }
                case "downtimeReason":
                    if !entry[columnIdentifier]!.isEmpty && !entry[columnIdentifier]!.contains("%$") && !entry[columnIdentifier]!.contains("&#~") {
                        let cell = downtimeTableView.view(atColumn: columnIndex, row: downtimeEntries.firstIndex(of: entry)!, makeIfNecessary: false) as? NSTableCellView
                        cell?.textField?.textColor = .textColor
                        if let row = downtimeEntries.firstIndex(of: entry) {
                            if row % 2 == 0 {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[0]
                            } else {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[1]
                            }
                        }
                    }
                case "category":
                    if !entry[columnIdentifier]!.isEmpty {
                        let cell = downtimeTableView.view(atColumn: columnIndex, row: downtimeEntries.firstIndex(of: entry)!, makeIfNecessary: false) as? CategoryComboTableCellView
                        if let row = downtimeEntries.firstIndex(of: entry) {
                            if row % 2 == 0 {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[0]
                            } else {
                                cell?.textField?.backgroundColor = NSColor.alternatingContentBackgroundColors[1]
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
        
        for (row, columnIDs) in valuesToHighlight {
            
            for id in columnIDs {
                
                if id == "category" {
                    let cell = downtimeTableView.view(atColumn: columnNumbers[id]!, row: row, makeIfNecessary: false) as? CategoryComboTableCellView
                    cell?.categoryComboBox.backgroundColor = NSColor.systemYellow
                } else {
                    let cell = downtimeTableView.view(atColumn: columnNumbers[id]!, row: row, makeIfNecessary: false) as? NSTableCellView
                    
                    if let value = cell?.textField?.stringValue {
                        if value.isEmpty {
                            cell?.textField?.backgroundColor = NSColor.systemYellow
                        } else {
                            cell?.textField?.textColor = NSColor.systemRed
                        }
                    }
                }
            }
        }
        
        valuesToHighlight.removeAll()
        badEntries.removeAll()
    }
    
    @objc func checkDataAfterEntriesChanged() {
        let valuesAreGood = tableContentIsValidForExport()
        
        if !valuesAreGood {
            indicateBadValues()
        }
    }

    @objc func indicateFromAppDelegate() {
        let valuesAreGood = tableContentIsValidForExport()
        
        if !valuesAreGood {
            indicateBadValues()
        }
        
    }
    
}

extension LandsideDowntimeViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return downtimeEntries.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let item = downtimeEntries[row]
        
        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
        
        if cell!.identifier!.rawValue == "category" {
            let comboCell = cell as? CategoryComboTableCellView
            comboCell?.categoryComboBox.stringValue = item[(tableColumn!.identifier.rawValue)]!
            comboCell?.wantsLayer = true
            comboCell?.categoryComboBox.drawsBackground = true
            return comboCell
        }

        cell?.textField?.stringValue = item[(tableColumn?.identifier.rawValue)!]!
        cell?.wantsLayer = true
        cell?.textField?.drawsBackground = true
        return cell

    }
}
