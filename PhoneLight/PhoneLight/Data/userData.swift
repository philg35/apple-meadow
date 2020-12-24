//
//  userData.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import Foundation
import SwiftUI
import Combine

class UserData : ObservableObject {
    @Published var phoneLight = phoneLightData
    
    func loadData() {
        let xml = GetXml()
        xml.read()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 2.0 seconds
            var index = 0
            for p in xml.deviceArray {
                print("parent", p.parentName)
                for d in p.devicesOnPort {
                    print("device", d.label, index)
                    
                    self.phoneLight.append(PhoneLight(id: index, deviceName: d.label, productName: d.model, imageName: "none", occState: false, outputState: false, level: 100))
                    index += 1
                }
            }
        }
    }
}
