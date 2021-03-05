//
//  AppDelegate.swift
//  Downtime
//
//  Created by Joshua Kraft on 6/4/19.
//  Copyright © 2019 Joshua Kraft. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let nc = NotificationCenter.default
    let fm = FileManager.default
    var okToQuit = false
    var blockQuitFromLandside = false
    var blockQuitFromVessel = false
    var blockQuitFromRail = false
    
    let documentDirectory: String = NSHomeDirectory() + "/Documents/"
    
    let vesselExportDirectory: String = NSHomeDirectory() + "/Documents/_vessel-reports/"
    let railExportDirectory: String = NSHomeDirectory() + "/Documents/_rail-reports/"
    let landsideExportDirectory: String = NSHomeDirectory() + "/Documents/_landside-reports/"
    let handoffCopyDirectory: String = NSHomeDirectory() + "/Documents/_handoff/"
   
    let vesselSaveDataPath: String = NSHomeDirectory() + "/Documents/vessel_downtime_session_data.txt"
    let railSaveDataPath: String = NSHomeDirectory() + "/Documents/rail_downtime_session_data.txt"
    let landsideSaveDataPath: String = NSHomeDirectory() + "/Documents/landside_downtime_session_data.txt"
    
    let firstOldSavePath: String = NSHomeDirectory() + "/Documents/downtime_session_data.txt"
    let secondOldSavePath: String = NSHomeDirectory() + "/Documents/vessel_rail_session_data.txt"
    
    let vesselHandoffPath: String = NSHomeDirectory() + "/Documents/_handoff/vessel_downtime_session_data.txt"
    let railHandoffPath: String = NSHomeDirectory() + "/Documents/_handoff/rail_downtime_session_data.txt"
    let landsideHandoffPath: String = NSHomeDirectory() + "/Documents/_handoff/landside_downtime_session_data.txt"

    let allowedFileNames = ["_handoff", "_landside-reports", "_rail-reports", "_vessel-reports", "iChats", "landside_downtime_session_data.txt", "rail_downtime_session_data.txt", "vessel_downtime_session_data.txt"]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        nc.addObserver(self, selector: #selector(shouldBlockFromVessel), name: Notification.Name.vesselRailEntriesContainSaveCharacters, object: nil)
        nc.addObserver(self, selector: #selector(shouldBlockFromLandside), name: .landsideEntriesContainSaveCharacters, object: nil)

        nc.addObserver(self, selector: #selector(okToQuitFromVessel), name: Notification.Name.vesselRailEntriesDoNotContainSaveCharacters, object: nil)
        nc.addObserver(self, selector: #selector(okToQuitFromLandside), name: .landsideEntriesDoNotContainSaveCharacters, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.nc.post(name: Notification.Name.checkEntriesForSaveCharacters, object: nil) }
        
        if !fm.fileExists(atPath: vesselExportDirectory) {
            do { try fm.createDirectory(atPath: vesselExportDirectory, withIntermediateDirectories: true, attributes: nil) } catch {
                NSLog("Could not create export directory: \(error)")
                Swift.print(error)
                Swift.print("Destination directory: " + vesselExportDirectory)
            }
        }
        
        if !fm.fileExists(atPath: railExportDirectory) {
            do { try fm.createDirectory(atPath: railExportDirectory, withIntermediateDirectories: true, attributes: nil) } catch {
                NSLog("Could not create export directory: \(error)")
                Swift.print(error)
                Swift.print("Destination directory: " + railExportDirectory)
            }
        }
        
        if !fm.fileExists(atPath: landsideExportDirectory) {
            do { try fm.createDirectory(atPath: landsideExportDirectory, withIntermediateDirectories: true, attributes: nil) } catch {
                NSLog("Could not create export directory: \(error)")
                Swift.print(error)
                Swift.print("Destination directory: " + landsideExportDirectory)
            }
        }
        
        if !fm.fileExists(atPath: handoffCopyDirectory) {
            do { try fm.createDirectory(atPath: handoffCopyDirectory, withIntermediateDirectories: true, attributes: nil) } catch {
                NSLog("Could not create handoff directory: \(error)")
                Swift.print(error)
                Swift.print("Destination directory: " + handoffCopyDirectory)
            }
        }
        
        if fm.fileExists(atPath: firstOldSavePath) {
            do { try fm.removeItem(atPath: firstOldSavePath) } catch {
                NSLog("Could not remove first generation save data: \(error)")
                Swift.print(error)
            }
        }
        
        if fm.fileExists(atPath: secondOldSavePath) {
            do { try fm.removeItem(atPath: secondOldSavePath) } catch {
                NSLog("Could not remove second generation save data: \(error)")
                Swift.print(error)
            }
        }

        var documentDirectoryContents = [String]()
        
        do { try documentDirectoryContents = fm.contentsOfDirectory(atPath: documentDirectory) } catch {
            NSLog("Could not fetch document directory contents: \(error)")
            Swift.print(error)
        }
        
        if !documentDirectoryContents.isEmpty {
            for item in documentDirectoryContents {
                if !allowedFileNames.contains(item) {
                    let path = documentDirectory + item
                    do { try fm.removeItem(atPath: path) } catch {
                        NSLog("Could not remove file that shouldn't be present: \(error)")
                        Swift.print(error)
                    }
                }
            }
        }
        
    }
    
    @objc func shouldBlockFromVessel() {
        okToQuit = false
        blockQuitFromVessel = true
    }
    
    @objc func shouldBlockFromRail() {
        okToQuit = false
        blockQuitFromRail = true
    }
    
    @objc func shouldBlockFromLandside() {
        okToQuit = false
        blockQuitFromLandside = true
    }
    
    @objc func okToQuitFromVessel() {
        blockQuitFromVessel = false
    }
    
    @objc func okToQuitFromRail() {
        blockQuitFromRail = false
    }
    
    @objc func okToQuitFromLandside() {
        blockQuitFromLandside = false
    }
    
    
    
    func checkIfOKtoQuit() {
        if !blockQuitFromLandside && !blockQuitFromVessel && !blockQuitFromRail {
            okToQuit = true
        } else { okToQuit = false }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        nc.post(name: Notification.Name.checkEntriesForSaveCharacters, object: nil)
        
        checkIfOKtoQuit()
        
        if okToQuit {
            return .terminateNow
        } else {
            let alert = NSAlert()
            alert.messageText = "Disallowed characters!"
            alert.informativeText = "You either have the characters %$ or &#~ somewhere. These values have been turned red. Downtime uses these values to save your data, so you cannot use them in your downtime fields. Please get rid of them before quitting."
            alert.runModal()
            nc.post(name: Notification.Name.indicateBadEntries, object: nil)
            return .terminateCancel
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func displayTutorial(_ sender: Any) {
        NSWorkspace.shared.openFile(Bundle.main.path(forResource: "DowntimeTutorial", ofType: "pdf")!)
    }
    
    @IBAction func generateVesselHandoff(_ sender: Any) {
        
        if fm.fileExists(atPath: vesselHandoffPath) {
            do { try fm.removeItem(atPath: vesselHandoffPath) } catch {
                NSLog("Could not remove vessel handoff data: \(error)")
                Swift.print(error)
            }
        }
        
        do { try fm.copyItem(atPath: vesselSaveDataPath, toPath: vesselHandoffPath) } catch {
            NSLog("Could not copy item: \(error)")
            Swift.print(error)
        }
        
        NSWorkspace.shared.openFile(vesselHandoffPath, withApplication: "TextEdit", andDeactivate: false)

        let alert = NSAlert()
        alert.messageText = "Handoff Instructions"
        alert.informativeText = "The file just opened is your vessel save data for Downtime. Email this file to whoever you are handing off the operation to and have them use the \"Receive Handoff Data...\" option in the \"Handoff...\" menu to load the data."
        alert.runModal()
    }
    
    @IBAction func generateRailHandoff(_ sender: Any) {
        if fm.fileExists(atPath: railHandoffPath) {
            do { try fm.removeItem(atPath: railHandoffPath) } catch {
                NSLog("Could not remove rail handoff data: \(error)")
                Swift.print(error)
            }
        }
        
        do { try fm.copyItem(atPath: railSaveDataPath, toPath: railHandoffPath) } catch {
            NSLog("Could not copy item: \(error)")
            Swift.print(error)
        }
        
        NSWorkspace.shared.openFile(railHandoffPath, withApplication: "TextEdit", andDeactivate: false)
        
        let alert = NSAlert()
        alert.messageText = "Handoff Instructions"
        alert.informativeText = "The file just opened is your rail save data for Downtime. Email this file to whoever you are handing off the operation to and have them use the \"Receive Handoff Data...\" option in the \"Handoff...\" menu to load the data."
        alert.runModal()

    }
    
    @IBAction func generateLandsideHandoff(_ sender: Any) {
        
        if fm.fileExists(atPath: landsideHandoffPath) {
            do { try fm.removeItem(atPath: landsideHandoffPath) } catch {
                NSLog("Could not remove landside handoff data: \(error)")
                Swift.print(error)
            }
        }

        do { try fm.copyItem(atPath: landsideSaveDataPath, toPath: landsideHandoffPath) } catch {
            NSLog("Could not copy item: \(error)")
            Swift.print(error)
        }
        
        NSWorkspace.shared.openFile(landsideHandoffPath, withApplication: "TextEdit", andDeactivate: false)
        
        let alert = NSAlert()
        alert.messageText = "Handoff Instructions"
        alert.informativeText = "The file just opened is your landside save data for Downtime. Email this file to whoever you are handing off the operation to and have them use the \"Receive Handoff Data...\" option in the \"Handoff...\" menu to load the data."
        alert.runModal()
        
    }
    
    @IBAction func receiveHandoffData(_ sender: Any) {
        if let tabViewController = NSApplication.shared.mainWindow?.contentViewController as? NSTabViewController {
            if tabViewController.selectedTabViewItemIndex == 0 {
                nc.post(name: .displayVesselSaveDataView, object: nil)
            } else if tabViewController.selectedTabViewItemIndex == 1 {
                nc.post(name: .displayRailSaveDataView, object: nil)
            } else if tabViewController.selectedTabViewItemIndex == 2 {
                nc.post(name: .displayLandsideSaveDataView, object: nil)
            }
        }
    }
    //test
}


