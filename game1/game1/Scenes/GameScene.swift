//
//  GameScene.swift
//  game1
//
//  Created by Philip Gross on 7/11/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0),
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var levelLabel: SKLabelNode!
    var level: Int = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }
    
    var starfield: SKEmitterNode!
    
    override func didMove(to view: SKView) {
        setupPhysics()
        layoutScene()
        
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
//        starfield = SKEmitterNode(fileNamed: "starfield")
//        starfield.position = CGPoint(x: frame.minX, y: frame.maxY)
//        starfield.advanceSimulationTime(10)
//        addChild(starfield)
//
//        starfield.zPosition = ZPositions.label
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        colorSwitch.zPosition = ZPositions.colorSwitch
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        addChild(colorSwitch)
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = ZPositions.label
        addChild(scoreLabel)
        
        levelLabel = SKLabelNode(text: "Shots: 0")
        levelLabel.position = CGPoint(x: 270, y: self.frame.size.height - 60)
        levelLabel.fontName = "AvenirNext-Bold"
        levelLabel.fontSize = 24
        levelLabel.fontColor = UIColor.white
        level = 1
        self.addChild(levelLabel)
        
        spawnBall()
    }
    
    func spawnBall() {
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        addChild(ball)
    }
    
    func turnWheel() {
        if let newState = SwitchState(rawValue: switchState.rawValue + 1) {
            switchState = newState
        } else {
            switchState = .red
        }
        run(SKAction.playSoundFileNamed("Button-click-sound", waitForCompletion: false))
        
        colorSwitch.run(SKAction.rotate(byAngle: .pi/2, duration: 0.25))
    }
    
    func gameOver() {
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        let menuScene = MenuScene(size: view!.bounds.size)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        view!.presentScene(menuScene, transition: transition)
    }
    
    func animate(sprite: SKSpriteNode) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.25)
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let sequence = SKAction.sequence([fadeOut, fadeIn])
        sprite.run(SKAction.repeatForever(sequence))
    }
    
    func updateLabel(label: SKLabelNode) {
        let moveCenter = SKAction.move(to: CGPoint(x: frame.midX, y: frame.midY + 100), duration: 0.25)
        let moveBack = SKAction.move(to: CGPoint(x: 270, y: self.frame.size.height - 60), duration: 0.25)
        let scaleUp = SKAction.scale(to: 3.0, duration: 0.25)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence1 = SKAction.sequence([moveCenter, scaleUp, scaleDown, moveBack])
        label.run(SKAction.repeat(sequence1, count: 1))
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                if currentColorIndex == switchState.rawValue {
                    run(SKAction.playSoundFileNamed("Mario-coin-sound", waitForCompletion: false))
                    score += 1
                    
                    if score == 5 {
                        physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.0)
                        level += 1
                        updateLabel(label: levelLabel)
                    }
                    
                    if score == 10 {
                        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0)
                        level += 1
                        updateLabel(label: levelLabel)
                    }
                    
                    if score == 15 {
                        animate(sprite: colorSwitch)
                        level += 1
                        updateLabel(label: levelLabel)
                    }
                    
                    if score == 20 {
                        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
                        level += 1
                        updateLabel(label: levelLabel)
                    }
                    
                    if score == 25 {
                        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
                        level += 1
                        updateLabel(label: levelLabel)
                    }
                    
                    if score == 30 {
                        physicsWorld.gravity = CGVector(dx: 0.0, dy: -7.0)
                        level += 1
                        updateLabel(label: levelLabel)
                    }
                    
                    ball.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                        ball.removeFromParent()
                        self.spawnBall()
                    })
                } else {
                    gameOver()
                }
            }
        }
    }
}
