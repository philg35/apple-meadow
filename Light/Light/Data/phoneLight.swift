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
    fileprivate var imageName: String
    var occState: Bool
    var outputState: Bool
    var level: UInt
    
    init(id: Int, deviceName: String, productName: String, imageName: String, occState: Bool, outputState: Bool, level: UInt) {
        self.id = id
        self.deviceName = deviceName
        self.productName = productName
        self.imageName = imageName
        self.occState = occState
        self.outputState = outputState
        self.level = level
    }
}
