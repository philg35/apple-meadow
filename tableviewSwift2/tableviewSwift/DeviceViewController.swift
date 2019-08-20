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
            
            var dictonary: NSDictionary?
            let t = event?.components(separatedBy: "=")
            let m = t![0].components(separatedBy: "/")
            var timeStamp = ""
            if let data = t?[1].data(using: String.Encoding.utf8) {
                
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                    
                    if let myDictionary = dictonary
                    {
                        print(myDictionary)
                        timeStamp = (convertDateFormatter(date: myDictionary.value(forKey: "ts") as! String))
                        
                        if let state = myDictionary["relay-state"] {
                            statesTextView.text += "\(timeStamp) = \(state) \r\n"
                        }
//                        if (event?.contains("relay-state"))! {
//                            statesTextView.text += timeStamp + "=" + myDictionary["relay-state"] + "\r\n"
//                        }
                        
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
            
            eventsTextView.text += timeStamp + "=" + m.last! + t![1] + "\r\n"
            
            
        }
        
    }
    
    func convertDateFormatter(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"//this your string date format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        dateFormatter.locale = Locale(identifier: "your_loc_id")
        let convertedDate = dateFormatter.date(from: date)
        
        guard dateFormatter.date(from: date) != nil else {
            assert(false, "no date from string")
            return ""
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd EEEE hh:mm:ss a"///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
        let timeStamp = dateFormatter.string(from: convertedDate!)
        
        return timeStamp
    }
}
