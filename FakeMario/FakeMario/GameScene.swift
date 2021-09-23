//
//  GameScene.swift
//  FakeMario
//
//  Created by Philip Gross on 3/3/21.
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
    
    private var player = SKSpriteNode()
    private var playerWalkingFrames: [SKTexture] = []
    var ground : SKSpriteNode?
    var jumped = false
    var cam : SKCameraNode?
    var lastUpdateTime : TimeInterval = 0
    var entities = [GKEntity]()
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        buildGround()
        buildPlayer()
        buildCamera()
        self.physicsWorld.contactDelegate = self
    }
    
    func buildPlayer() {
        let playerAnimatedAtlas = SKTextureAtlas(named: "FakeMario")
        var walkFrames: [SKTexture] = []
        
        let numImages = playerAnimatedAtlas.textureNames.count
        print("numImages", numImages)
        for i in 0...numImages - 1 {
            let playerTextureName = "sprite_fario\(i)"
            walkFrames.append(playerAnimatedAtlas.textureNamed(playerTextureName))
        }
        playerWalkingFrames = walkFrames
        
        let firstFrameTexture = playerWalkingFrames[0]
        player = SKSpriteNode(texture: firstFrameTexture)
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.xScale = 3
        player.yScale = 3
        
        player.physicsBody = SKPhysicsBody(texture: (player.texture!), size: (player.texture!.size()))
        player.physicsBody!.categoryBitMask = PhysicsCategories.player
        player.physicsBody!.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.peach | PhysicsCategories.star
        player.physicsBody!.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.star
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.affectedByGravity = true
        player.physicsBody!.isDynamic = true
        addChild(player)
    }
    
    func buildGround() {
        ground = self.childNode(withName: "ground") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground?.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.peach
    }
    
    func buildCamera() {
        cam = self.childNode(withName: "cameraSprite") as? SKCameraNode
        self.camera = cam
        if let camera = cam
        {
            camera.xScale = 1.6
            camera.yScale = 1.6
            print("camera ok!!!")
        }
        else {
            print("no camera!!!")
        }
    }
    
    func animatePlayer() {
        player.run(SKAction.repeatForever(
                    SKAction.animate(with: playerWalkingFrames,
                                     timePerFrame: 0.05,
                                     resize: false,
                                     restore: true)),
                   withKey:"walkingInPlacePlayer")
    }
    
    override func didMove(to view: SKView) {
        
    }
    
    func startMovingPlayerLeft () {
        let moveAction = SKAction.move(by: CGVector(dx: -10000, dy: 0), duration: 20)
        player.xScale = -3
        player.run(moveAction)
        animatePlayer()
    }
    
    func startMovingPlayerRight() {
        let moveAction = SKAction.move(by: CGVector(dx: 10000, dy: 0), duration: 20)
        player.xScale = 3
        player.run(moveAction)
        animatePlayer()
    }
    
    func endMovingPlayer() {
        player.removeAllActions()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        let pl = player
        let deltaX = positionInScene.x - (pl.position.x)
        let deltaY = positionInScene.y - (pl.position.y)
        print("x=\(positionInScene.x),y=\(positionInScene.y)")
        if (deltaX > frame.maxY / 2) {
            startMovingPlayerRight()
            if (deltaY > frame.maxX / 2) {
                jumpPlayer()
            }
        }
        else {
            startMovingPlayerLeft()
            if (deltaY > frame.maxX / 2) {
                jumpPlayer()
            }
        }
    }
    
    func jumpPlayer () {
        if (jumped == false) {
            jumped = true
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endMovingPlayer()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
//        print("contact", firstBody.categoryBitMask, secondBody.categoryBitMask, Date().timeIntervalSince1970)
        
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
        
        if let camera = cam {
            camera.position = player.position
        }
        
        self.lastUpdateTime = currentTime
    }
}
