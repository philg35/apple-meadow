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

class IPConnection : NSObject, ObservableObject {
    
    override init() {
        super.init()
        
        
    }
     
    func send(nlightString : String) -> Void {
        let iv = "00000000000000000000000000000001".data(using: .hexadecimal)!
        print("iv: \(iv as NSData)")
        
        let nonceStr = "4102030405060708090a0b0c0de00f00"
              
        let key = "sensorswitch1234".data(using: .utf8)!
        print("key: \(key as NSData)")
              
//            let dataInStr = nonceStr + "a5000003fa00fb031b10790102003bee" // OFF
//        let dataInStr = nonceStr + "a5000003fa00fb031b107901010038ee"   // ON
        let dataInStr = nonceStr + nlightString
        let dataIn = dataInStr.data(using: .hexadecimal)!
        print("dataIn: \(dataIn as NSData)")
        
        guard let ciphertext = self.crypt(operation: kCCEncrypt, algorithm: kCCAlgorithmAES, options: kCCOptionPKCS7Padding, key: key, initializationVector: iv, dataIn: dataIn) else { return }
        print("cipher text: \(ciphertext as NSData)")
        
        
        let headerString = "0001000000" + "20" + "000000010000"
        let headerData = headerString.data(using: .hexadecimal)!
        print("header=", headerString.count)
        let client = TCPClient(address: "10.0.0.251", port: 5551)
        switch client.connect(timeout: 10) {
          case .success:
            switch client.send(data: headerData + ciphertext  ) {
              case .success:
                print("sent success")
                guard let dataReturnCrypt = client.read(2) else {
                    print("nothing returned??")
                    return }
                
                print("dataReturnCrypt text: \(dataReturnCrypt)")
//                    guard let plaintext = self.crypt(operation: kCCDecrypt, algorithm: kCCAlgorithmAES, options: kCCOptionPKCS7Padding, key: key, initializationVector: iv, dataIn: dataReturnCrypt) else { return }
//
//                    print("plain text: \(plaintext as NSData)")
                
                
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


