//
//  ContentView.swift
//  RNCrypter_test
//
//  Created by Philip Gross on 9/3/22.
//

import SwiftUI
import RNCryptor

let encryptionKey = "sensorswitch1234"
//let keyStr = "sensorswitch1234"
//let key = keyStr.data(using: .utf8)!
//print("key: \(key as NSData)")
//print("key count=", key.count)
      
let dataInStr = "4102030405060708090a0b0c0de00f00a5000003fa00fb031b10790102003bee"
//let dataIn = dataInStr.data(using: .hexadecimal)!
//print("dataIn: \(dataIn as NSData)")

struct ContentView: View {
    
    @StateObject var myEnc = RNCryptClass()
    
    var body: some View {
        VStack {
            Text("RNCryptor Test")
                    .padding()
            Button(action: {
                let result : String = myEnc.encrypt(plaintext: dataInStr, key: encryptionKey)
                print("result=", result)
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
