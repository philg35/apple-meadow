//
//  DeviceDataStruct.swift
//  AEStest
//
//  Created by Philip Gross on 9/6/22.
//

import Foundation

struct DeviceDataStruct: Hashable, Codable, Identifiable {
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
    var hasDim: Bool
    var stateReason: String
    
    
    init(id: Int, deviceId: String, deviceName: String, productName: String, imageName: String, occState: Bool, outputState: Bool, level: Int, hasOcc: Bool, hasOutput: Bool, hasDim: Bool, stateReason: String) {
            
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
        self.hasDim = hasDim
        self.stateReason = stateReason
    }
}
