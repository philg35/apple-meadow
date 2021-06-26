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
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    
        override init() {
            super.init()
     
            myCentral = CBCentralManager(delegate: self, queue: nil)
            myCentral.delegate = self
        }


    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         if central.state == .poweredOn {
             isSwitchedOn = true
         }
         else {
             isSwitchedOn = false
         }
    }


    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var peripheralName: String!
        var peripheralManufData: String = "not"
        //peripheralManufData = "not"
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            peripheralName = name
        }
        else {
            peripheralName = "Unknown"
        }
       
//        if let txPower = advertisementData[CBAdvertisementDataManufacturerDataKey] as? String {
//            peripheralTxPower = txPower
//        }
//        else {
//            peripheralTxPower = "-99"
//        }
//        print("tx power", peripheralTxPower!)
        
        
//        for ad in advertisementData {
//            if ad.key == "kCBAdvDataManufacturerData"
//            {
//                print(ad.value, peripheralName ?? "none")
//
//            }
////            if ad.key == "kCBAdvDataTxPowerLevel"
////            {
////                peripheralTxPower = ad.value as? String
////                print("tx power", ad.value, peripheralName ?? "none")
////            }
//        }
        
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            //assert(manufacturerData.count >= 7)
            //0d00 - TI manufacturer ID
            //Constructing 2-byte data as little endian (as TI's manufacturer ID is 000D)
            if manufacturerData.count == 20
            {
                print("NLAIR", manufacturerData[0], manufacturerData[1], manufacturerData[2], manufacturerData[3], manufacturerData[4], manufacturerData[5], manufacturerData[6], manufacturerData[7], manufacturerData[8], manufacturerData[9], manufacturerData[10], manufacturerData[11], manufacturerData[12], manufacturerData[13], manufacturerData[14], manufacturerData[15], manufacturerData[16], manufacturerData[17], manufacturerData[18], manufacturerData[19])
                
            let manufactureID = UInt16(manufacturerData[0]) + UInt16(manufacturerData[1]) << 8
            print(String(format: "%04X", manufactureID))
            let nodeID = manufacturerData[2]
            print(String(format: "%02X", nodeID)) 
//            let state = manufacturerData[3]
//            print(String(format: "%02X", state)) //->05
//            //c6f - is the sensor tag battery voltage
//            //Constructing 2-byte data as big endian (as shown in the Java code)
//            let batteryVoltage = UInt16(manufacturerData[4]) << 8 + UInt16(manufacturerData[5])
//            print(String(format: "%04X", batteryVoltage)) //->0C6F
//            //32- is the BLE packet counter.
//            let packetCounter = manufacturerData[6]
//            print(String(format: "%02X", packetCounter)) //->32
            print("manufData", manufacturerData)
            peripheralManufData = String(manufactureID)
        }
        }
        
    
    
        let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, manufData: peripheralManufData)
        //print(newPeripheral)
        peripherals.append(newPeripheral)
        peripherals.sort(by: { $0.rssi > $1.rssi})
    }
    
    func startScanning() {
         print("startScanning")
         myCentral.scanForPeripherals(withServices: nil, options: nil)
     }
    
    func stopScanning() {
        print("stopScanning")
        myCentral.stopScan()
    }
    
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

