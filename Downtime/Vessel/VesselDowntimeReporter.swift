//
//  VesselDowntimeReporter.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/9/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

class VesselDowntimeReporter: NSObject {

    var allDowntimeEntries = [[String: String]]()
    
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
    
    let sortedDowntimeKeyForValue = ["00":"0000", "01":"0100", "02":"0200", "03":"0300", "04":"0400", "05":"0500", "06":"0600", "07":"0700", "08":"0800", "09":"0900", "10":"1000", "11":"1100", "12":"1200", "13":"1300", "14":"1400", "15":"1500", "16":"1600", "17":"1700", "18":"1800", "19":"1900", "20":"2000", "21":"2100", "22":"2200", "23":"2300", "24":"2400"]
    
    let daysideHours = ["0800", "0900", "1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800"]
    let nightsideHours = ["1800", "1900", "2000", "2100", "2200", "2300", "0000", "0100", "0200", "0300"]
    
    var report = [String]()
    
    var totalMech = 0.0
    var totalOp = 0.0
    var totalSys = 0.0
    var totalDead = 0.0
    
    let emptyLine = ",\"\",,,,,\n"
    
    let exportDirectory: String = NSHomeDirectory() + "/Documents/"
    
    func getDowntimeEntries(data: [[String: String]]) {
        allDowntimeEntries = data
        sortDowntimeEntries()
    }
    
    func sortDowntimeEntries() {
        for entry in allDowntimeEntries {
            let startingHour = entry["startTime"]!.substring(toIndex: (entry["startTime"]!.length - 2))
            sortedDowntimeEntries[sortedDowntimeKeyForValue[startingHour]!]?.append(entry)
        }
        
        getNightsideReportContent()
    }
    
    func getDaysideReportContent() {
        //To come
    }
    
    
    func getNightsideReportContent() {
        
        report.removeAll()
        
        report.append("Hour,Start Time,End Time,Downtime Reason,Total Time,Category\n")
        report.append(emptyLine)
        
        for hour in nightsideHours {
            
            switch hour {
            case "1800":
                report.append("1800-1900,,,,,,\n")
            case "1900":
                report.append("1900-2000,,,,,,\n")
            case "2000":
                report.append("2000-2100,,,,,,\n")
            case "2100":
                report.append("2100-2200,,,,,,\n")
            case "2200":
                if sortedDowntimeEntries["2200"]!.count == 1 {
                    break
                }
                report.append("2200-2300,,,,,,\n")
            case "2300":
                report.append("2300-0000,,,,,,\n")
            case "0000":
                report.append("0000-0100,,,,,,\n")
            case "0100":
                report.append("0100-0200,,,,,,\n")
            case "0200":
                report.append("0200-0300,,,,,,\n")
            default:
                break //should not be reached
            }
            
            for entry in sortedDowntimeEntries[hour]! {
                if entry.count > 1 {
                    var csvLine = String()
                    
                    csvLine = ",=\"\(entry["startTime"]!)\",=\"\(entry["endTime"]!)\",\"\(entry["downtimeReason"]!)\",\(entry["totalTime"]!),\(entry["category"]!)\n"
                    
                    switch entry["category"]! {
                        
                    case "Mechanical":
                        totalMech += Double(entry["totalTime"]!)!
                    case "Operational Scenario":
                        totalOp += Double(entry["totalTime"]!)!
                    case "System / Tech":
                        totalSys += Double(entry["totalTime"]!)!
                    case "Deadtime":
                        totalDead += Double(entry["totalTime"]!)!
                    default:
                        break   //should not be reached
                    }
                    
                    report.append(csvLine)

                }
            }
            
            report.append(emptyLine)
            
        }
        
        let totalDowntime = totalOp + totalSys + totalMech + totalDead
        
        for _ in 1...3 {
            report.append(emptyLine)
        }
        
        report.append("Total Operational,\(String(totalOp)),Hours,,\n")
        report.append("Total System/Tech,\(String(totalSys)),Hours,,\n")
        report.append("Total Mechanical,\(String(totalMech)),Hours,,\n")
        report.append("Total Deadtime,\(String(totalDead)),Hours,,\n")
        report.append(emptyLine)
        report.append("Total Downtime,\(String(totalDowntime)),Hours,,\n")

        let date = Date()
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        var dateString = df.string(from: date)
        dateString = dateString.replacingOccurrences(of: "/", with: "-")
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
        
        for (key, _) in sortedDowntimeEntries {
            sortedDowntimeEntries.updateValue([[:]], forKey: key)
        }
        
    }
    
    func getHootReportContent() {
        //To come
    }
    
}
