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
    typealias FinishedXmlRead = () -> ()
    
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

                self.phoneLight.append(PhoneLight(id: index, deviceId: d.deviceID, deviceName: d.label, productName: d.model, imageName: "none", occState: false, outputState: false, level: 100, hasOcc: false, hasOutput: false))
                index += 1
            }
        }
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
        
//        let clientCertArray = NSArray(contentsOfFile: "caCertificate.crt")
//        var sslSettings: [String: NSObject] = [:]
//        sslSettings[kCFStreamSSLCertificates as String] = clientCertArray
//        mqtt!.sslSettings = sslSettings
        
        mqtt.allowUntrustCACertificate = true
        
        mqtt.connect()
        mqtt.delegate = self
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
