//
//  ViewController.swift
//  tableviewSwift
//
//  Created by Philip Gross on 3/20/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit
import CocoaMQTT

public var ipAddress = "10.0.0.251"
var mqttStarted = false

// https://10.0.0.251/api/rest/v1/system/web-server/protocols/https/certificate/document

class ViewController: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var textview: UITextView!
    
    struct PortDevices
    {
        var parentPort: String
        var parentName: String
        var devicesOnPort: [DevXml]
    }
    
    var mqtt: CocoaMQTT!
    private var parentList: [String] = []
    private var deviceArray: [PortDevices] = []
    private var groupLabels: [DevXml] = []
    private var groupDict: [String : String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ipAddress = UserDefaults.standard.string(forKey: "defaultIP") ?? "10.0.0.251"
        tableview.dataSource = self
        tableview.delegate = self
        doXmlRead()
        self.title = ipAddress
    }
    
    func loadAll(ipAddr: String)
    {
        print("loading all", ipAddr)
        ipAddress = ipAddr
        self.title = ipAddress
        let defaults = UserDefaults.standard
        defaults.set(ipAddress, forKey: "defaultIP")
        doXmlRead()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("preparing segue???")
        if let vc = segue.destination as? DeviceViewController
        {
            let row = tableview.indexPathForSelectedRow?.row
            let section = tableview.indexPathForSelectedRow?.section
            vc.events = GetEventsForDevice(device: self.deviceArray[section ?? 0].devicesOnPort[row ?? 0].deviceID)
        }
        else if let vc = segue.destination as? ConfigViewController
        {
            print("config view controller")
            vc.mainVc = self
        }
        else
        {
            print("some other view controller")
        }
        
    }
    
    func GetEventsForDevice(device: String) -> [String] {
        var events : [String] = []
        let lines = textview.text.components(separatedBy: "\n")
        for line in lines {
            if line.contains(device) {
                events.append(line)
            }
        }
        return events
    }
    
    func doXmlRead() {
        if mqttStarted == true {
            mqtt.disconnect()
        }
        var contents = ""
        let urlField = "https:" + ipAddress + "/ngw/devices.xml"
        let url = URL(string: urlField)!
        let request = URLRequest(url: url)
        
        let sessionDelegate = SessionDelegate()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if data != nil {
                contents = (String(data: data!, encoding: String.Encoding.utf8) as String?)!
                contents = contents.replacingOccurrences(of: "\r", with: "\n")
            }
            
            let p = ParseXml()
            p.setData(data: data)
            p.parse()
            
            for item in p.items {
                let parentPort = item.parentPort
                if !self.parentList.contains(parentPort) {
                    self.parentList.append(parentPort)
                }
            }
            
            self.deviceArray.removeAll()    // clear all to start
            for parent in self.parentList {
                var devs: [DevXml] = []
                for device in p.items {
                    if device.parentPort == parent {
                        if device.groupLabel != "" {
                            self.groupLabels.append(device)
                        }
                        else if !device.model.contains("POD") && !device.model.contains("ECYD") {
                            devs.append(device)
                        }
                    }
                }
                if devs.count > 0 {
                    devs.sort {
                        $0.model.localizedCaseInsensitiveCompare($1.model) == ComparisonResult.orderedAscending
                    }
                    let devicesPort = PortDevices(parentPort: parent, parentName: "", devicesOnPort: devs)
                    self.deviceArray.append(devicesPort)
                }
            }
            
            for group in self.groupLabels {
                self.groupDict[group.parentPort] = group.groupLabel     // determine groupLabel dictionary
            }
            
            if (self.deviceArray.count > 0) {
                for index in 0...(self.deviceArray.count - 1) {             // add in parentName (now that groupLabels dictionary is set)
                    self.deviceArray[index].parentName = self.groupDict[self.deviceArray[index].parentPort] ?? "none"
                }
            }
            
            self.deviceArray.sort { $0.parentName < $1.parentName}      // sort sections by parentName
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
                if mqttStarted == false {
                    mqttStarted = true
                    self.setUpMQTT()
                }
            }
        }
        task.resume()
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

extension ViewController: CocoaMQTTDelegate {
    // These two methods are all we care about for now
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect, yay")
        mqtt.subscribe("nLight/version/2/status/device/#", qos: CocoaMQTTQOS.qos1)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        //print(message.topic, message.string as Any)
        if let msgString = message.string {
            textview.text?.append("***" + message.topic + " = " + msgString + "\r\n")
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
            let (pIndex, dIndex) = findDeviceParentIndexes(device: t[5])
            self.deviceArray[pIndex].devicesOnPort[dIndex].hasOutput = true
            self.deviceArray[pIndex].devicesOnPort[dIndex].outputState = message.contains("true")
            self.tableview.reloadData()
        } else if topic.contains("pole/1/occupied") {
            let t = topic.components(separatedBy: "/")
            let (pIndex, dIndex) = findDeviceParentIndexes(device: t[5])
            self.deviceArray[pIndex].devicesOnPort[dIndex].hasOccupany = true
            self.deviceArray[pIndex].devicesOnPort[dIndex].occupiedState = message.contains("true")
            self.tableview.reloadData()
        }
    }
    
    func findDeviceParentIndexes(device: String) -> (Int, Int) {
        for (index, element) in self.deviceArray.enumerated() {
            for (index2, element2) in element.devicesOnPort.enumerated() {
                if element2.deviceID == device {
                    return (index, index2)
                }
            }
        }
        return (0, 0)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let alertController = UIAlertController(title: "Future State", message: "This will do something \(indexPath.row)", preferredStyle: .alert)
//        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//        alertController.addAction(alertAction)
//        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceArray[section].devicesOnPort.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ((self.groupDict[deviceArray[section].parentPort] ?? "nLWired") + " (" + String(deviceArray[section].devicesOnPort.count) + " devices)")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.contentView.backgroundColor = UIColorFromHex(rgbValue: 0x941100, alpha: 1)//UIColor.blue.withAlphaComponent(1)
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! as! CustomTableViewCell
        
        let text = deviceArray[indexPath.section].devicesOnPort[indexPath.row]
        
        cell.roomLabel.text = text.label
        cell.model.text = text.model + "(\(text.deviceID))"
        cell.delegate = self
        cell.deviceSN = text.deviceID
        cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        cell.Switch.setOn(self.deviceArray[indexPath.section].devicesOnPort[indexPath.row].outputState, animated: false)
        if self.deviceArray[indexPath.section].devicesOnPort[indexPath.row].hasOccupany == true {
            if self.deviceArray[indexPath.section].devicesOnPort[indexPath.row].occupiedState == true {
                cell.occPicture.image = UIImage(named: "occupied2")
            } else {
                cell.occPicture.image = UIImage(named: "vacant2")
            }
        }
        else {
            cell.occPicture.image = nil
        }
        return cell
    }
}

extension ViewController: PressSwitchDelegate {
    func didPressSwitch(deviceID: String, newState: Bool) {
        print("switch \(deviceID) goto \(newState)")
        mqtt.publish("nLight/version/2/control/device/\(deviceID)/pole/1/relay-state", withString: "{\"state\":\(newState)}", qos: .qos1, retained: false, dup: false)
    }
}

class SessionDelegate:NSObject, URLSessionDelegate
{
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        {
            print("in session delegate")
            print(challenge.protectionSpace.host)
            if(challenge.protectionSpace.host == ipAddress)
            {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
}
