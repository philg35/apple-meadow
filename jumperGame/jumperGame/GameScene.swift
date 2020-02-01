//
//  GameScene.swift
//  jumperGame
//
//  Created by Philip Gross on 7/27/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit
import GameplayKit
import MediaPlayer

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let player: UInt32 = 0x1 << 1    // 2
    static let ground: UInt32 = 0x1 << 2    // 4
    static let peach: UInt32 = 0x1 << 3     // 8
    static let star: UInt32 = 0x1 << 4      // 16
    static let radial: UInt32 = 0x1 << 5    // 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var jumped = false
    var lastUpdateTime : TimeInterval = 0
    var player : SKSpriteNode?
    var peach : SKSpriteNode?
    var star : SKSpriteNode?
    var ground : SKSpriteNode?
    var cam : SKCameraNode?
    var tileMap : SKTileMapNode?
    
    var playerr: AVAudioPlayer?
    
    override func sceneDidLoad() {
        let path = Bundle.main.path(forResource:"honeyHive", ofType: "mp3")

        do{
            try playerr = AVAudioPlayer(contentsOf: URL(fileURLWithPath: path!))
        } catch {
            print("File is not Loaded")
        }
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSession.Category.playback)
        }
        catch{
        }

        playerr!.play()
        
        self.lastUpdateTime = 0
        player = self.childNode(withName: "player") as? SKSpriteNode
        player?.physicsBody?.categoryBitMask = PhysicsCategories.player
        player?.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.peach | PhysicsCategories.star
        player?.physicsBody?.contactTestBitMask = PhysicsCategories.ground | PhysicsCategories.star
        //player?.physicsBody?.fieldBitMask = PhysicsCategories.radial
        
        peach = self.childNode(withName: "peach") as? SKSpriteNode
        peach?.physicsBody?.categoryBitMask = PhysicsCategories.peach
        peach?.physicsBody?.collisionBitMask = PhysicsCategories.ground | PhysicsCategories.player
        
        star = self.childNode(withName: "star") as? SKSpriteNode
        star?.physicsBody?.categoryBitMask = PhysicsCategories.star
        star?.physicsBody?.collisionBitMask = PhysicsCategories.player
        
        ground = self.childNode(withName: "greenGround") as? SKSpriteNode
        ground?.physicsBody?.categoryBitMask = PhysicsCategories.ground
        ground?.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.peach
        
        cam = self.childNode(withName: "cameraSprite") as? SKCameraNode
        self.physicsWorld.contactDelegate = self
        
//        self.tileMap = self.childNode(withName: "Tile Map Node") as? SKTileMapNode
//        guard let tileMap = self.tileMap else { fatalError("Missing tile map for the level") }
//        self.tileMap?.zPosition = -1
//        
//        let tileSize = tileMap.tileSize
//        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
//        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
//        for col in 0..<tileMap.numberOfColumns {
//            for row in 0..<tileMap.numberOfRows {
//                let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
//                let isEdgeTile = tileDefinition?.userData?["groundTile"] as? Bool
//                if (isEdgeTile ?? false) {
//                    let x = CGFloat(col) * tileSize.width - halfWidth
//                    let y = CGFloat(row) * tileSize.height - halfHeight
//                    let rect = CGRect(x: 0, y: 0, width: tileSize.width, height: tileSize.height)
//                    let tileNode = SKShapeNode(rect: rect)
//                    tileNode.position = CGPoint(x: x, y: y)
//                    tileNode.physicsBody = SKPhysicsBody.init(rectangleOf: tileSize, center: CGPoint(x: tileSize.width / 2.0, y: tileSize.height / 2.0))
//                    //tileNode.physicsBody?.restitution = 1
//                    tileNode.physicsBody?.isDynamic = false
//                    tileNode.physicsBody?.collisionBitMask = PhysicsCategories.player
//                    tileNode.physicsBody?.categoryBitMask = PhysicsCategories.ground
//                    tileMap.addChild(tileNode)
//                }
//            }
//        }
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
        
        if (firstBody.categoryBitMask & PhysicsCategories.star) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0 {
            playerr!.stop()
            if let scene = GKScene(fileNamed: "WinScene") {
                if let sceneNode = scene.rootNode as! WinScene? {
                    sceneNode.scaleMode = .aspectFill
                    if let view = self.view {
                        view.presentScene(sceneNode)
                        view.ignoresSiblingOrder = true
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        }
        else if ((firstBody.categoryBitMask & PhysicsCategories.ground) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0) {
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


