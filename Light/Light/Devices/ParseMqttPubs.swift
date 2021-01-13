//
//  ParseMqttPubs.swift
//  Light
//
//  Created by Philip Gross on 1/11/21.
//

import Foundation

struct RelayPost: Codable, Hashable, Identifiable {
    var id: Int?
    let relaystate : Bool?
    let ts: String?
}
