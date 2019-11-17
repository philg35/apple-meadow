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
    
    var hitsLabel: SKLabelNode!
    var hits: Int = 0 {
        didSet {
            hitsLabel.text = "Hits: \(hits)"
        }
    }
    var highScoreLabel: SKLabelNode!
    var highScore: Int = 0 {
        didSet {
            highScoreLabel.text = "High Score: \(highScore)"
        }
    }
    
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        player!.physicsBody = SKPhysicsBody(texture: (player?.texture!)!, size: (player?.texture!.size())!)
        player?.physicsBody?.categoryBitMask = PhysicsCategories.player
        player?.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.peach | PhysicsCategories.star
        player?.physicsBody?.allowsRotation = false
        player?.physicsBody?.affectedByGravity = true
        player?.physicsBody?.isDynamic = true
        
        cam = self.childNode(withName: "cameraSprite") as? SKCameraNode
        self.physicsWorld.contactDelegate = self
        
        hitsLabel = SKLabelNode(text: "Hits: 0")
        hitsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        hitsLabel.position = CGPoint(x: 20, y: self.frame.size.height - 60)
        hitsLabel.fontName = "AmericanTypewriter-Bold"
        hitsLabel.fontSize = 24
        hitsLabel.fontColor = UIColor.white
        hits = 0
        self.addChild(hitsLabel)
        
        highScoreLabel = SKLabelNode(text: "High Score: 0")
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        highScoreLabel.position = CGPoint(x: 20, y: self.frame.size.height - 60)
        highScoreLabel.fontName = "AmericanTypewriter-Bold"
        highScoreLabel.fontSize = 24
        highScoreLabel.fontColor = UIColor.white
        highScore = 0
        self.addChild(highScoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addGoomba), userInfo: nil, repeats: true)
    }
    
    @objc func addGoomba() {
        let goomba = SKSpriteNode(imageNamed: "goomba")
        goomba.position = CGPoint(x: 1100, y: 320)
        let size = CGSize(width: 100, height: 100)
        goomba.scale(to: size)
        goomba.physicsBody = SKPhysicsBody(rectangleOf: goomba.size)
        goomba.physicsBody?.isDynamic = true
        goomba.physicsBody?.allowsRotation = false
        goomba.physicsBody?.categoryBitMask = PhysicsCategories.goomba
        goomba.physicsBody?.contactTestBitMask = PhysicsCategories.player
        goomba.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.ground | PhysicsCategories.goomba
        self.addChild(goomba)
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(by: CGVector(dx: -5000, dy: 0), duration: 30))
        actionArray.append(SKAction.removeFromParent())
        goomba.run(SKAction.sequence(actionArray))
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
        //print("contact", firstBody.categoryBitMask, secondBody.categoryBitMask, Date().timeIntervalSince1970)
        
        
        if ((firstBody.categoryBitMask & PhysicsCategories.ground) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0) {
            print("landed")
            jumped = false
            if hits > highScore {
                highScore = hits
            }
            hits = 0
        }
        else if ((firstBody.categoryBitMask & PhysicsCategories.goomba) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0) {
                if contact.contactNormal.dy < 0 {
                    print("got goomba", contact.contactNormal)
                    if let goombaTest = firstBody.node as! SKSpriteNode? {
                        if let playerTest = secondBody.node as! SKSpriteNode? {
                            playerDidCollideWithGoomba(goombaNode: goombaTest, playerNode: playerTest)
                        }
                    }
                }
        }
    }
    
    func playerDidCollideWithGoomba (goombaNode: SKSpriteNode, playerNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = goombaNode.position
        self.addChild(explosion)
        self.run(SKAction.playSoundFileNamed("stomp.wav", waitForCompletion: false))
        goombaNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 0.9)) {
            explosion.removeFromParent()
        }
        hits += 1
        var impulse = Int((playerNode.physicsBody?.velocity.dy)!) - Int(hits) * 30
        if impulse < -1000 {
            impulse = -1000
        }
        playerNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -impulse/3))
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
            hitsLabel.position.x = pl.position.x
            hitsLabel.position.y = pl.position.y + 200
            highScoreLabel.position.x = pl.position.x
            highScoreLabel.position.y = pl.position.y + 150
        }
        self.lastUpdateTime = currentTime
    }
}
