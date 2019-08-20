//
//  DeviceViewController.swift
//  tableviewSwift
//
//  Created by Philip Gross on 8/18/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import Foundation
import UIKit

class DeviceViewController : UIViewController {
    @IBOutlet weak var eventsTextView: UITextView!
    @IBOutlet weak var statesTextView: UITextView!
    
    var events: [String?] = []
    
    override func viewDidLoad() {
        print("in the new class")
        for event in events {
            eventsTextView.text += event ?? "" + "\r\n"
            
            if (event?.contains("relay-state"))! {
                statesTextView.text += event ?? "" + "\r\n"
            }
        }
        
    }
}
