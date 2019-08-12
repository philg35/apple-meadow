//
//  ViewController.swift
//  tableviewSwift
//
//  Created by Philip Gross on 3/20/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet var labelMqtt: UILabel!

    @IBAction func OnButtonPressed(_ sender: Any) {
        mqtt.publish("nLight/version/2/status/device/00000020/pole/1/relay-state", withString: "{\"state\":true}", qos: .qos1, retained: false, dup: false)
    }
    
    @IBAction func OffButtonPressed(_ sender: Any) {
        mqtt.publish("nLight/version/2/status/device/00000020/pole/1/relay-state", withString: "{\"state\":false}", qos: .qos1, retained: false, dup: false)
    }
    
    @IBOutlet weak var textView: UITextView!
    
    private var rooms: [String] = []
    var mqtt: CocoaMQTT!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rooms.append("Kitchen Table")
        rooms.append("Kitchen Island")
        rooms.append("Living Room")
        rooms.append("Mudroom")
        
        tableview.dataSource = self
        tableview.delegate = self
        
        setUpMQTT()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertController = UIAlertController(title: "Hint", message: "You have selected \(indexPath.row)", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! as! CustomTableViewCell
        
        let text = rooms[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor.white
        }
        else {
            cell.contentView.backgroundColor = UIColor.lightGray
        }
        cell.RoomLabel.text = text
        return cell
    }
    
    
    func setUpMQTT() {
        let clientID = "CocoaMQTT-" //+ String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "10.0.0.251", port: 8883)
        mqtt.username = ""
        mqtt.password = ""
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 60
        mqtt.enableSSL = true
        
        //let clientCertArray = NSArray(contentsOfFile: "certBBD465.pem")
        let clientCertArray = NSArray(contentsOfFile: "caCertificate.crt")
        
        var sslSettings: [String: NSObject] = [:]
        sslSettings[kCFStreamSSLCertificates as String] = clientCertArray
        
        mqtt!.sslSettings = sslSettings
        
        //mqtt.allowUntrustCACertificate = true
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
        print(message.topic, message.string as Any)
        if let msgString = message.string {
            textView.text?.append(message.topic + " = " + msgString)
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
}
