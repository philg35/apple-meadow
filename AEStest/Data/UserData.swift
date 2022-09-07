//
//  UserData.swift
//  AEStest
//
//  Created by Philip Gross on 9/6/22.
//

import Foundation
import SwiftUI
import Combine

class UserData : ObservableObject {
    @Published var allDeviceData = AllDeviceData
    var ipaddress : String
    var xml : GetXml
    
    init() {
        self.ipaddress = UserDefaults.standard.string(forKey: "defaultIP") ?? "10.0.0.251"
        print("self.ipaddress=", self.ipaddress)
        self.xml = GetXml(ipaddress: ipaddress)
        self.changeIpAddress()
    }

    
    typealias FinishedXmlRead = () -> ()
    
    func changeIpAddress() {
        self.xml = GetXml(ipaddress: ipaddress)
        self.loadData()
    }
    
    func readXmlAndCreateList(completed: FinishedXmlRead) {
        self.xml.startRead()
        self.xml.read()
        while (!self.xml.readReady()) {
            // do nothing. just wait
        }
        completed()
    }
    
    func createDeviceList() {
        var index = 0
        print("createDeviceList")
        for p in self.xml.deviceArray {
            print("parent", p.parentName)
            for d in p.devicesOnPort {
                print("device", d.label, index)
                
                self.allDeviceData.append(DeviceDataStruct(id: index, deviceId: d.deviceID, deviceName: d.label, productName: d.model, imageName: "", occState: false, outputState: false, level: 100, hasOcc: false, hasOutput: false, hasDim: false, stateReason: ""))
                
                index += 1
            }
        }
    }
    
    func loadData() {
        readXmlAndCreateList { () -> () in
            createDeviceList()
        }
    }
    
    func didPressSwitch(deviceID: String, newState: Bool) {
        print("switch \(deviceID) goto \(newState)")
        
    }

}

extension UserData {
    
    func _console(_ info: String) {
    }
    
//    func findDeviceParentIndexes(device: String) -> (Int) {
//        for (index, element) in self.phoneLight.enumerated() {
//            if element.deviceId == device {
//                return (index)
//            }
//        }
//        return (999)
//    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
