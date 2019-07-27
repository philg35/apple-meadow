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
    var lastUpdateTime : TimeInterval = 0
    var player : SKSpriteNode?
    var cam : SKCameraNode?
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        player = self.childNode(withName: "player") as? SKSpriteNode
        cam = self.childNode(withName: "cameraSprite") as? SKCameraNode
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
        if (jumped == false) {
            jumped = true
            player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        let pl = player
        let deltaX = positionInScene.x - (pl?.position.x)!
        let deltaY = positionInScene.y - (pl?.position.y)!
        if (deltaX > frame.maxX / 2) {
            startMovingPlayerRight()
            if (deltaY > frame.maxY / 2) {
                jumpPlayer()
            }
        }
        else {
            startMovingPlayerLeft()
            if (deltaY > frame.maxY / 2) {
                jumpPlayer()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endMovingPlayer()
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
        
        if let camera = cam, let pl = player {
            camera.position.x = pl.position.x + 100
            camera.position.y = pl.position.y + 100
        }
        
        self.lastUpdateTime = currentTime
    }
}
