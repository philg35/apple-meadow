//
//  SecondInterfaceController.swift
//  UINavWatch Extension
//
//  Created by Philip Gross on 8/4/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import WatchKit
import Foundation

class SecondInterfaceController: WKInterfaceController {
    @IBOutlet weak var label: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let dict = context as? NSDictionary
        if dict != nil {
            _ = dict!["segue"] as! String
            let data = dict!["data"] as! String
            self.label.setText(data)
        }
    }
}
