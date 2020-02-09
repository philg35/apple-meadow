//
//  WinScene.swift
//  jumperGame
//
//  Created by Philip Gross on 7/27/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit
import GameplayKit

class WinScene: SKScene {
    var startDateTime: TimeInterval!
    var allowTouchToExit : Bool!
    var level : Int = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        print("got here!")
        startDateTime = Date().timeIntervalSinceReferenceDate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var fileName : String!
        if allowTouchToExit == true {
            level = UserDefaults.standard.integer(forKey: "Level")
            level += 1
            UserDefaults.standard.set(level, forKey: "Level")
            print("touches began, level=", level)
            
            if level == 2 {
                fileName = "GameScene2"
            }
            else if level == 3 {
                fileName = "GameScene3"
            }
            else {
                fileName = "GameScene"
            }
            

            // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
            // including entities and graphs.
            guard let scene = GKScene(fileNamed: fileName) else {
                return
            }

            guard let sceneNode = scene.rootNode as? GameScene ?? GameScene(fileNamed: fileName) else {
                return
            }

            // Copy gameplay related content over to the scene
            sceneNode.entities = scene.entities
            //sceneNode.graphs = scene.graphs

            // Set the scale mode to scale to fit the window
            sceneNode.scaleMode = .aspectFill

            // Present the scene
            if let view = self.view as! SKView? {
                view.presentScene(sceneNode)

                view.ignoresSiblingOrder = true

                view.showsFPS = true
                view.showsNodeCount = true
            }
        }
        else {
            print("too soon.")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       print("touches ended")
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if (Date().timeIntervalSinceReferenceDate - startDateTime!) > 5 {
            allowTouchToExit = true
        }
    }
}
