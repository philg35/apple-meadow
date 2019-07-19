//
//  Settings.swift
//  game1
//
//  Created by Philip Gross on 7/12/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let alienCategory: UInt32 = 0x1 << 1
    static let photonTorpedoCategory: UInt32 = 0x1 << 2
}

enum ZPositions {
    static let background: CGFloat = -1
    static let label: CGFloat = 0
    static let ball: CGFloat = 1
    static let colorSwitch: CGFloat = 2
}
