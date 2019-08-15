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
    @IBOutlet weak var ipAddressField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var textview: UITextView!
    
    struct PortDevices
    {
        var parentPort: String
        var parentName: String
        var devicesOnPort: [DevXml]
    }
    
    var pickerData: [String] = [String]()
    var mqtt: CocoaMQTT!
    private var parentList: [String] = []
    private var deviceArray: [PortDevices] = []
    private var groupLabels: [DevXml] = []
    private var groupDict: [String : String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.ipAddressField.delegate = self
        
        //read in saved ip addresses
        let defaults = UserDefaults.standard
        pickerData = defaults.stringArray(forKey: "pickerData") ?? [String]()
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        ipAddress = pickerData[selectedValue]
        doXmlRead()
        //setUpMQTT()
    }
    
    @IBAction func removePressed(_ sender: Any) {
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        print("selected", selectedValue)
        pickerData.remove(at: selectedValue)
        self.pickerView.reloadAllComponents()
        savePickerData()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        print("selected", selectedValue)
        ipAddress = pickerData[selectedValue]
        doXmlRead()
    }
    
    @IBAction func addPressed(_ sender: Any) {
        if ipAddressField.endEditing(false) {
            print("ending editting, button pressed")
            ipAddress = ipAddressField.text ?? "10.0.0.251"
            if !pickerData.contains(ipAddress) {
                print("add it")
                pickerData.append(ipAddress)
                pickerData.sort()
                self.pickerView.reloadAllComponents()
            }
            savePickerData()
        }
        else {
            print("button pressed")
        }
        doXmlRead()
    }
    
    func doXmlRead() {
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
            
            // determine groupLabel dictionary
            for group in self.groupLabels {
                self.groupDict[group.parentPort] = group.groupLabel
            }
            
            // add in parentName (now that groupLabels dictionary is set
            for index in 0...(self.deviceArray.count - 1) {
                self.deviceArray[index].parentName = self.groupDict[self.deviceArray[index].parentPort] ?? "none"
            }
            
            // sort sections by parentName
            self.deviceArray.sort { $0.parentName < $1.parentName}
            
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
    
    func savePickerData() {
        //save ip addresses
        let defaults = UserDefaults.standard
        defaults.set(pickerData, forKey: "pickerData")
    }
    
    func setUpMQTT() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "10.0.0.251", port: 8883)
        mqtt.username = ""
        mqtt.password = ""
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 60
        mqtt.enableSSL = true
        
//        let clientCertArray = NSArray(contentsOfFile: "caCertificate.crt")
//
//        var sslSettings: [String: NSObject] = [:]
//        sslSettings[kCFStreamSSLCertificates as String] = clientCertArray
//
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
            textview.text?.append(message.topic + " = " + msgString)
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
        print("got error")
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
        
        let alertController = UIAlertController(title: "Future State", message: "This will do something \(indexPath.row)", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
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
        header.backgroundView?.backgroundColor = UIColor.blue.withAlphaComponent(1)
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
        return cell
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print(pickerData[row], row, component)
        ipAddress = pickerData[row]
        doXmlRead()
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("done editing")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("began editing")
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
