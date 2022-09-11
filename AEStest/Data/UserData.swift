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
    var np : NlightPacket
    var ipConn : IPConnection
    @Published var favoritesList : [String]
    
    var timer: Timer?
    var runCount = 0
    
    init() {
        self.ipaddress = UserDefaults.standard.string(forKey: "defaultIP") ?? "10.0.0.251"
        print("self.ipaddress=", self.ipaddress)
        self.xml = GetXml(ipaddress: ipaddress)
        self.np = NlightPacket()
        self.ipConn = IPConnection(ipaddress: self.ipaddress)
        self.favoritesList = UserDefaults.standard.object(forKey: "favoriteList") as? [String] ?? [""]
        print("self.favoritesList=", self.favoritesList)
        self.changeIpAddress(ipaddr: self.ipaddress)
    }

    
    typealias FinishedXmlRead = () -> ()
    
    func changeIpAddress(ipaddr: String) {
        self.xml = GetXml(ipaddress: ipaddr)
        self.loadData()
        self.ipConn = IPConnection(ipaddress: ipaddr)
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
                var hasOutput = false
                print("device", d.label, index)
                for f in self.favoritesList {
                    if f == d.deviceID {
                        hasOutput = true
                    }
                }
                self.allDeviceData.append(DeviceDataStruct(id: index, deviceId: d.deviceID, deviceName: d.label, productName: d.model, imageName: "", occState: false, outputState: false, level: 100, hasOcc: false, hasOutput: hasOutput, hasDim: false, stateReason: ""))
                
                index += 1
            }
        }
    }
    
    func loadData() {
        readXmlAndCreateList { () -> () in
            createDeviceList()
        }
        ReadStatus()
    }
    
    func didPressSwitch(deviceID: String, newState: Bool) {
        var pay : String
        if newState {
            pay = "010100"
        }
        else {
            pay = "010200"
        }
        let p = self.np.CreatePacket(dest: deviceID, src: "00fb031b", subj: "79", payload: pay)
        let r = self.ipConn.send(nlightString: p)
        print(r)
        
        ReadStatus()
    }
    
    func ReadStatus() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        }
        runCount = 0
    }

    func didPressCurtsy(deviceID: String) {
        let p = self.np.CreatePacket(dest: deviceID, src: "00fb031b", subj: "BA", payload: "")
        let r = self.ipConn.send(nlightString: p)
        print(r)
    }
    
    @objc func fireTimer() {
        print("Timer fired!")
        
        for s in self.favoritesList {
            let p = np.CreatePacket(dest: s, src: "00fb031b", subj: "74", payload: "15")
            let r = self.ipConn.send(nlightString: p)
            let s : NlightPacketStruct = self.np.parseStatus(packet: r)
            print(r)
            print(s)
            let pIndex = findDeviceParentIndexes(device: s.source)
            self.allDeviceData[pIndex].outputState = self.np.checkOutputOn(payload: s.payload)
        }
        
        runCount += 1
        print("runCount=", runCount)
        if runCount >= 2 {
            timer?.invalidate()
            self.timer = nil
            print("tried to invalidate....did it work?")
        }
    }
    
    func findDeviceParentIndexes(device: String) -> (Int) {
        for (index, element) in self.allDeviceData.enumerated() {
            if element.deviceId == device {
                return (index)
            }
        }
        return (999)
    }
    
}

extension UserData {
    
    func _console(_ info: String) {
    }
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
