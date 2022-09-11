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
        let packet : String = "a5" + dest + src + String(format:"%02X", size) + subj + payload
        let packetArray = stringToBytes(packet)
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
        var final = packet + chk1 + chk2
        if final.count <= 32 {
            final = final.padding(toLength: 32, withPad: "0", startingAt: 0)
        } else if final.count <= 64 {
            final = final.padding(toLength: 64, withPad: "0", startingAt: 0)
        } else if final.count <= 96 {
            final = final.padding(toLength: 96, withPad: "0", startingAt: 0)
        } else if final.count <= 128 {
            final = final.padding(toLength: 128, withPad: "0", startingAt: 0)
        }
        return final
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
    
    func parseStatus(packet : String) -> NlightPacketStruct {
        let length = String(getSubstring(str: packet, start: 18, end: 20))
        let l2 = Int(length, radix: 16)
        //print(length, l2!)
        let payloadEndIndex = 22 + (2 * l2!) - 26
        let parsed = NlightPacketStruct(header: String(packet.prefix(2)),
                                        dest: getSubstring(str: packet, start: 2, end: 10),
                                        source: getSubstring(str: packet, start: 10, end: 18),
                                        length: getSubstring(str: packet, start: 18, end: 20),
                                        subject: getSubstring(str: packet, start: 20, end: 22),
                                        payload: getSubstring(str: packet, start: 22, end: payloadEndIndex),
                                        ck: getSubstring(str: packet, start: payloadEndIndex, end: payloadEndIndex + 4))
        return parsed
    }
    
    func checkOutputOn(payload : String) -> Bool {
        print(payload)
        let strCheck = "1501000280"
        let length = strCheck.count
        if payload.prefix(length) == strCheck {
            return true
        }
        else {
            return false
        }
    }
    
    func getSubstring(str : String, start: Int, end: Int) -> String {
        let start = str.index(str.startIndex, offsetBy: start)
        let end = str.index(str.startIndex, offsetBy: end)
        let range = start..<end

        let mySubstring = String(str[range])
        return mySubstring.uppercased()
    }
}
