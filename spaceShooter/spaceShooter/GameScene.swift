//
//  GameScene.swift
//  spaceShooter
//
//  Created by Philip Gross on 7/18/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let alienCategory: UInt32 = 0x1 << 1
    static let photonTorpedoCategory: UInt32 = 0x1 << 2
    static let playerShipCategory: UInt32 = 0x1 << 3
}

enum ZPositions {
    static let background: CGFloat = -1
    static let label: CGFloat = 0
    static let ball: CGFloat = 1
    static let colorSwitch: CGFloat = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var hitsLabel: SKLabelNode!
    var hits: Int = 0 {
        didSet {
            hitsLabel.text = "Hits: \(hits)"
        }
    }
    var shotsLabel: SKLabelNode!
    var shots: Int = 0 {
        didSet {
            shotsLabel.text = "Shots: \(shots)"
        }
    }
    var missesLabel: SKLabelNode!
    var misses: Int = 0 {
        didSet {
            missesLabel.text = "Misses: \(misses)"
        }
    }
    var crashesLabel: SKLabelNode!
    var crashes: Int = 0 {
        didSet {
            crashesLabel.text = "Crashes: \(crashes)"
        }
    }
    var timeSeconds: Int = 0
    var score: Int = 0
    
    var gameTimer: Timer!
    var possibleAliens = ["starwars1", "starwars2", "deathstar", "deathstar2", "spaceship"]
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
        
    override func didMove(to view: SKView) {
        layoutScene()
    }
    
    func layoutScene() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        starfield = SKEmitterNode(fileNamed: "starfield.sks")
        starfield.position = CGPoint(x: frame.minX, y: frame.maxY)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = ZPositions.background
        
        player = SKSpriteNode(imageNamed: "spaceship4")
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 50)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategories.playerShipCategory
        player.physicsBody?.contactTestBitMask = PhysicsCategories.alienCategory
        player.physicsBody?.collisionBitMask = 0
        self.addChild(player)
        
        
        
        hitsLabel = SKLabelNode(text: "Hits: 0")
        hitsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        hitsLabel.position = CGPoint(x: 20, y: self.frame.size.height - 60)
        hitsLabel.fontName = "AmericanTypewriter-Bold"
        hitsLabel.fontSize = 24
        hitsLabel.fontColor = UIColor.white
        hits = 0
        self.addChild(hitsLabel)
        
        shotsLabel = SKLabelNode(text: "Shots: 0")
        shotsLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        shotsLabel.position = CGPoint(x: 220, y: self.frame.size.height - 60)
        shotsLabel.fontName = "AmericanTypewriter-Bold"
        shotsLabel.fontSize = 24
        shotsLabel.fontColor = UIColor.white
        shots = 0
        self.addChild(shotsLabel)
        
        missesLabel = SKLabelNode(text: "Misses: 0")
        missesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        missesLabel.position = CGPoint(x: 20, y: self.frame.size.height - 90)
        missesLabel.fontName = "AmericanTypewriter-Bold"
        missesLabel.fontSize = 24
        missesLabel.fontColor = UIColor.white
        misses = 0
        self.addChild(missesLabel)
        
        crashesLabel = SKLabelNode(text: "Misses: 0")
        crashesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        crashesLabel.position = CGPoint(x: 220, y: self.frame.size.height - 90)
        crashesLabel.fontName = "AmericanTypewriter-Bold"
        crashesLabel.fontSize = 24
        crashesLabel.fontColor = UIColor.white
        crashes = 0
        self.addChild(crashesLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    @objc func addAlien() {
        timeSeconds += 1

        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.maxX))
        let position = CGFloat(randomAlienPosition.nextInt())
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = PhysicsCategories.alienCategory
        alien.physicsBody?.contactTestBitMask = PhysicsCategories.photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = PhysicsCategories.playerShipCategory
        self.addChild(alien)
        let animationDuration: TimeInterval = Double.random(in: 3...6)
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        actionArray.append(SKAction.run {
            self.countMissedAlien()
        })
        alien.run(SKAction.sequence(actionArray))
    }
    
    func countMissedAlien() {
        //print("you missed one")
        misses += 1
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    func fireTorpedo() {
        shots += 1
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position = player.position
        torpedoNode.position.y += 5
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        torpedoNode.physicsBody?.categoryBitMask = PhysicsCategories.photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = PhysicsCategories.alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(torpedoNode)
        let animationDuration: TimeInterval = 0.3
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        torpedoNode.run(SKAction.sequence(actionArray))
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
        
        if (firstBody.categoryBitMask & PhysicsCategories.photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & PhysicsCategories.alienCategory) != 0 {
            if let torpedoTest = firstBody.node as! SKSpriteNode?
            {
                if let alienTest = secondBody.node as! SKSpriteNode?
                {
                    torpedoDidCollideWithAlien(torpedoNode: torpedoTest, alienNode: alienTest)
                }
            }
        } else if (firstBody.categoryBitMask & PhysicsCategories.playerShipCategory) != 0 && (secondBody.categoryBitMask & PhysicsCategories.alienCategory) != 0 {
            if let shipTest = firstBody.node as! SKSpriteNode?
            {
                if let alienTest = secondBody.node as! SKSpriteNode?
                {
                    shipDidCollideWithAlien(shipNode: shipTest, alienNode: alienTest)
                }
            }
        }
    }
    
    func torpedoDidCollideWithAlien (torpedoNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        hits += 1
        
    }
    
    func shipDidCollideWithAlien(shipNode: SKSpriteNode, alienNode: SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        alienNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            explosion.removeFromParent()
        }
        crashes += 1
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        if player.position.x < 0 {
            player.position.x = 0
            //player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width {
            player.position.x = self.size.width
            //player.position = CGPoint(x: -20, y: player.position.y)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if (timeSeconds > 25)
        {
            UserDefaults.standard.set(hits, forKey: "Hits")
            UserDefaults.standard.set(shots, forKey: "Shots")
            UserDefaults.standard.set(misses, forKey: "Misses")
            UserDefaults.standard.set(crashes, forKey: "Crashes")
            
            let endScene = EndScene(size: view!.bounds.size)
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            view!.presentScene(endScene, transition: transition)
        }
    }
}
