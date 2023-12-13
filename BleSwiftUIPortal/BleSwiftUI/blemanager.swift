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
    var readOutput: String
    var lcOfInterest: String
}

let temperatureMeasurementCBUUID = CBUUID(string: "2A1C")

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
        let exampleUuid = [CBUUID(string: "d2d8cd40-6b76-41eb-a60e-b8d62a9a5fb0")]
        let testString = hexStringtoAscii("551e3d570a07")
        print("test=", testString)
        let advertisementData = [CBAdvertisementDataLocalNameKey: testString, CBAdvertisementDataServiceUUIDsKey: exampleUuid] as [String : Any] as [String : Any]
        myPerif.startAdvertising(advertisementData)
    }
}

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var peripherals = [Peripheral]()
    var isLocalConnOnly : Bool = true
    var conn_periph : CBPeripheral!
    @Published public var global = Params.global
    
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
        conn_periph = peripheral
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
                peripherals[perifIndex].characteristicList += characteristic.uuid.uuidString.prefix(8) + ", "
                if (!characteristic.isNotifying) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let cVal = characteristic.value else {
            return
        }
        let stringFromData = String(data: cVal, encoding: String.Encoding.ascii)
        let uuid = characteristic.uuid.uuidString.prefix(8)
        var perifIndex: Int {
            peripherals.firstIndex(where: { $0.cbperiph == peripheral}) ?? 0
        }
        let hexString = characteristic.value?.hexEncodedString() ?? ""
        let asciiString = stringFromData ?? ""
        let outString = "\(uuid) = \(asciiString), \(hexString)"
        print(outString)
        peripherals[perifIndex].readOutput += outString + ", \r\n"
        
        switch (uuid){
        case "B0730002":
            global.portalName = asciiString
            break
        case "B073000B":
            global.zoneOfInterest = asciiString
            break
        case "B073000E":
            global.lastPressed = hexString[0..<8]
            let typeSeen = hexString[8..<12]
            var typeString = "???"
            switch (typeSeen) {
            case "0001":
                typeString = "occ"
                break
            case "0002":
                typeString = "pcell"
                break
            case "0003":
                typeString = "occpcell"
                break
            case "0004":
                typeString = "switch"
                break
            case "0005":
                typeString = "occswitch"
                break
            case "0006":
                typeString = "pcswitch"
                break
            case "0007":
                typeString = "occpcsw"
                break
            default:
                break
            }
            global.lastType = typeString
            break
        case "B0730013":
            print("length=", hexString.count, hexString.count/4)
            let components = hexString.components(withLength: 52)
            global.lcList = []
            for x in components {
                let lc = x[0..<8]
                print("lc = ", lc)
                global.lcList.append(lc)
            }
            break
        case "674F0002":
            global.lcOfInterest = hexString
            break
        case "674F0003":
            global.lcData = hexString
            break
            
        default:
            break
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (characteristic.isNotifying)
        {
            print("didUpdateNotificationStateFor ", characteristic.uuid.uuidString)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let services = peripheral.services {
            var perifIndex: Int {
                peripherals.firstIndex(where: { $0.cbperiph == peripheral}) ?? 0
            }
            for service in services {
                print("service=", service)
                peripherals[perifIndex].serviceList += service.uuid.uuidString.prefix(8) + ", "
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
        
        if let list = advertisementData["kCBAdvDataServiceUUIDs"] as? [AnyObject], (list.contains { ($0 as? CBUUID)?.uuidString == "B0730001-6604-4CA1-A5A4-98864F059E4A" }) {
            print("Found new portal.")
            isLocalConnect = true
        }
        
        if (isLocalConnect || !isLocalConnOnly) {
            let newPeripheral = Peripheral(id: peripherals.count, name: peripheralName, rssi: RSSI.intValue, cbperiph: peripheral, serviceList: "", characteristicList: "", reading: 0, readOutput: "", lcOfInterest: "")
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
    
    func readCharacteristicFromString(charString: String) -> Void {
        for s in conn_periph?.services ?? [] {
            //print("s=", s)
            for c in s.characteristics ?? [] {
                if c.uuid.uuidString == charString {
                    print("found char again...")
                    conn_periph.readValue(for: c)
                    break
                }
            }
        }
    }
    
    func writeCharacteristicFromString(charString: String, textString: String) -> Void {
        for s in conn_periph?.services ?? [] {
            //print("s=", s)
            for c in s.characteristics ?? [] {
                if c.uuid.uuidString == charString {
                    print("found char again...")
                    conn_periph.writeValue((textString.data(using: .utf8) ?? "".data(using: .utf8))!, for: c, type: .withoutResponse)
                    break
                }
            }
        }
    }
    
    func writeCharacteristicFromHexString(charString: String, hexString: String) -> Void {
        for s in conn_periph?.services ?? [] {
            for c in s.characteristics ?? [] {
                if c.uuid.uuidString == charString {
                    print("found char again...")
                    let hexdata = hexString.hexaData
                    let hexbytes = hexString.hexaBytes
                    print("hexbytes = ", hexbytes)
                    conn_periph.writeValue(Data(hexbytes), for: c, type: .withoutResponse)
                    break
                }
            }
        }
    }
    
    func writeCharacteristicFromInt8(charString: String, payload: UInt8) -> Void {
        for s in conn_periph?.services ?? [] {
            //print("s=", s)
            for c in s.characteristics ?? [] {
                if c.uuid.uuidString == charString {
                    print("found char again...")
                    conn_periph.writeValue(Data([payload]), for: c, type: .withoutResponse)
                    break
                }
            }
        }
    }
    
    func writeCharacteristicFromInt32(charString: String, payload: UInt32) -> Void {
        for s in conn_periph?.services ?? [] {
            //print("s=", s)
            for c in s.characteristics ?? [] {
                if c.uuid.uuidString == charString {
                    print("found char again...")
                    var u32BE = payload.bigEndian // or simply value
                    let dataBE = Data(bytes: &u32BE, count: 4)
                    conn_periph.writeValue(dataBE, for: c, type: .withoutResponse)
                    break
                }
            }
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

func hexStringtoAscii(_ hexString : String) -> String {
    
    let pattern = "(0x)?([0-9a-f]{2})"
    let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    let nsString = hexString as NSString
    let matches = regex.matches(in: hexString, options: [], range: NSMakeRange(0, nsString.length))
    let characters = matches.map {
        Character(UnicodeScalar(UInt32(nsString.substring(with: $0.range(at: 2)), radix: 16)!)!)
    }
    return String(characters)
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
}

extension String {
    func components(withLength length: Int) -> [String] {
        return stride(from: 0, to: count, by: length).map {
            let start = index(startIndex, offsetBy: $0)
            let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
}

extension StringProtocol {
    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
