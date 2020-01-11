//
//  SaveDataDragWellViewController.swift
//  Downtime
//
//  Created by Joshua Kraft on 1/10/20.
//  Copyright © 2020 Joshua Kraft. All rights reserved.
//

import Cocoa

class SaveDataDragWellViewController: NSViewController {

    @IBOutlet var dragWell: DragWellView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissView(_ sender: Any) {
        if dragWell != nil {
            dragWell.clearFile()
            dismiss(self)
        }
    }
}
