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
    let manufData: String
    let cbperiph: CBPeripheral
    var serviceList: String
    var characteristicList: String
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
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device", CBAdvertisementDataServiceUUIDsKey: "1804"]
        myPerif.startAdvertising(advertisementData)
    }
    
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    
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
            peripherals[perifIndex].characteristicList += characteristic.uuid.uuidString + ", "
          }
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
            peripherals[perifIndex].serviceList += service.uuid.uuidString + ", "
            peripheral.discoverCharacteristics(nil, for: service)
          }
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        var peripheralManufData: String = "not"
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
        
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            if manufacturerData.count == 20
            {
                print("NLAIR", manufacturerData[0], manufacturerData[1], manufacturerData[2], manufacturerData[3], manufacturerData[4], manufacturerData[5], manufacturerData[6], manufacturerData[7], manufacturerData[8], manufacturerData[9], manufacturerData[10], manufacturerData[11], manufacturerData[12], manufacturerData[13], manufacturerData[14], manufacturerData[15], manufacturerData[16], manufacturerData[17], manufacturerData[18], manufacturerData[19])
                
            let manufactureID = UInt16(manufacturerData[3]) + UInt16(manufacturerData[2]) << 8
            print(String(format: "%04X", manufactureID))
            
//            print("manufData", manufacturerData)
            peripheralManufData = String(manufactureID)
            }
        }
    
    
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, manufData: peripheralManufData, cbperiph: peripheral, serviceList: "", characteristicList: "")
        peripherals.append(newPeripheral)
        peripherals.sort(by: { $0.rssi > $1.rssi})
//        myCentral.connect(peripheral, options: nil)
        
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
    
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

