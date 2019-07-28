//
//  WinScene.swift
//  jumperGame
//
//  Created by Philip Gross on 7/27/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit

class WinScene: SKScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        print("got here!")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
}
