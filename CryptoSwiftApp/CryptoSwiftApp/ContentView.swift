//
//  ContentView.swift
//  CryptoSwiftApp
//
//  Created by Philip Gross on 9/3/22.
//

import SwiftUI
import CryptoSwift

struct ContentView: View {
    var body: some View {
        
        let encryptionKey = "sensorswitch1234"
        //let keyStr = "sensorswitch1234"
        //let key = keyStr.data(using: .utf8)!
        //print("key: \(key as NSData)")
        //print("key count=", key.count)
              
        let dataInStr = "4102030405060708090a0b0c0de00f00a5000003fa00fb031b10790102003bee"
        
        VStack {
        Text("CryptoSwift Example")
            .padding()
            Button(action: {
                
                let iv: Array<UInt8> = [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]

                let dataInStrArray: [UInt8] = Array(dataInStr.utf8)
                print(dataInStrArray, dataInStrArray.count)
                let encryptionKeyArray: [UInt8] = Array(encryptionKey.utf8)
                print(encryptionKeyArray, encryptionKeyArray.count)
                
                do {
                    let encrypted = try AES(key: encryptionKeyArray, blockMode: CBC(iv: iv), padding: .pkcs7).encrypt(dataInStrArray)
                    let decrypted = try AES(key: encryptionKeyArray, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(encrypted)
                    print("encrypt=", encrypted, encrypted.count)
                    print("decrypt=", decrypted, decrypted.count)
                    
                    if let string = String(bytes: decrypted, encoding: .utf8) {
                        print(string)
                    } else {
                        print("not a valid UTF-8 sequence")
                    }
                } catch {
                    print(error)
                }
                
                
                
                
                print("something done")
                
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
