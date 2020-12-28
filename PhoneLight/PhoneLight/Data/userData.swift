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
    let xml = GetXml()
    typealias FinishedXmlRead = () -> ()
    
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

                self.phoneLight.append(PhoneLight(id: index, deviceName: d.label, productName: d.model, imageName: "none", occState: false, outputState: false, level: 100))
                index += 1
            }
        }
    }

    func loadData() {
        readXmlAndCreateList { () -> () in
            createDeviceList()
        }
    }
}
