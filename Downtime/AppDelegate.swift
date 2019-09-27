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
    var okToQuit = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        nc.addObserver(self, selector: #selector(canQuit), name: Notification.Name.entriesDoNotContainSaveCharacters, object: nil)
        nc.addObserver(self, selector: #selector(cannotQuit), name: Notification.Name.entriesContainSaveCharacters, object: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { self.nc.post(name: Notification.Name.checkEntriesForSaveCharacters, object: nil) }
        
    }
    
    @objc func canQuit() {
        okToQuit = true
    }

    @objc func cannotQuit() {
        okToQuit = false
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        
        nc.post(name: Notification.Name.checkEntriesForSaveCharacters, object: nil)
        
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
}

