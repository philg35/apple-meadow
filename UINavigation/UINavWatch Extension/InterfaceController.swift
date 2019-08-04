//
//  InterfaceController.swift
//  UINavWatch Extension
//
//  Created by Philip Gross on 8/3/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        if segueIdentifier == "hierarchical" {
            return ["segue": "hierarchical",
                    "data":"Passed through hierarchical navigation"]
        } else if segueIdentifier == "pagebased" {
            return ["segue": "pagebased",
                    "data": "Passed through page-based navigation"]
        } else {
            return ["segue": "", "data": ""]
        }
    }
}
