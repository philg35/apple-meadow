//
//  GameScene.swift
//  jumperGame
//
//  Created by Philip Gross on 7/27/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var jumped = false
    
    private var lastUpdateTime : TimeInterval = 0
    private var player : SKSpriteNode?
    private var snow : SKEmitterNode?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        snow = self.childNode(withName: "snow") as? SKEmitterNode
        snow?.advanceSimulationTime(20)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    func startMovingPlayerLeft () {
        let moveAction = SKAction.move(by: CGVector(dx: -1000, dy: 0), duration: 2)
        player?.xScale = -0.5
        player?.run(moveAction)

    }
    
    func startMovingPlayerRight() {
        let moveAction = SKAction.move(by: CGVector(dx: 1000, dy: 0), duration: 2)
        player?.xScale = 0.5
        player?.run(moveAction)
    }
    
    func endMovingPlayer() {
        player?.removeAllActions()
    }
    
    func jumpPlayer () {
        if (jumped == false)
        {
            jumped = true
            player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
//        let touchedNode = self.atPoint(positionInScene)
//        print(positionInScene)
        if (positionInScene.x > 0)
        {
            if (positionInScene.y > 0)
            {
                jumpPlayer()
                if positionInScene.x > 100
                {
                    startMovingPlayerRight()
                }
            }
            else
            {
                startMovingPlayerRight()
            }
        }
        else
        {
            if (positionInScene.y > 0)
            {
                jumpPlayer()
                if positionInScene.x < -100
                {
                    startMovingPlayerLeft()
                }
            }
            else
            {
                startMovingPlayerLeft()
            }
        }
//        if let name = touchedNode.name
//        {
//            print(name, "started")
//            switch (name)
//            {
//            case "arrowLeft":
//                startMovingPlayerLeft()
//                break
//            case "arrowRight":
//                startMovingPlayerRight()
//                break
//            case "Scene":
//                jumpPlayer()
//                break
//            case "snow":
//                jumpPlayer()
//                break
//            default:
//                break
//            }
//        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endMovingPlayer()
//        let touch:UITouch = touches.first!
//        let positionInScene = touch.location(in: self)
//        let touchedNode = self.atPoint(positionInScene)
//
//        if let name = touchedNode.name
//        {
//            print(name, "ended")
////            switch (name)
////            {
////            case "arrowLeft":
////                endMovingPlayer()
////                break
////            case "arrowRight":
////                endMovingPlayer()
////                break
////            case "Scene":
////                break
////            default:
////                break
////            }
//        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        if (player?.physicsBody?.velocity.dy == 0)
        {
            jumped = false
        }
        
        self.lastUpdateTime = currentTime
    }
}
