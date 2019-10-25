//
//  GameScene.swift
//  marioGame
//
//  Created by Philip Gross on 10/19/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit
import GameplayKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let player: UInt32 = 2
    static let ground: UInt32 = 4
    static let peach: UInt32 = 8
    static let star: UInt32 = 16
    static let goomba: UInt32 = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var jumped = false
    var player : SKSpriteNode?
    var cam : SKCameraNode?
    
    var gameTimer: Timer!
    
    
    private var lastUpdateTime : TimeInterval = 0
    
    override func sceneDidLoad() {
        print("started loading5")
        self.lastUpdateTime = 0
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        player?.physicsBody?.categoryBitMask = PhysicsCategories.player
        player?.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.peach | PhysicsCategories.star
        
        
        
        cam = self.childNode(withName: "cameraSprite") as? SKCameraNode
        self.physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addGoomba), userInfo: nil, repeats: true)
    }
    
    @objc func addGoomba() {

        let alien = SKSpriteNode(imageNamed: "goomba")
        alien.position = CGPoint(x: 1100, y: 320)
        let size = CGSize(width: 100, height: 100)
        alien.scale(to: size)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.allowsRotation = false
        alien.physicsBody?.categoryBitMask = PhysicsCategories.goomba
        alien.physicsBody?.contactTestBitMask = PhysicsCategories.player
        alien.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.ground | PhysicsCategories.goomba
        self.addChild(alien)
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(by: CGVector(dx: -5000, dy: 0), duration: 30))
        actionArray.append(SKAction.removeFromParent())
        alien.run(SKAction.sequence(actionArray))
    }
    
    
    func startMovingPlayerLeft () {
        let moveAction = SKAction.move(by: CGVector(dx: -1000, dy: 0), duration: 2)
        player?.xScale = -1
        player?.run(moveAction)

    }
    
    func startMovingPlayerRight() {
        let moveAction = SKAction.move(by: CGVector(dx: 1000, dy: 0), duration: 2)
        player?.xScale = 1
        player?.run(moveAction)
    }
    
    func endMovingPlayer() {
        player?.removeAllActions()
    }
    
    func jumpPlayer () {
        if (jumped == false) {
            jumped = true
            player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 150))
            print("jumped")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        if touchedNode.name == "player"{
            if Int(camera!.xScale) < 2 {
                camera?.xScale += 0.2
                camera?.yScale += 0.2
            }
            else {
                camera?.xScale = 0.8
                camera?.yScale = 0.8
            }
        }
        else {
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endMovingPlayer()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        print("contact", firstBody.categoryBitMask, secondBody.categoryBitMask, Date().timeIntervalSince1970)
        
        
        if ((firstBody.categoryBitMask & PhysicsCategories.ground) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0) {
            print("landed")
            jumped = false
        }
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
        
        if let camera = cam, let pl = player {
            camera.position.x = pl.position.x + 100
            camera.position.y = pl.position.y + 100
        }
        
        self.lastUpdateTime = currentTime
    }
}
