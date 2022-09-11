//
//  NlightPacketStruct.swift
//  AEStest
//
//  Created by Philip Gross on 9/8/22.
//

import Foundation

struct NlightPacketStruct: Hashable, Codable {
    var header: String?
    var dest: String
    var source: String
    var length: String
    var subject: String
    var payload: String
    var ck: String?
    
    
    init(header: String, dest: String, source: String, length: String, subject: String, payload: String, ck: String) {
            
        self.header = header
        self.dest = dest
        self.source = source
        self.length = length
        self.subject = subject
        self.payload = payload
        self.ck = ck
    }
}
