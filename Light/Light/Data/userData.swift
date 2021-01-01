//
//  userData.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import Foundation
import SwiftUI
import Combine
import CocoaMQTT

var mqttStarted = false

class UserData : ObservableObject {
    @Published var phoneLight = phoneLightData
    let xml = GetXml()
    var mqtt: CocoaMQTT!
    //var savedImages : [String] = UserDefaults.standard.stringArray(forKey: "SavedImages") ?? [String]()
    typealias FinishedXmlRead = () -> ()
    var dictImages: [String:String] = UserDefaults.standard.object(forKey: "SavedImages") as? [String:String] ?? [:]

    init() {
        self.loadData()
        self.setUpMQTT()
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
                
                self.phoneLight.append(PhoneLight(id: index, deviceId: d.deviceID, deviceName: d.label, productName: d.model, imageName: self.getImage(deviceId: d.deviceID), occState: false, outputState: false, level: 100, hasOcc: false, hasOutput: false))
                
                index += 1
            }
        }
    }
    
    func getImage(deviceId: String) -> String {
        if let val = dictImages[deviceId] {
            // now val is not nil and the Optional has been unwrapped, so use it
            return val
        }
        else {
            return "014-light-bulb"
        }
    }
    
    func saveImage(deviceId: String, imageName: String) {
        dictImages[deviceId] = imageName
        UserDefaults.standard.set(dictImages, forKey: "SavedImages")
    }
    
    
    func loadData() {
        readXmlAndCreateList { () -> () in
            createDeviceList()
        }
    }
    
    func setUpMQTT() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: ipAddress, port: 8883)
        mqtt.username = ""
        mqtt.password = ""
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 60
        mqtt.enableSSL = true
        
        mqtt.allowUntrustCACertificate = true
        
        print(mqtt.connect())
        mqtt.delegate = self
    }
    
    func didPressSwitch(deviceID: String, newState: Bool) {
        print("switch \(deviceID) goto \(newState)")
        mqtt.publish("nLight/version/2/control/device/\(deviceID)/pole/1/relay-state", withString: "{\"state\":\(newState)}", qos: .qos1, retained: false, dup: false)
    }
}

extension UserData: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        
    }
    
    // These two methods are all we care about for now
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect, yay")
        mqtt.subscribe("nLight/version/2/status/device/#", qos: CocoaMQTTQOS.qos1)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print(message.topic, message.string as Any)
        if let msgString = message.string {
            //textview.text?.append("***" + message.topic + " = " + msgString + "\r\n")
            processMqttMessage(topic: message.topic, message: msgString)
        }
    }
    
    // Other required methods for CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("didReceive trust!!!")
        completionHandler(true)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("connected ok")
        mqtt.subscribe("nLight/version/2/status/device/#", qos: CocoaMQTTQOS.qos1)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("published ok")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("published ack ok")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("pinged ok")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("disconnected")
        mqttStarted = false
        print("\(err.debugDescription)")
    }
    
    func _console(_ info: String) {
    }
    
    func processMqttMessage(topic: String, message: String) {
        if topic.contains("pole/1/relay-state") {
            let t = topic.components(separatedBy: "/")
            let (pIndex) = findDeviceParentIndexes(device: t[5])
            self.phoneLight[pIndex].hasOutput = true
            self.phoneLight[pIndex].outputState = message.contains("true")
            //self.tableview.reloadData()
        } else if topic.contains("pole/1/occupied") {
            let t = topic.components(separatedBy: "/")
            let (pIndex) = findDeviceParentIndexes(device: t[5])
            self.phoneLight[pIndex].hasOcc = true
            self.phoneLight[pIndex].occState = message.contains("true")
            //self.tableview.reloadData()
        }
    }
    
    func findDeviceParentIndexes(device: String) -> (Int) {
        for (index, element) in self.phoneLight.enumerated() {
            if element.deviceId == device {
                return (index)
            }
        }
        return (0)
    }
}
