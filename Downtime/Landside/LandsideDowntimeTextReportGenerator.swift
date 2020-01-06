//
//  LandsideDowntimeTextReportGenerator.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/5/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class LandsideDowntimeTextReportGenerator: NSObject {

    var headerSentence = String()
    
    var downtimeEntries = [[String: String]]()
    
    var report = NSMutableAttributedString()

    var lightCurtainBreaks = [[String: String]]()
    var relands = [[String: String]]()
    var flips = [[String: String]]()
    var ascFaults = [[String: String]]()
    var timedNotes = [[String: String]]()
    var blankNotes = [[String: String]]()
    
    let locale = NSLocale.autoupdatingCurrent
    
    let exportDirectory: String = NSHomeDirectory() + "/Documents/_landside-reports/"

    var landsideMoveTotals = [String: String]()
    var inventoryTotals = [String: String]()
    
    let font = NSFont(name: "Calibri", size: 14.5)!
    let boldFont = NSFont(name: "Calibri-Bold", size: 14.5)!

    
    func getHeaderSentence(sentence: String) {
        headerSentence = sentence
    }
    
    func getDowntimeEntries(entries: [[String: String]]) {
        lightCurtainBreaks.removeAll()
        relands.removeAll()
        flips.removeAll()
        ascFaults.removeAll()
        timedNotes.removeAll()
        blankNotes.removeAll()
        downtimeEntries.removeAll()
        downtimeEntries = entries
    }
    
    func getLandsideTotals(totals: [String: String]) {
        landsideMoveTotals = totals
    }
    
    func getInventoryTotals(totals: [String: String]) {
        inventoryTotals = totals
    }
    
    func sortEntriesByCategory() {
        for entry in downtimeEntries {
            
            switch entry["category"]! {
            case "Light Curtain Break":
                lightCurtainBreaks.append(entry)
            case "Reland":
                relands.append(entry)
            case "Flip":
                flips.append(entry)
            case "ASC Fault":
                ascFaults.append(entry)
            case "Note":
                if !entry.hasStartTime() && !entry.hasEndTime() {
                    blankNotes.append(entry)
                } else {
                    timedNotes.append(entry)
                }
            default:
                break //Should not be reached.
                
            }
            
        }
    }
    
    func sortEntriesByTime() {
        lightCurtainBreaks = lightCurtainBreaks.sorted(by: {
            if $0["sortTime"]! != $1["sortTime"]! {  //If sort times (start times) are not the same, sort by start time
                return $0["sortTime"]! < $1["sortTime"]!
            } else { //If sort times are the same, sort by end time
                return $0["endTime"]! < $1["endTime"]!
            }
        })
        
        relands = relands.sorted(by: {
            return $0["sortTime"]! < $1["sortTime"]!
        })
        
        ascFaults = ascFaults.sorted(by: {
            if $0["sortTime"]! != $1["sortTime"]! {  //If sort times (start times) are not the same, sort by start time
                return $0["sortTime"]! < $1["sortTime"]!
            } else { //If sort times are the same, sort by end time
                return $0["endTime"]! < $1["endTime"]!
            }
        })
        
        timedNotes = timedNotes.sorted(by: {
            if $0["sortTime"]! != $1["sortTime"]! {  //If start times are not the same, sort by start time
                return $0["sortTime"]! < $1["sortTime"]!
            } else { //If sort times are the same, sort by end time
                return $0["endTime"]! < $1["endTime"]!
            }
        })
    }
    
    func generateReport() {
        sortEntriesByCategory()
        sortEntriesByTime()
                
        let emptyLine = "\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        let bulletPoint: NSMutableAttributedString = "\u{2022}".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        
        let firstLine = "Landside Operations:".withBoldText(boldPartsOfString: ["Landside Operations:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        firstLine.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, firstLine.length))
        firstLine.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, firstLine.length))
        report.append(firstLine)
        report.append(emptyLine)
        report.append(emptyLine)
        
        let sentenceLine = headerSentence.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        
        report.append(sentenceLine)
        
        report.append(emptyLine)
        report.append(emptyLine)

        let noteHeader = "Notes:".withBoldText(boldPartsOfString: ["Notes:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        noteHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, noteHeader.length))
        noteHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, noteHeader.length))
        report.append(noteHeader)
        report.append(emptyLine)
        report.append(emptyLine)

        for note in blankNotes {
            let noteLine = NSMutableAttributedString()
            noteLine.append(bulletPoint)
            noteLine.append(NSAttributedString(string: "  "))
            let noteText = note["downtimeReason"]!.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            noteLine.append(noteText)
            noteLine.append(emptyLine)
            noteLine.insert(NSAttributedString(string: "     "), at: 0)
            report.append(noteLine)
        }

        report.append(emptyLine)

        for entry in timedNotes {
            let noteLine = NSMutableAttributedString()
            noteLine.append(bulletPoint)
            noteLine.append(NSAttributedString(string: "  "))
            var noteText = NSMutableAttributedString()
            if !entry.hasEndTime() {
                noteText = "\(entry["startTime"]!) - \(entry["endTime"]!)\t\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            } else {
                noteText = "\(entry["startTime"]!) - \(entry["endTime"]!)\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            }
            noteLine.append(noteText)
            noteLine.append(emptyLine)
            noteLine.insert(NSAttributedString(string: "     "), at: 0)
            report.append(noteLine)
        }
        
        report.append(emptyLine)
        report.append(emptyLine)
        report.append(emptyLine)
        
        let lightCurtainHeader = "Light Curtain Breaks:".withBoldText(boldPartsOfString: ["Light Curtain Breaks:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        lightCurtainHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, lightCurtainHeader.length))
        lightCurtainHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, lightCurtainHeader.length))
        report.append(lightCurtainHeader)
        report.append(emptyLine)
        report.append(emptyLine)

        for entry in lightCurtainBreaks {
            let lightCurtainBreakLine = NSMutableAttributedString()
            lightCurtainBreakLine.append(bulletPoint)
            lightCurtainBreakLine.append(NSAttributedString(string: "  "))
            let lightCurtainBreakText = "\(entry["startTime"]!) - \(entry["endTime"]!)\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            lightCurtainBreakLine.append(lightCurtainBreakText)
            lightCurtainBreakLine.append(emptyLine)
            lightCurtainBreakLine.insert(NSAttributedString(string: "     "), at: 0)
            report.append(lightCurtainBreakLine)
        }
                
        report.append(emptyLine)
        report.append(emptyLine)
        report.append(emptyLine)

        let relandHeader = "Relands:".withBoldText(boldPartsOfString: ["Relands:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        relandHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, relandHeader.length))
        relandHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, relandHeader.length))
        report.append(relandHeader)
        report.append(emptyLine)
        report.append(emptyLine)
        
        for entry in relands {
            let relandLine = NSMutableAttributedString()
            relandLine.append(bulletPoint)
            relandLine.append(NSAttributedString(string: "  "))
            let relandText = "\(entry["startTime"]!)\t-\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            relandLine.append(relandText)
            relandLine.append(emptyLine)
            relandLine.insert(NSAttributedString(string: "     "), at: 0)
            report.append(relandLine)
        }
        
        report.append(emptyLine)
        report.append(emptyLine)
        report.append(emptyLine)

        let flipsHeader = "Flips:".withBoldText(boldPartsOfString: ["Flips:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        flipsHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, flipsHeader.length))
        flipsHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, flipsHeader.length))
        report.append(flipsHeader)
        report.append(emptyLine)
        report.append(emptyLine)

        for entry in flips {
            let flipLine = NSMutableAttributedString()
            flipLine.append(bulletPoint)
            flipLine.append(NSAttributedString(string: "  "))
            let flipText = entry["downtimeReason"]!.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            flipLine.append(flipText)
            flipLine.append(emptyLine)
            flipLine.insert(NSAttributedString(string: "     "), at: 0)
            report.append(flipLine)
        }
        
        report.append(emptyLine)
        report.append(emptyLine)
        report.append(emptyLine)

        let ascFaultsHeader = "ASC Faults:".withBoldText(boldPartsOfString: ["ASC Faults:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        ascFaultsHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, ascFaultsHeader.length))
        ascFaultsHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, ascFaultsHeader.length))
        report.append(ascFaultsHeader)
        report.append(emptyLine)
        report.append(emptyLine)
        
        for entry in ascFaults {
            let ascLine = NSMutableAttributedString()
            ascLine.append(bulletPoint)
            ascLine.append(NSAttributedString(string: "  "))
            var ascText = NSMutableAttributedString()
            if !entry.hasEndTime() {
                ascText =  "\(entry["startTime"]!) - \(entry["endTime"]!)\t\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            } else {
                ascText =  "\(entry["startTime"]!) - \(entry["endTime"]!)\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString

            }
            ascLine.append(ascText)
            ascLine.append(emptyLine)
            ascLine.insert(NSAttributedString(string: "     "), at: 0)
            report.append(ascLine)
        }
        
        report.append(emptyLine)
        report.append(emptyLine)
        report.append(emptyLine)

        let deliveredLine = ("We Delivered Containers: " + landsideMoveTotals["delivered"]!)
        let receivedLine = ("We Received Containers: " + landsideMoveTotals["received"]!)
        let totalMoveLine = ("Total Container Moves: " + landsideMoveTotals["total"]!)
        
        let deliveredReportLine = deliveredLine.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        let receivedReportLine = receivedLine.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        let totalMoveReportLine = totalMoveLine.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        
        report.append(deliveredReportLine)
        report.append(emptyLine)
        report.append(receivedReportLine)
        report.append(emptyLine)
        report.append(totalMoveReportLine)
        report.append(emptyLine)
        report.append(emptyLine)

        let autoInvHeader = "Automation Inventory:".withBoldText(boldPartsOfString: ["Automation Inventory:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        autoInvHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, autoInvHeader.length))
        autoInvHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, autoInvHeader.length))
        report.append(autoInvHeader)
        report.append(emptyLine)
        report.append(emptyLine)
        
        let outboundLine = ("O/B: " + inventoryTotals["outbound"]!).withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        let inboundLine = ("I/B: " + inventoryTotals["inbound"]!).withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        let emptiesLine = ("MTY: " + inventoryTotals["empties"]!).withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        
        report.append(outboundLine)
        report.append(emptyLine)
        report.append(inboundLine)
        report.append(emptyLine)
        report.append(emptiesLine)
        report.append(emptyLine)
        
        openFile()
        
    }
    
    func openFile() {
        
        let ws = NSWorkspace.shared
        
        let date = Date()
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        var dateString = df.string(from: date)
        dateString = dateString.replacingOccurrences(of: "/", with: "-")
        dateString = dateString.replacingOccurrences(of: ":", with: "")
        let fileName = "Downtime Report " + dateString + ".rtf"
        let destination = exportDirectory + fileName
        var contents = Data()

        let docAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
            NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf,
            NSAttributedString.DocumentAttributeKey.characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
        ]
        
        do {
            contents = try report.data(from: NSMakeRange(0, report.length), documentAttributes: docAttributes)
        } catch {
            Swift.print(error)
        }

        do {
            try contents.write(to: URL(fileURLWithPath: destination))
        } catch {
            let alert = NSAlert(error: error)
            alert.informativeText = "Could not write file to destination: \(destination)"
            alert.runModal()
        }
        
        ws.openFile(destination)

        headerSentence.removeAll()
        downtimeEntries.removeAll()
        report = NSMutableAttributedString()
        
        lightCurtainBreaks.removeAll()
        relands.removeAll()
        flips.removeAll()
        ascFaults.removeAll()
        timedNotes.removeAll()
        blankNotes.removeAll()
        
        landsideMoveTotals.removeAll()
        inventoryTotals.removeAll()
        
    }
    
}
