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
    var level: Int
    var hasOcc: Bool
    var hasOutput: Bool
    var deviceId: String
    var mqttPubs: [RelayPost]
    var onTime: [String: Float]
    var hasDim: Bool
    var stateReason: String
    
    
    init(id: Int, deviceId: String, deviceName: String, productName: String, imageName: String, occState: Bool, outputState: Bool, level: Int, hasOcc: Bool, hasOutput: Bool, mqttPubs: [RelayPost], onTime: [String: Float], hasDim: Bool, stateReason: String) {
            
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
        self.onTime = onTime
        self.hasDim = hasDim
        self.stateReason = stateReason
    }
}
