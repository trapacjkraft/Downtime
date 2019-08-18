//
//  VesselDowntimeTextReportGenerator.swift
//  Downtime
//
//  Created by Joshua Kraft on 7/8/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class VesselDowntimeTextReportGenerator: NSObject {
    
    var allDowntimeEntries = [[String: String]]()
    var blankNotes = [[String: String]]()
    
    var sortedDowntimeEntries: [String: [[String: String]]] = [
        "0000":[[:]],
        "0100":[[:]],
        "0200":[[:]],
        "0300":[[:]],
        "0400":[[:]],
        "0500":[[:]],
        "0600":[[:]],
        "0700":[[:]],
        "0800":[[:]],
        "0900":[[:]],
        "1000":[[:]],
        "1100":[[:]],
        "1200":[[:]],
        "1300":[[:]],
        "1400":[[:]],
        "1500":[[:]],
        "1600":[[:]],
        "1700":[[:]],
        "1800":[[:]],
        "1900":[[:]],
        "2000":[[:]],
        "2100":[[:]],
        "2200":[[:]],
        "2300":[[:]]
    ]
    
    var timedNotes: [String: [[String: String]]] = [
        "0000":[[:]],
        "0100":[[:]],
        "0200":[[:]],
        "0300":[[:]],
        "0400":[[:]],
        "0500":[[:]],
        "0600":[[:]],
        "0700":[[:]],
        "0800":[[:]],
        "0900":[[:]],
        "1000":[[:]],
        "1100":[[:]],
        "1200":[[:]],
        "1300":[[:]],
        "1400":[[:]],
        "1500":[[:]],
        "1600":[[:]],
        "1700":[[:]],
        "1800":[[:]],
        "1900":[[:]],
        "2000":[[:]],
        "2100":[[:]],
        "2200":[[:]],
        "2300":[[:]]
    ]

    let sortedDowntimeKeyForValue = ["00":"0000", "01":"0100", "02":"0200", "03":"0300", "04":"0400", "05":"0500", "06":"0600", "07":"0700", "08":"0800", "09":"0900", "10":"1000", "11":"1100", "12":"1200", "13":"1300", "14":"1400", "15":"1500", "16":"1600", "17":"1700", "18":"1800", "19":"1900", "20":"2000", "21":"2100", "22":"2200", "23":"2300", "24":"2400"]
    
    let daysideHours = ["0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600"]
    let nightsideHours = ["1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200"]
    let hootHours = ["0300", "0400", "0500", "0600", "0700"]
    
    var isDaysideReport = false
    var isNightsideReport = false
    var isHootReport = false
    
    var report = NSMutableAttributedString()
    
    var totalMech = NSDecimalNumber.zero
    var totalOp = NSDecimalNumber.zero
    var totalEStop = NSDecimalNumber.zero
    var totalSys = NSDecimalNumber.zero
    var totalDead = NSDecimalNumber.zero
    
    let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
    
    let locale = NSLocale.autoupdatingCurrent
    
    let exportDirectory: String = NSHomeDirectory() + "/Documents/"

    let font = NSFont(name: "Calibri", size: 14.5)!
    let boldFont = NSFont(name: "Calibri-Bold", size: 14.5)!
    
    func getDowntimeEntries(data: [[String: String]], shift: String) {
        allDowntimeEntries = data
        
        if shift == "day" {
            isDaysideReport = true
        } else if shift == "night" {
            isNightsideReport = true
        } else if shift == "hoot" {
            isHootReport = true
        }
        
        sortDowntimeEntries()

    }
    
    func sortDowntimeEntries() {
        for entry in allDowntimeEntries {
            if entry.isANote() {
                if entry.hasStartTime() {
                    let startingHour = entry["startTime"]!.substring(toIndex: (entry["startTime"]!.length - 2))
                    timedNotes[sortedDowntimeKeyForValue[startingHour]!]?.append(entry)
                } else if !entry.hasStartTime() && !entry.hasEndTime() {
                    blankNotes.append(entry)
                }
            } else {
                let startingHour = entry["startTime"]!.substring(toIndex: (entry["startTime"]!.length - 2))
                sortedDowntimeEntries[sortedDowntimeKeyForValue[startingHour]!]?.append(entry)
            }
        }
        
        generateReport()
    }

    func generateReport() {
        
        let emptyLine = "\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
        
        if isDaysideReport {
            for hour in daysideHours {
                
                switch hour {
                case "0800":
                    let line = "0800 - 0900:\n\n".withBoldText(boldPartsOfString: ["0800 - 0900:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0900":
                    let line = "0900 - 1000:\n\n".withBoldText(boldPartsOfString: ["0900 - 1000:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1000":
                    let line = "1000 - 1100:\n\n".withBoldText(boldPartsOfString: ["1000 - 1100:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1100":
                    let line = "1100 - 1200:\n\n".withBoldText(boldPartsOfString: ["1100 - 1200:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1200":
                    let line = "1200 - 1300:\n\n".withBoldText(boldPartsOfString: ["1200 - 1300:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1300":
                    let line = "1300 - 1400:\n\n".withBoldText(boldPartsOfString: ["1300 - 1400:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1400":
                    let line = "1400 - 1500:\n\n".withBoldText(boldPartsOfString: ["1400 - 1500:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1500":
                    let line = "1500 - 1600:\n\n".withBoldText(boldPartsOfString: ["1500 - 1600:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1600":
                    let line = "1600 - 1700:\n\n".withBoldText(boldPartsOfString: ["1600 - 1700:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)

                default:
                    break //Should not be reached
                }
                
                for entry in sortedDowntimeEntries[hour]! {
                    if entry.count > 1 {
                        let reportLine = NSMutableAttributedString()
                        
                        let firstPart = "\(entry["startTime"]!) - \(entry["endTime"]!)\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont)
                        let secondPart = "(\(entry["totalTime"]!), \(entry["category"]!))\n"
                        let boldedPart = secondPart.withBoldText(boldPartsOfString: [secondPart as NSString], font: font, boldFont: boldFont)
                        
                        reportLine.append(firstPart)
                        reportLine.append(boldedPart)
                        
                        switch entry["category"]! {
                            
                        case "Mechanical":
                            totalMech = totalMech.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "Operational Scenario":
                            totalOp = totalOp.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "E-Stop":
                            totalEStop = totalEStop.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "System / Tech":
                            totalSys = totalSys.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "Deadtime":
                            totalDead = totalDead.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        default:
                            break   //should not be reached
                        }

                        report.append(reportLine)
                        
                    }
                }
                
                report.append(emptyLine)
                
                
                for entry in timedNotes[hour]! {
                    if entry.count > 1 {
                        let noteLine = entry["downtimeReason"]!.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
                        noteLine.append(emptyLine)
                        report.append(noteLine)
                    }
                }
                
                report.append(emptyLine)

            }
        } else if isNightsideReport {
            for hour in nightsideHours {
                switch hour {
                case "1800":
                    let line = "1800 - 1900:\n\n".withBoldText(boldPartsOfString: ["1800 - 1900:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "1900":
                    let line = "1900 - 2000:\n\n".withBoldText(boldPartsOfString: ["1900 - 2000:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "2000":
                    let line = "2000 - 2100:\n\n".withBoldText(boldPartsOfString: ["2000 - 2100:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "2100":
                    let line = "2100 - 2200:\n\n".withBoldText(boldPartsOfString: ["2100 - 2200:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "2200":
                    let line = "2200 - 2300:\n\n".withBoldText(boldPartsOfString: ["2200 - 2300:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "2300":
                    let line = "2300 - 2400:\n\n".withBoldText(boldPartsOfString: ["2300 - 2400:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0000":
                    let line = "0000 - 0100:\n\n".withBoldText(boldPartsOfString: ["0000 - 0100:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0100":
                    let line = "0100 - 0200:\n\n".withBoldText(boldPartsOfString: ["0100 - 0200:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0200":
                    let line = "0200 - 0300:\n\n".withBoldText(boldPartsOfString: ["0200 - 0300:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                    
                default:
                    break //Should not be reached
                }
                
                for entry in sortedDowntimeEntries[hour]! {
                    if entry.count > 1 {
                        let reportLine = NSMutableAttributedString()
                        
                        let firstPart = "\(entry["startTime"]!) - \(entry["endTime"]!)\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont)
                        let secondPart = "(\(entry["totalTime"]!), \(entry["category"]!))\n"
                        let boldedPart = secondPart.withBoldText(boldPartsOfString: [secondPart as NSString], font: font, boldFont: boldFont)
                        
                        reportLine.append(firstPart)
                        reportLine.append(boldedPart)
                        
                        switch entry["category"]! {
                            
                        case "Mechanical":
                            totalMech = totalMech.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "Operational Scenario":
                            totalOp = totalOp.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "E-Stop":
                            totalEStop = totalEStop.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "System / Tech":
                            totalSys = totalSys.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "Deadtime":
                            totalDead = totalDead.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        default:
                            break   //should not be reached
                        }
                        
                        report.append(reportLine)
                        
                    }
                }
                
                report.append(emptyLine)
                
                for entry in timedNotes[hour]! {
                    if entry.count > 1 {
                        let noteLine = entry["downtimeReason"]!.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
                        noteLine.append(emptyLine)
                        report.append(noteLine)
                    }
                }
                
                report.append(emptyLine)

            }
        } else if isHootReport {
            for hour in hootHours {
                switch hour {
                    
                case "0300":
                    let line = "0300 - 0400:\n\n".withBoldText(boldPartsOfString: ["0300 - 0400:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0400":
                    let line = "0400 - 0500:\n\n".withBoldText(boldPartsOfString: ["0400 - 0500:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0500":
                    let line = "0500 - 0600:\n\n".withBoldText(boldPartsOfString: ["0500 - 0600:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0600":
                    let line = "0600 - 0700:\n\n".withBoldText(boldPartsOfString: ["0600 - 0700:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)
                case "0700":
                    let line = "0700 - 0800:\n\n".withBoldText(boldPartsOfString: ["0700 - 0800:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
                    line.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, line.length))
                    line.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, line.length))
                    report.append(line)

                default:
                    break //Should not be reached

                }
                
                for entry in sortedDowntimeEntries[hour]! {
                    if entry.count > 1 {
                        let reportLine = NSMutableAttributedString()
                        
                        let firstPart = "\(entry["startTime"]!) - \(entry["endTime"]!)\t\(entry["downtimeReason"]!)\t".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont)
                        let secondPart = "(\(entry["totalTime"]!), \(entry["category"]!))\n"
                        let boldedPart = secondPart.withBoldText(boldPartsOfString: [secondPart as NSString], font: font, boldFont: boldFont)
                        
                        reportLine.append(firstPart)
                        reportLine.append(boldedPart)
                        
                        switch entry["category"]! {
                            
                        case "Mechanical":
                            totalMech = totalMech.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "Operational Scenario":
                            totalOp = totalOp.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "E-Stop":
                            totalEStop = totalEStop.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "System / Tech":
                            totalSys = totalSys.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        case "Deadtime":
                            totalDead = totalDead.adding(NSDecimalNumber(string: entry["totalTime"]!).rounding(accordingToBehavior: roundingBehavior))
                        default:
                            break   //should not be reached
                        }
                        
                        report.append(reportLine)
                        
                    }
                }
                
                report.append(emptyLine)
                
                for entry in timedNotes[hour]! {
                    if entry.count > 1 {
                        let noteLine = entry["downtimeReason"]!.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
                        noteLine.append(emptyLine)
                        report.append(noteLine)
                    }
                }
                
                report.append(emptyLine)

            }
        }
            
        
        let noteHeader = "Notes:".withBoldText(boldPartsOfString: ["Notes:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        noteHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, noteHeader.length))
        noteHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, noteHeader.length))
        report.append(noteHeader)
        report.append(emptyLine)
        report.append(emptyLine)
        
        for note in blankNotes {
            let noteLine = note["downtimeReason"]!.withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString
            noteLine.append(emptyLine)
            report.append(noteLine)
        }
        
        report.append(emptyLine)
        report.append(emptyLine)
        
        let totalHeader = "Totals:".withBoldText(boldPartsOfString: ["Totals:"], font: font, boldFont: boldFont) as! NSMutableAttributedString
        totalHeader.addAttribute(.underlineColor, value: NSColor.black, range: NSMakeRange(0, totalHeader.length))
        totalHeader.addAttribute(.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue), range: NSMakeRange(0, totalHeader.length))
        report.append(totalHeader)
        
        report.append(emptyLine)
        report.append(emptyLine)
        
        var totalDowntime = NSDecimalNumber.zero
        totalDowntime = totalDowntime.adding(totalMech)
        totalDowntime = totalDowntime.adding(totalOp)
        totalDowntime = totalDowntime.adding(totalEStop)
        totalDowntime = totalDowntime.adding(totalSys)
        totalDowntime = totalDowntime.adding(totalDead)
        
        let mechString = totalMech.description(withLocale: locale)
        let opString = totalOp.description(withLocale: locale)
        let estopString = totalEStop.description(withLocale: locale)
        let sysString = totalSys.description(withLocale: locale)
        let deadString = totalDead.description(withLocale: locale)
        
        let totalString = totalDowntime.description(withLocale: locale)
        
        report.append("Total Mechanical\t\(mechString) Hours\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString)
        report.append("Total Operational\t\(opString) Hours\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString)
        report.append("Total E-Stop Time\t\(estopString) Hours\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString)
        report.append("Total System/Tech\t\(sysString) Hours\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString)
        report.append("Total Deadtime\t\t\(deadString) Hours\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString)
        report.append(emptyLine)
        report.append("Total Downtime\t\t\(totalString) Hours\n".withBoldText(boldPartsOfString: [], font: font, boldFont: boldFont) as! NSMutableAttributedString)
        
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
        
        for (key, _) in sortedDowntimeEntries {
            sortedDowntimeEntries.updateValue([[:]], forKey: key)
        }
        
        for (key, _) in timedNotes {
            timedNotes.updateValue([[:]], forKey: key)
        }

        blankNotes.removeAll()
        
        report = NSMutableAttributedString()
        totalOp = 0.0
        totalSys = 0.0
        totalEStop = 0.0
        totalMech = 0.0
        totalDead = 0.0
        isDaysideReport = false
        isNightsideReport = false
        isHootReport = false
        
    }
    
}
