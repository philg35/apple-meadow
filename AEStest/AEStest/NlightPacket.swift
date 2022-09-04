//
//  NlightPacket.swift
//  AEStest
//
//  Created by Philip Gross on 9/3/22.
//

import UIKit

class NlightPacket: NSObject {
    
    
    func CreatePacket(dest: String, src: String, subj: String, payload: String) -> String {
        let size = 13 + (payload.count / 2)
        print("size", size)
        let packet : String = "a5" + dest + src + String(format:"%02X", size) + subj + payload
        let packetArray = stringToBytes(packet)
        print("packetArray=", packetArray!)
        var itemsAtEvenIndices = [Int]()
        var itemsAtOddIndices = [Int]()

        for (index, item) in packetArray!.enumerated() {
          if index.isMultiple(of: 2) {
              itemsAtEvenIndices.append(Int(item))
          } else {
              itemsAtOddIndices.append(Int(item))
          }
        }
        let ck1 = ~itemsAtEvenIndices.reduce(0, {$0^$1})
        let ck2 = ~itemsAtOddIndices.reduce(0, {$0^$1})
        let chk1 = String(format:"%02X", ck1).suffix(2)
        let chk2 = String(format:"%02X", ck2).suffix(2)
        print("odd=", itemsAtOddIndices, String(format:"%02X", ck1).suffix(2))
        print("even=", itemsAtEvenIndices, String(format:"%02X", ck2).suffix(2))
        return packet + chk1 + chk2
    }
    
    func toPairsOfChars(pairs: [String], string: String) -> [String] {
        if string.count == 0 {
            return pairs
        }
        var pairsMod = pairs
        pairsMod.append(String(string.prefix(2)))
        return toPairsOfChars(pairs: pairsMod, string: String(string.dropFirst(2)))
    }

    func stringToBytes(_ string: String) -> [UInt8]? {
        // omit error checking: remove '0x', make sure even, valid chars
        let pairs = toPairsOfChars(pairs: [], string: string)
        return pairs.map { UInt8($0, radix: 16)! }
    }
    
}
