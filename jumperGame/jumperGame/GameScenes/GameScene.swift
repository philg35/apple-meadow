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
    static let goomba: UInt32 = 0x1 << 6    // 64
    static let fireball: UInt32 = 0x1 << 7  // 128
    static let bowser: UInt32 = 0x1 << 8    // 256
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var jumped = false
    var lastUpdateTime : TimeInterval = 0
    var player : SKSpriteNode?
    var peach : SKSpriteNode?
    var bowser : SKSpriteNode?
    var star : SKSpriteNode?
    var ground : SKSpriteNode?
    var cam : SKCameraNode?
    var tileMap : SKTileMapNode?
    
    var playerr: AVAudioPlayer?
    
    var level : Int = 0
    var toggle : Bool = false
    
    var gameTimer: Timer!
    var gameTimer2: Timer!
    
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
        level = UserDefaults.standard.integer(forKey: "Level")
        let musicArray = ["honeyHive", "eggPlanet", "moltenGalaxy", "airShip", "blueSky", "flyingMario", "marioRemix", "spaceAthletic"]
        var music = ""
        if level == 3
        {
            music = "finalBowser"
        }
        else
        {
            music = musicArray[Int.random(in: 0..<musicArray.count)]
        }
        print(music)
        let path = Bundle.main.path(forResource: music, ofType: "mp3")
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
        
        if let camera = cam
        {
            camera.xScale = 1.6
            camera.yScale = 1.6
        }
            
        self.physicsWorld.contactDelegate = self
        
        
        
        if level == 2 {
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
        else if level == 3 {
            let bowser = SKSpriteNode(imageNamed: "bowser")
            bowser.position = CGPoint(x: 1100, y: 320)
            bowser.physicsBody?.categoryBitMask = PhysicsCategories.bowser
            bowser.physicsBody?.collisionBitMask = 0 //PhysicsCategories.player
            //self.addChild(bowser)
            gameTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(addFireball), userInfo: nil, repeats: true)
            gameTimer2 = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(moveBowser), userInfo: nil, repeats: true)
        }
    }
    
    func startMovingPlayerLeft () {
        let moveAction = SKAction.move(by: CGVector(dx: -10000, dy: 0), duration: 20)
        player?.xScale = -10
        player?.run(moveAction)
    }
    
    func startMovingPlayerRight() {
        let moveAction = SKAction.move(by: CGVector(dx: 10000, dy: 0), duration: 20)
        player?.xScale = 10
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
            print("camera scale=", camera?.xScale, camera?.yScale)
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
        else if ((firstBody.categoryBitMask & PhysicsCategories.goomba) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0)
        {
            if contact.contactNormal.dy < -0.5
            {
                if let goombaTest = firstBody.node as! SKSpriteNode?
                {
                    if let playerTest = secondBody.node as! SKSpriteNode?
                    {
                        print("got goomba", contact.contactNormal)
                        playerDidCollideWithGoomba(goombaNode: goombaTest, playerNode: playerTest)
                    }
                }
            }
            else
            {
                if let goombaTest = firstBody.node as! SKSpriteNode?
                {
                    if let playerTest = secondBody.node as! SKSpriteNode?
                    {
                        print("goomba got you", contact.contactNormal)
                        playerTouchedGoomba(goombaNode: goombaTest, playerNode: playerTest)
                    }
                }
            }
            
        }
        else if((firstBody.categoryBitMask & PhysicsCategories.fireball) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0)
        {
            if let fireballTest = firstBody.node as! SKSpriteNode?
            {
                if let playerTest = secondBody.node as! SKSpriteNode?
                {
                    print("fireball got you", contact.contactNormal)
                    //playerTouchedGoomba(goombaNode: goombaTest, playerNode: playerTest)
                }
            }
        }
        else if ((firstBody.categoryBitMask & PhysicsCategories.ground) != 0 && (secondBody.categoryBitMask & PhysicsCategories.player) != 0) {
            //print("landed")
            jumped = false
            if level == 2 {
                if hits > highScore {
                    highScore = hits
                }
                hits = 0
            }
        }
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
    
    @objc func addFireball() {
        bowser = self.childNode(withName: "bowser") as? SKSpriteNode
        let fireball = SKSpriteNode(imageNamed: "fireball")
        fireball.position.x = (bowser?.position.x)! - 200
        fireball.position.y = bowser?.position.y as! CGFloat
        let size = CGSize(width: 100, height: 100)
        fireball.scale(to: size)
        fireball.zRotation = 180
        fireball.physicsBody = SKPhysicsBody(rectangleOf: fireball.size)
        fireball.physicsBody?.isDynamic = false
        fireball.physicsBody?.allowsRotation = false
        fireball.physicsBody?.categoryBitMask = PhysicsCategories.fireball
        fireball.physicsBody?.contactTestBitMask = PhysicsCategories.player
        fireball.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.ground
        self.addChild(fireball)
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(by: CGVector(dx: -5000, dy: 0), duration: 30))
        actionArray.append(SKAction.removeFromParent())
        fireball.run(SKAction.sequence(actionArray))
    }
    
    @objc func moveBowser() {
        var dir : Int = 0
        if toggle == true {
            toggle = false
            dir = 2000
        }
        else {
            toggle = true
            dir = -2000
        }
        print("moving bowser")
        bowser = self.childNode(withName: "bowser") as? SKSpriteNode
        bowser?.physicsBody?.applyImpulse(CGVector(dx: dir, dy: 10000))
    }

    func playerDidCollideWithGoomba (goombaNode: SKSpriteNode, playerNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = goombaNode.position
        self.addChild(explosion)
        self.run(SKAction.playSoundFileNamed("1up.mp3", waitForCompletion: false))
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
    
    func playerTouchedGoomba (goombaNode: SKSpriteNode, playerNode: SKSpriteNode) {
        playerNode.physicsBody?.applyImpulse(CGVector(dx: -10, dy: 5))
        self.run(SKAction.playSoundFileNamed("ouch.mp3", waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval)
    {
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
            if level == 2 {
                hitsLabel.position.x = pl.position.x
                hitsLabel.position.y = pl.position.y + 200
                highScoreLabel.position.x = pl.position.x
                highScoreLabel.position.y = pl.position.y + 150
            }
        }
        
        self.lastUpdateTime = currentTime
    }
}


