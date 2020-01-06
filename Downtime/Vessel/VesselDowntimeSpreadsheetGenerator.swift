//
//  VesselDowntimeSpreadsheetGenerator.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/9/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class VesselDowntimeSpreadsheetGenerator: NSObject {

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
    
    var daysideHours = ["0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600"]
    var nightsideHours = ["1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200"]
    var hootHours = ["0300", "0400", "0500", "0600", "0700"]
    
    var isDaysideReport = false
    var isNightsideReport = false
    var isHootReport = false
    
    var isFlexStart = false
    var isExtendedShift = false

    var report = [String]()
    
    var totalMech = NSDecimalNumber.zero
    var totalOp = NSDecimalNumber.zero
    var totalEStop = NSDecimalNumber.zero
    var totalSys = NSDecimalNumber.zero
    var totalDead = NSDecimalNumber.zero
    
    let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 1, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
    
    let locale = NSLocale.autoupdatingCurrent

    let emptyLine = ",\"\",,,,,\n"
    
    let exportDirectory: String = NSHomeDirectory() + "/Documents/_vessel+rail-Reports/"

    func getDowntimeEntries(data: [[String: String]], shift: String, flex: Bool, extended: Bool) {
        allDowntimeEntries = data
        
        if shift == "day" {
            isDaysideReport = true
        } else if shift == "night" {
            isNightsideReport = true
        } else if shift == "hoot" {
            isHootReport = true
        }
        
        isFlexStart = flex
        isExtendedShift = extended
        
        if isFlexStart && !isExtendedShift {
            daysideHours = ["0700", "0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600"]
            nightsideHours = ["1700", "1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200"]
        }
        
        if !isFlexStart && isExtendedShift {
            daysideHours = ["0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800"]
            nightsideHours = ["1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200", "0300", "0400"]
        }
        
        if isFlexStart && isExtendedShift {
            daysideHours = ["0700", "0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800"]
            nightsideHours = ["1700", "1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200", "0300", "0400"]
            
        }
        
        if !isFlexStart && !isExtendedShift {
            daysideHours = ["0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600"]
            nightsideHours = ["1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200"]
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
        
        report.removeAll()
        
        report.append("Hour,Start Time,End Time,Downtime Reason,Total Time,Category\n")
        report.append(emptyLine)

        if isDaysideReport {
            for hour in daysideHours {
                switch hour {
                case "0700":
                    report.append("0700-0800,,,,,,\n")
                case "0800":
                    report.append("0800-0900,,,,,,\n")
                case "0900":
                    report.append("0900-1000,,,,,,\n")
                case "1000":
                    report.append("1000-1100,,,,,,\n")
                case "1100":
                    report.append("1100-1200,,,,,,\n")
                case "1200":
                    report.append("1200-1300,,,,,,\n")
                case "1300":
                    report.append("1300-1400,,,,,,\n")
                case "1400":
                    report.append("1400-1500,,,,,,\n")
                case "1500":
                    report.append("1500-1600,,,,,,\n")
                case "1600":
                    report.append("1600-1700,,,,,,\n")
                case "1700":
                    report.append("1700-1800,,,,,,\n")
                case "1800":
                    report.append("1800-1900,,,,,,\n")
                default:
                    break //should not be reached
                }
                
                for entry in sortedDowntimeEntries[hour]! {
                    if entry.count > 1 {
                        var csvLine = String()
                        
                        csvLine = ",=\"\(entry["startTime"]!)\",=\"\(entry["endTime"]!)\",\"\(entry["downtimeReason"]!)\",\(entry["totalTime"]!),\(entry["category"]!)\n"
                        
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
                        
                        report.append(csvLine)
                        
                    }
                }
                
                report.append(emptyLine)

            }
        } else if isNightsideReport {
            for hour in nightsideHours {
                switch hour {
                case "1700":
                    report.append("1700-1800,,,,,,\n")
                case "1800":
                    report.append("1800-1900,,,,,,\n")
                case "1900":
                    report.append("1900-2000,,,,,,\n")
                case "2000":
                    report.append("2000-2100,,,,,,\n")
                case "2100":
                    report.append("2100-2200,,,,,,\n")
                case "2200":
                    report.append("2200-2300,,,,,,\n")
                case "2300":
                    report.append("2300-0000,,,,,,\n")
                case "0000":
                    report.append("0000-0100,,,,,,\n")
                case "0100":
                    report.append("0100-0200,,,,,,\n")
                case "0200":
                    report.append("0200-0300,,,,,,\n")
                case "0300":
                    report.append("0300-0400,,,,,,\n")
                case "0400":
                    report.append("0400-0500,,,,,,\n")

                default:
                    break //should not be reached
                }
                
                for entry in sortedDowntimeEntries[hour]! {
                    if entry.count > 1 {
                        var csvLine = String()
                        
                        csvLine = ",=\"\(entry["startTime"]!)\",=\"\(entry["endTime"]!)\",\"\(entry["downtimeReason"]!)\",\(entry["totalTime"]!),\(entry["category"]!)\n"
                        
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
                        report.append(csvLine)
                    }
                }
                report.append(emptyLine)
            }
        } else if isHootReport {
           
            for hour in hootHours {
                switch hour {
                case "0300":
                    report.append("0300-0400,,,,,,\n")
                case "0400":
                    report.append("0400-0500,,,,,,\n")
                case "0500":
                    report.append("0500-0600,,,,,,\n")
                case "0600":
                    report.append("0600-0700,,,,,,\n")
                case "0700":
                    report.append("0700-0800,,,,,,\n")
                default:
                    break
                }
            
                for entry in sortedDowntimeEntries[hour]! {
                    if entry.count > 1 {
                        var csvLine = String()
                        
                        csvLine = ",=\"\(entry["startTime"]!)\",=\"\(entry["endTime"]!)\",\"\(entry["downtimeReason"]!)\",\(entry["totalTime"]!),\(entry["category"]!)\n"
                        
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
                        report.append(csvLine)
                    }
                }
                report.append(emptyLine)
            }
        }
        
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

        report.append("Total Mechanical,\(mechString),Hours,,\n")
        report.append("Total Operational,\(opString),Hours,,\n")
        report.append("Total E-Stop Time,\(estopString),Hours,,\n")
        report.append("Total System/Tech,\(sysString),Hours,,\n")
        report.append("Total Deadtime,\(deadString),Hours,,\n")
        report.append(emptyLine)
        report.append("Total Downtime,\(totalString),Hours,,\n")

        openFile()
    }
    
    func openFile() {
        let date = Date()
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        var dateString = df.string(from: date)
        dateString = dateString.replacingOccurrences(of: "/", with: "-")
        dateString = dateString.replacingOccurrences(of: ":", with: "")
        let fileName = "Downtime Report " + dateString + ".csv"
        let destination = exportDirectory + fileName
        let contents = report.joined()
        
        do {
            try contents.write(toFile: destination, atomically: true, encoding: .utf8)
        } catch {
            let alert = NSAlert(error: error)
            alert.informativeText = "Could not write file to destination: \(destination)"
            alert.runModal()
        }
        
        let ws = NSWorkspace()
        
        ws.openFile(destination)
        
        report.removeAll()
        
        totalMech = 0.0
        totalOp = 0.0
        totalEStop = 0.0
        totalSys = 0.0
        totalDead = 0.0
        isDaysideReport = false
        isNightsideReport = false
        isHootReport = false
        
        for (key, _) in sortedDowntimeEntries {
            sortedDowntimeEntries.updateValue([[:]], forKey: key)
        }
        
        for (key, _) in timedNotes {
            timedNotes.updateValue([[:]], forKey: key)
        }

        blankNotes.removeAll()
    }
}
