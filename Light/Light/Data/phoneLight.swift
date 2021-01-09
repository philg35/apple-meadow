//
//  phoneLight.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import Foundation

struct PhoneLight: Hashable, Codable, Identifiable {
    var id: Int
    var deviceName: String
    var productName: String
    var imageName: String
    var occState: Bool
    var outputState: Bool
    var level: UInt
    var hasOcc: Bool
    var hasOutput: Bool
    var deviceId: String
    var mqttPubs: [String]
    
    
    init(id: Int, deviceId: String, deviceName: String, productName: String, imageName: String, occState: Bool, outputState: Bool, level: UInt, hasOcc: Bool, hasOutput: Bool, mqttPubs: [String]) {
            
        self.id = id
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.productName = productName
        self.imageName = imageName
        self.occState = occState
        self.outputState = outputState
        self.level = level
        self.hasOcc = hasOcc
        self.hasOutput = hasOutput
        self.mqttPubs = mqttPubs
    }
}
