//
//  IPConnection.swift
//  AEStest
//
//  Created by Philip Gross on 8/27/22.
//

import Foundation
import CommonCrypto
import SwiftSocket

extension String {
    enum ExtendedEncoding {
        case hexadecimal
    }

    func data(using encoding:ExtendedEncoding) -> Data? {
        let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

        guard hexStr.count % 2 == 0 else { return nil }

        var newData = Data(capacity: hexStr.count/2)

        var indexIsEven = true
        for i in hexStr.indices {
            if indexIsEven {
                let byteRange = i...hexStr.index(after: i)
                guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
                newData.append(byte)
            }
            indexIsEven.toggle()
        }
        return newData
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class IPConnection : NSObject, ObservableObject {
    
    var ipaddress : String
    
    init(ipaddress: String) {
        self.ipaddress = ipaddress
    }
    
    
    func send(nlightString : String) -> Void {
//        let iv = "00000000000000000000000000000000".data(using: .hexadecimal)!
        let iv = "00".data(using: .hexadecimal)!
        //print("iv: \(iv as NSData)")
        
        let nonceStr = "4102030405060708090a0b0c0de00f00"
        
        let key = "sensorswitch1234".data(using: .utf8)!
        //print("key: \(key as NSData)")
        
        let dataInStr = nonceStr + nlightString
        let packetLength = dataInStr.count / 2
        let packetLengthMod = packetLength
        
        let packetLengthString = String(format:"%02X", packetLengthMod)
        let dataIn = dataInStr.data(using: .hexadecimal)!
//        print("dataIn=", dataIn)
        guard let ciphertext = self.crypt(operation: kCCEncrypt, algorithm: kCCAlgorithmAES, options: kCCOptionPKCS7Padding, key: key, initializationVector: iv, dataIn: dataIn) else { return }
        
        let headerString = "0001000000" + packetLengthString + "000000010000"
        let headerData = headerString.data(using: .hexadecimal)!
        let client = TCPClient(address: self.ipaddress, port: 5551)
        switch client.connect(timeout: 10) {
        case .success:
            switch client.send(data: headerData + ciphertext  ) {
            case .success:
                guard let dataReturnCrypt = client.read(100, timeout: 1) else {
                    print("nothing returned??")
                    return }
                
//                print("dataReturnCrypt text: \(dataReturnCrypt)")
                let packetOnly = dataReturnCrypt[11...]
//                print("packetOnly=", packetOnly)
                guard let plaintext = self.crypt(operation: kCCDecrypt, algorithm: kCCAlgorithmAES, options: kCCOptionPKCS7Padding, key: key, initializationVector: iv, dataIn: Data(packetOnly)) else { return }
                
                let str = plaintext.hexEncodedString()
                let index = str.index(str.startIndex, offsetBy: 32)
                print("response =", str.suffix(from: index))
                      
            case .failure(let error):
                print(error)
            }
        case .failure(let error):
            print(error)
        }
    }
    
    func crypt(operation: Int, algorithm: Int, options: Int, key: Data,
               initializationVector: Data, dataIn: Data) -> Data? {
        return key.withUnsafeBytes { keyUnsafeRawBufferPointer in
            return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
                    // Give the data out some breathing room for PKCS7's padding.
                    let dataOutSize: Int = dataIn.count + kCCBlockSizeAES128*2
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize,
                                                                   alignment: 1)
                    defer { dataOut.deallocate() }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(CCOperation(operation), CCAlgorithm(algorithm),
                                         CCOptions(options),
                                         keyUnsafeRawBufferPointer.baseAddress, key.count,
                                         ivUnsafeRawBufferPointer.baseAddress,
                                         dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                                         dataOut, dataOutSize, &dataOutMoved)
                    guard status == kCCSuccess else { return nil }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }
    
    func randomGenerateBytes(count: Int) -> Data? {
        let bytes = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
        defer { bytes.deallocate() }
        let status = CCRandomGenerateBytes(bytes, count)
        guard status == kCCSuccess else { return nil }
        return Data(bytes: bytes, count: count)
    }
    
    
}


