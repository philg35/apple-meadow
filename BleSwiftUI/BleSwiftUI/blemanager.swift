//
//  blemanager.swift
//  BleSwiftUI
//
//  Created by Philip Gross on 6/26/21.
//  Copyright © 2021 Philip Gross. All rights reserved.
//


import Foundation
import CoreBluetooth

struct Peripheral: Identifiable {
    let id: Int
    let name: String
    let rssi: Int
    let cbperiph: CBPeripheral
    var serviceList: String
    var characteristicList: String
    var reading: UInt32
}

class BLEPerifManager : NSObject, ObservableObject, CBPeripheralManagerDelegate {
    var myPerif: CBPeripheralManager!
    
    
    override init() {
        super.init()
 
        myPerif = CBPeripheralManager(delegate: self, queue: nil)
        myPerif.delegate = self
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("periph state", peripheral.state.rawValue)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("started advertising")
    }
    
    func startAdvertising()
    {
        let exampleUuid = [CBUUID(string: "879D048E-E0AA-4CA2-B686-F3B4B0E67A93")]
        let advertisementData = [CBAdvertisementDataLocalNameKey: "DELC", CBAdvertisementDataServiceUUIDsKey: exampleUuid] as [String : Any] as [String : Any]
        myPerif.startAdvertising(advertisementData)
    }
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    var isLocalConnOnly : Bool = true
        override init() {
            super.init()
     
            myCentral = CBCentralManager(delegate: self, queue: nil)
            myCentral.delegate = self
        }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("central state=", central.state.rawValue)
        if central.state == .poweredOn {
            print("powered on")
             isSwitchedOn = true
         }
         else {
            print("not powered on")
             isSwitchedOn = false
         }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error ?? "no errors")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

       if let charac = service.characteristics {
        var perifIndex: Int {
            peripherals.firstIndex(where: { $0.cbperiph == peripheral}) ?? 0
        }
        for characteristic in charac {
            print(characteristic)
            peripherals[perifIndex].characteristicList += characteristic.uuid.uuidString + ", \r\n"
            if (characteristic.uuid.uuidString == "2A1C") {
                print("*****found health temperature char*****")
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
          }
        }
      }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Characteristic read: \(characteristic)\n ")
        
        if let charData = characteristic.value(forKey: "value") as? Data {
            let reading = (UInt32(charData[2]) * 256 + UInt32(charData[1])) / 1000
            print(reading)
            for p in peripherals {
                if p.cbperiph == peripheral {
                    print("found peripheral to put data in, index=\(p.id), data= \(reading)")
                    peripherals[p.id].reading = reading
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            print("didUpdateNotificationStateFor", characteristic)
            if error == nil {
                print("TRUE")
                
            }
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

           if let services = peripheral.services {
            var perifIndex: Int {
                peripherals.firstIndex(where: { $0.cbperiph == peripheral}) ?? 0
            }
           //discover characteristics of services
           for service in services {
            print("service=", service)
            peripherals[perifIndex].serviceList += service.uuid.uuidString + ", \r\n"
            peripheral.discoverCharacteristics(nil, for: service)
          }
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
        var isLocalConnect = false
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            if manufacturerData[0] == 0x46 && manufacturerData[1] == 0x03 && manufacturerData[2] == 0x20 {
                isLocalConnect = true
//                for (index, element) in manufacturerData.enumerated() {
//                    let hexValue = String(element, radix: 16)
//                  print("Item \(index): \(hexValue)")
//                }
            
                let org_id_slice = manufacturerData[3...8]
                let org_id = Array(org_id_slice)
                print("org_id=", org_id)
                
                let asset_id_slice = manufacturerData[9...14]
                let asset_id = Array(asset_id_slice)
                print("asset_id=", asset_id)
            }
        }
    
        if (isLocalConnect || !isLocalConnOnly) {
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, cbperiph: peripheral, serviceList: "", characteristicList: "", reading: 0)
            peripherals.append(newPeripheral)
            peripherals.sort(by: { $0.rssi > $1.rssi})
        }
    }
    
    func startScanning() {
         print("startScanning")
         myCentral.scanForPeripherals(withServices: nil, options: nil)
     }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }
    
    func connect(periphConn : Peripheral) {
        periphConn.cbperiph.delegate = self
        print("connect detail")
        myCentral.connect(periphConn.cbperiph, options: nil)
        print("after connect detail")
    }
    
    func disconnect(periphConn : Peripheral) {
        myCentral.cancelPeripheralConnection(periphConn.cbperiph)
    }
    
    func read(periphConn : Peripheral) {
        //periphConn.cbperiph.readValue(for: 0x2a1c)
    }
    
    func isLocalConnChange(newValue: Bool){
        isLocalConnOnly = newValue
    }
    
    func clearScan() {
        peripherals.removeAll()
    }
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

