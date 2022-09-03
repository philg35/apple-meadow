//
//  ContentView.swift
//  AEStest
//
//  Created by Philip Gross on 8/27/22.
//

import SwiftUI
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

struct ContentView: View {
    @StateObject var ipConn = IPConnection()
    
    
    var body: some View {
        VStack {
        Text("AES test")
            .padding()
        Button(action: {
           
            
            let iv = "00000000000000000000000000000001".data(using: .hexadecimal)!
            print("iv: \(iv as NSData)")
            
            let nonceStr = "4102030405060708090a0b0c0de00f00"
                  
            let key = "sensorswitch1234".data(using: .utf8)!
            print("key: \(key as NSData)")
                  
//            let dataInStr = nonceStr + "a5000003fa00fb031b10790102003bee" // OFF
            let dataInStr = nonceStr + "a5000003fa00fb031b107901010038ee"   // ON
            let dataIn = dataInStr.data(using: .hexadecimal)!
            print("dataIn: \(dataIn as NSData)")
            
            guard let ciphertext = ipConn.crypt(operation: kCCEncrypt, algorithm: kCCAlgorithmAES, options: kCCOptionPKCS7Padding, key: key, initializationVector: iv, dataIn: dataIn) else { return }
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
//                    guard let plaintext = ipConn.crypt(operation: kCCDecrypt, algorithm: kCCAlgorithmAES, options: kCCOptionPKCS7Padding, key: key, initializationVector: iv, dataIn: dataReturnCrypt) else { return }
//
//                    print("plain text: \(plaintext as NSData)")
                    
                    
                  case .failure(let error):
                    print(error)
                }
              case .failure(let error):
                print(error)
            }
            
        }) {
            Text("Go")
        }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



