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
    var blockQuitFromVesselRail = false
    
    let vesselRailExportDirectory: String = NSHomeDirectory() + "/Documents/_vessel+rail-Reports/"
    let landsideExportDirectory: String = NSHomeDirectory() + "/Documents/_landside-reports/"
   
    let vesselSaveDataPath: String = NSHomeDirectory() + "/Documents/vessel_rail_downtime_session_data.txt"
    let landsideSaveDataPath: String = NSHomeDirectory() + "/Documents/landside_downtime_session_data.txt"

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        nc.addObserver(self, selector: #selector(shouldBlockFromVesselRail), name: Notification.Name.vesselRailEntriesContainSaveCharacters, object: nil)
        nc.addObserver(self, selector: #selector(shouldBlockFromLandside), name: .landsideEntriesContainSaveCharacters, object: nil)

        nc.addObserver(self, selector: #selector(okToQuitFromVesselRail), name: Notification.Name.vesselRailEntriesDoNotContainSaveCharacters, object: nil)
        nc.addObserver(self, selector: #selector(okToQuitFromLandside), name: .landsideEntriesDoNotContainSaveCharacters, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.nc.post(name: Notification.Name.checkEntriesForSaveCharacters, object: nil) }
        
        if !fm.fileExists(atPath: vesselRailExportDirectory) {
            do { try fm.createDirectory(atPath: vesselRailExportDirectory, withIntermediateDirectories: true, attributes: nil) } catch {
                NSLog("Could not create export directory: \(error)")
                Swift.print(error)
                Swift.print("Destination directory: " + vesselRailExportDirectory)
            }
        }
        
        if !fm.fileExists(atPath: landsideExportDirectory) {
            do { try fm.createDirectory(atPath: landsideExportDirectory, withIntermediateDirectories: true, attributes: nil) } catch {
                NSLog("Could not create export directory: \(error)")
                Swift.print(error)
                Swift.print("Destination directory: " + landsideExportDirectory)
            }
        }

    }
    
    @objc func shouldBlockFromVesselRail() {
        okToQuit = false
        blockQuitFromVesselRail = true
    }
    
    @objc func shouldBlockFromLandside() {
        okToQuit = false
        blockQuitFromLandside = true
    }
    
    @objc func okToQuitFromVesselRail() {
        blockQuitFromVesselRail = false
    }
    
    @objc func okToQuitFromLandside() {
        blockQuitFromLandside = false
    }
    
    
    
    func checkIfOKtoQuit() {
        if !blockQuitFromLandside && !blockQuitFromVesselRail {
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
    
    @IBAction func generateVesselRailHandoff(_ sender: Any) {
        NSWorkspace.shared.openFile(vesselSaveDataPath, withApplication: "TextEdit", andDeactivate: false)
        let alert = NSAlert()
        alert.messageText = "Handoff Instructions"
        alert.informativeText = "The file just opened is your vessel or rail save data for Downtime. Email this file to whoever you are handing off the operation to and have them use the \"Receive Handoff Data...\" option in the \"Handoff...\" menu to load the data."
        alert.runModal()
    }
    
    @IBAction func generateLandsideHandoff(_ sender: Any) {
        NSWorkspace.shared.openFile(landsideSaveDataPath, withApplication: "TextEdit", andDeactivate: false)
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
                nc.post(name: .displayLandsideSaveDataView, object: nil)
            }
        }
    }
    
}


