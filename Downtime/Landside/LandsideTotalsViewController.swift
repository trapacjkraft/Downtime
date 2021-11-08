//
//  LandsideTotalsViewController.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/4/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class LandsideTotalsViewController: NSViewController {

    @IBOutlet var flexDeliveryTextField: NSTextField!
    @IBOutlet var mealHourDeliveryTextField: NSTextField!
    @IBOutlet var flipsTextField: NSTextField!
    @IBOutlet var turnTimeTextField: NSTextField!
    
    @IBOutlet var totalDeliveryTextField: NSTextField!
    @IBOutlet var totalReceivedTextField: NSTextField!
    @IBOutlet var totalLandsideTextField: NSTextField!
    
    @IBOutlet var outboundInventoryTextField: NSTextField!
    @IBOutlet var inboundInventoryTextField: NSTextField!
    @IBOutlet var emptyInventoryTextField: NSTextField!
    
    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var textReportButton: NSButton!
    
    // Sentence parts for creating the header string
    
    @IBOutlet var headerFirstPart: NSTextField!
    @IBOutlet var headerSecondPart: NSTextField!
    @IBOutlet var headerThirdPart: NSTextField!
    @IBOutlet var headerFourthPart: NSTextField!
    @IBOutlet var headerFifthPart: NSTextField!
    @IBOutlet var headerSixthPart: NSTextField!
    @IBOutlet var headerSeventhPart: NSTextField!
    
    
    var downtimeEntries = [[String: String]]()
    
    var landsideTotals = [
        "delivered":"",
        "received":"",
        "total":""
    ]
    
    var inventoryTotals = [
        "outbound":"",
        "inbound":"",
        "empties":""
    ]
    
    let reportGenerator = LandsideDowntimeTextReportGenerator()

    var textFields = [NSTextField]()
    let totalFieldsFormatter = NumberFieldFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        flipsTextField.stringValue = countFlipsInDowntime()
        
        // create an array of the totals text fields to ensure all values are captured
        textFields.removeAll()
        textFields.append(totalDeliveryTextField)
        textFields.append(totalReceivedTextField)
        textFields.append(totalLandsideTextField)
        textFields.append(outboundInventoryTextField)
        textFields.append(inboundInventoryTextField)
        textFields.append(emptyInventoryTextField)
        
        for field in textFields {
            field.formatter = totalFieldsFormatter
        }
        
    }
    
    func getDowntimeEntries(data: [[String: String]]) {
        downtimeEntries.removeAll()
        downtimeEntries = data
    }
    
    func createHeaderSentence() -> String {
        var headerString = String()
        headerString.append(headerFirstPart.stringValue + " ")
        headerString.append(flexDeliveryTextField.stringValue + " ")
        headerString.append(headerSecondPart.stringValue + " ")
        headerString.append(headerThirdPart.stringValue + " ")
        headerString.append(mealHourDeliveryTextField.stringValue + " ")
        headerString.append(headerFourthPart.stringValue + " ")
        headerString.append(flipsTextField.stringValue + " ")
        headerString.append(headerFifthPart.stringValue + " ")
        headerString.append(headerSixthPart.stringValue + " ")
        headerString.append(turnTimeTextField.stringValue + " ")
        headerString.append(headerSeventhPart.stringValue)
        
        return headerString
    }
    
    func countFlipsInDowntime() -> String {
        
        var flipCount = 0
        
        for entry in downtimeEntries {
            if entry["category"]! == "Flip" {
                flipCount += 1
            }
        }
        
        return String(flipCount)
    }
    
    @IBAction func updateLandsideTotals(_ sender: NSTextField) {
        for (id, _) in landsideTotals {
            if sender.identifier!.rawValue == id {
                landsideTotals.updateValue(sender.stringValue, forKey: id)
            }
        }
    }
    
    @IBAction func calculateTotalLandsideMoves(_ sender: NSTextField) {
        var delivered = 0
        var received = 0
        var total = 0
        
        if totalDeliveryTextField.stringValue.isEmpty {
            delivered = 0
        } else {
            if let num = Int(totalDeliveryTextField.stringValue) {
                delivered = num
            } else {
                delivered = 0
            }
            
        }
        
        if totalReceivedTextField.stringValue.isEmpty {
            received = 0
        } else {
            if let num = Int(totalReceivedTextField.stringValue) {
                received = num
            } else {
                received = 0
            }
        }
        
        total = delivered + received
        totalLandsideTextField.stringValue = String(total)
        updateLandsideTotals(sender)
        
    }
    
    @IBAction func updateInventoryTotals(_ sender: NSTextField) {
        for (id, _) in inventoryTotals {
            if sender.identifier!.rawValue == id {
                inventoryTotals.updateValue(sender.stringValue, forKey: id)
            }
        }
    }
    
    @IBAction func generateTextReport(_ sender: NSButton) {
        
        
        let headerSentence = createHeaderSentence()
        reportGenerator.getHeaderSentence(sentence: headerSentence)
        
        for field in textFields {
            updateLandsideTotals(field)
            updateInventoryTotals(field)
        }
     
        reportGenerator.getDowntimeEntries(entries: downtimeEntries)
        reportGenerator.getLandsideTotals(totals: landsideTotals)
        reportGenerator.getInventoryTotals(totals: inventoryTotals)
        reportGenerator.generateReport()
        
    }
    
    @IBAction func closeView(_ sender: Any) {
        dismiss(self)
    }
        
}
