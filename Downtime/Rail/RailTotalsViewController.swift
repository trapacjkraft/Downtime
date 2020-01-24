//
//  RailTotalsViewController.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/17/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class RailTotalsViewController: NSViewController {

    @IBOutlet var firstHalfCraneOperator: NSTextField!
    @IBOutlet var secondHalfCraneOperator: NSTextField!
    
    @IBOutlet var firstHalfStrads: NSTextField!
    @IBOutlet var secondHalfStrads: NSTextField!
    
    @IBOutlet var workingConveyors: NSTextField!
    
    @IBOutlet var firstHalfDischargeTotal: NSTextField!
    @IBOutlet var firstHalfLoadoutTotal: NSTextField!
    @IBOutlet var firstHalfRehandleTotal: NSTextField!
    @IBOutlet var firstHalfTotalMoves: NSTextField!
    
    @IBOutlet var shiftTotalDischarge: NSTextField!
    @IBOutlet var shiftTotalLoadout: NSTextField!
    @IBOutlet var shiftTotalRehandles: NSTextField!
    @IBOutlet var shiftTotalMoves: NSTextField!
    
    @IBOutlet var textReportGeneratorButton: NSButton!
    
    var downtimeEntries = [[String: String]]()
    var selectedShift = [String: Bool]()
    var shiftOptions = [String: Bool]()
    
    var details = [
        "firstHalfOperator":"",
        "secondHalfOperator":"",
        "firstHalfStrads":"",
        "secondHalfStrads":"",
        "conveyors":""
    ]
    
    var firstHalfTotals = [
        "firstHalfDischarge":"",
        "firstHalfLoadout":"",
        "firstHalfRehandle":"",
        "firstHalfTotal":""
    ]
    
    var shiftTotals = [
        "shiftDischarge":"",
        "shiftLoadout":"",
        "shiftRehandle":"",
        "shiftTotals":""
    ]
    
    let reportGenerator = RailDowntimeTextReportGenerator()
    
    var detailsTextFields = [NSTextField]()
    var totalsTextFields = [NSTextField]()
    let numberFieldsFormatter = NumberFieldFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsTextFields.removeAll()
        totalsTextFields.removeAll()
        
        detailsTextFields.append(firstHalfCraneOperator)
        detailsTextFields.append(secondHalfCraneOperator)
        detailsTextFields.append(firstHalfStrads)
        detailsTextFields.append(secondHalfStrads)
        detailsTextFields.append(workingConveyors)
        
        totalsTextFields.append(firstHalfDischargeTotal)
        totalsTextFields.append(firstHalfLoadoutTotal)
        totalsTextFields.append(firstHalfRehandleTotal)
        totalsTextFields.append(firstHalfTotalMoves)
        totalsTextFields.append(shiftTotalDischarge)
        totalsTextFields.append(shiftTotalLoadout)
        totalsTextFields.append(shiftTotalRehandles)
        totalsTextFields.append(shiftTotalMoves)
        
    }
    
    func getDowntimeEntries(data: [[String: String]]) {
        downtimeEntries.removeAll()
        downtimeEntries = data
    }
    
    func getShiftAndOptions(shift: [String: Bool], options: [String: Bool]) {
        selectedShift.removeAll()
        shiftOptions.removeAll()
        
        selectedShift = shift
        shiftOptions = options
    }
    
    @IBAction func updateDetails(_ sender: NSTextField) {
        for (id, _) in details {
            if sender.identifier!.rawValue == id {
                details.updateValue(sender.stringValue, forKey: id)
            }
        }
    }
    
    func updateFirstHalfTotals(_ sender: NSTextField) {
        for (id, _) in firstHalfTotals {
            if sender.identifier!.rawValue == id {
                firstHalfTotals.updateValue(sender.stringValue, forKey: id)
            }
        }
    }
    
    func updateShiftTotals(_ sender: NSTextField) {
        for (id, _) in shiftTotals {
            if sender.identifier!.rawValue == id {
                shiftTotals.updateValue(sender.stringValue, forKey: id)
            }
        }
    }
    
    @IBAction func calculateTotalFirstHalfMoves(_ sender: NSTextField) {
        var discharge = 0
        var loadout = 0
        var rehandles = 0
        var total = 0
        
        if firstHalfDischargeTotal.stringValue.isEmpty {
            discharge = 0
        } else {
            if let num = Int(firstHalfDischargeTotal.stringValue) {
                discharge = num
            } else {
                discharge = 0
            }
        }
        
        if firstHalfLoadoutTotal.stringValue.isEmpty {
            loadout = 0
        } else {
            if let num = Int(firstHalfLoadoutTotal.stringValue) {
                loadout = num
            } else {
                loadout = 0
            }
        }
        
        if firstHalfRehandleTotal.stringValue.isEmpty {
            rehandles = 0
        } else {
            if let num = Int(firstHalfRehandleTotal.stringValue) {
                rehandles = num
            } else {
                rehandles = 0
            }
        }
        
        total = discharge + loadout + rehandles
        firstHalfTotalMoves.stringValue = String(total)
        updateFirstHalfTotals(sender)
    }
    
    @IBAction func calculateTotalShiftMoves(_ sender: NSTextField) {
        var discharge = 0
        var loadout = 0
        var rehandles = 0
        var total = 0
        
        if shiftTotalDischarge.stringValue.isEmpty {
            discharge = 0
        } else {
            if let num = Int(shiftTotalDischarge.stringValue) {
                discharge = num
            } else {
                discharge = 0
            }
        }
        
        if shiftTotalLoadout.stringValue.isEmpty {
            loadout = 0
        } else {
            if let num = Int(shiftTotalLoadout.stringValue) {
                loadout = num
            } else {
                loadout = 0
            }
        }
        
        if shiftTotalRehandles.stringValue.isEmpty {
            rehandles = 0
        } else {
            if let num = Int(shiftTotalRehandles.stringValue) {
                rehandles = num
            } else {
                rehandles = 0
            }
        }
        
        total = discharge + loadout + rehandles
        shiftTotalMoves.stringValue = String(total)
        updateShiftTotals(sender)

    }
    
    @IBAction func generateTextReport(_ sender: NSButton) {
        
        for field in totalsTextFields {
            updateFirstHalfTotals(field)
            updateShiftTotals(field)
        }
        
        for field in detailsTextFields {
            updateDetails(field)
        }
        
        reportGenerator.getDetails(details: details)
        reportGenerator.getTotals(firstHalf: firstHalfTotals, shift: shiftTotals)
        reportGenerator.getDowntimeEntries(data: downtimeEntries, selectedShift: selectedShift, flex: shiftOptions["flex"]!, extended: shiftOptions["extended"]!)
        
    }
    
    @IBAction func closeView(_ sender: Any) {
        dismiss(self)
    }
}
