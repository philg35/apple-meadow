//
//  GameScene.swift
//  FakeMario
//
//  Created by Philip Gross on 3/3/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var player = SKSpriteNode()
    private var playerWalkingFrames: [SKTexture] = []
    
    override func sceneDidLoad() {
        buildPlayer()
        animatePlayer()
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
        addChild(player)
    }
    
    func animatePlayer() {
        player.run(SKAction.repeatForever(
                    SKAction.animate(with: playerWalkingFrames,
                                     timePerFrame: 0.1,
                                     resize: false,
                                     restore: true)),
                 withKey:"walkingInPlacePlayer")
    }
    
    override func didMove(to view: SKView) {
        
        
        
        
        
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
