//
//  RNCryptClass.swift
//  RNCrypter_test
//
//  Created by Philip Gross on 9/3/22.
//

import UIKit
import RNCryptor

class RNCryptClass: NSObject, ObservableObject {
    
    func encrypt(plaintext: String, key: String) -> String {
        let data : Data = plaintext.data(using: .utf8)!
        let encryptedData = RNCryptor.encrypt(data: data, withPassword: key)
        print("encryptedData=", encryptedData)
        let encryptedString : String = encryptedData.base64EncodedString()
        return encryptedString
    }
}
