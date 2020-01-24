//
//  DragWellView.swift
//  BaplieScrubber
//
//  Created by Joshua Kraft on 9/7/18.
//  Copyright © 2018 Joshua Kraft. All rights reserved.
//

import Cocoa

protocol DragWellViewDelegate: class {
    func getSaveFilePath(path: String)
}

class DragWellView: NSImageView {

    let nc = NotificationCenter.default
    
    let fileTypes = ["edi", "txt"]
    var droppedFilePath: String?
    var pathForNotification: [String: String] = ["path":""]
    
    var hasFile = false
    
    weak var delegate: DragWellViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) { //Register for dragging - add an observer for the AppDelegate notification to open with a BAPLIE
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType("public.file-url"), NSPasteboard.PasteboardType("public.item")])
        self.wantsLayer = true
    }
    
    func checkExtension(_ sender: NSDraggingInfo) -> Bool { //Check for .edi or .txt extensions, or for errlog name for received error logs on inbound BAPLIEs
        guard let pb = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pb[0] as? String else { return false }
        
        let fileName = URL(fileURLWithPath: path).lastPathComponent.lowercased()
        let suffix = URL(fileURLWithPath: path).pathExtension.lowercased()
        
        if fileName == "errlog" {
            return true
        }
        
        for type in fileTypes {
            if type.lowercased() == suffix {
                return true
            }
        }
        
        return false
    }
    
    func clearFile() { //Call to return to launch-state
        self.image = NSImage(named: NSImage.Name("dimView"))
        droppedFilePath = nil
        hasFile = false
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation { //If dragging enters and extension is valid, light the drag well
        if hasFile {
            return []
        } else if checkExtension(sender) {
            self.image = NSImage(named: NSImage.Name("litView"))
            return .copy
        }
        
        return []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) { //If dragging exits, dim the drag well
        if !hasFile {
            self.image = NSImage(named: NSImage.Name("dimView"))
        }
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) { //If dragging finishes and performDragOperation is successful, activate the drag well
        if hasFile {
            self.image = NSImage(named: NSImage.Name("activeView"))
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool { //Copy the BAPLIE if the extension is valid
        guard let pb = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = pb[0] as? String else { return false } //Get the filepath of the dragged item
        
        droppedFilePath = path
        hasFile = true //set the hasBaplie flag
        
        let fileName = URL(fileURLWithPath: droppedFilePath!).lastPathComponent.lowercased()
        pathForNotification.updateValue(droppedFilePath!, forKey: "path")
        
        if fileName.contains("vessel_") {
            nc.post(name: .loadVesselSaveData, object: nil, userInfo: pathForNotification)
        } else if fileName.contains("rail_") {
            nc.post(name: .loadRailSaveData, object: nil, userInfo: pathForNotification)
        } else if fileName.contains("landside_") {
            nc.post(name: .loadLandsideSaveData, object: nil, userInfo: pathForNotification)
        }
        
        nc.post(name: .dismissSaveDataView, object: nil)
        
        return true
    }
        
}
