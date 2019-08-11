//
//  ViewController.swift
//  mqttProject2
//
//  Created by Philip Gross on 8/8/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit
import Moscapsule

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Note that you must initialize framework only once after launch application
        // in case that it uses SSL/TLS functions.
        moscapsule_init()
        
        let mqttConfig = MQTTConfig(clientId: "tester", host: "10.0.0.251", port: 8883, keepAlive: 60)
        
        mqttConfig.onConnectCallback = { returnCode in
            NSLog("Return Code is \(returnCode.description)")
        }
        mqttConfig.onMessageCallback = { mqttMessage in
            NSLog("MQTT Message received: payload=\(String(describing: mqttMessage.payloadString))")
        }
        
        //let certFile = "certBBD465.pem"
        let certFile = "caCertificate.crt"
        
        mqttConfig.mqttServerCert = MQTTServerCert(cafile: certFile, capath: nil)
        
        let mqttClient = MQTT.newConnection(mqttConfig)
        
        mqttClient.subscribe("#", qos: 2)
    }

    

}

