//
//  EndScene.swift
//  spaceShooter
//
//  Created by Philip Gross on 7/25/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import SpriteKit

class EndScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        addLabels()
        run(SKAction.playSoundFileNamed("Game-over-robotic-voice.mp3", waitForCompletion: false))
    }
    
    func addLabels() {
        let hits = UserDefaults.standard.integer(forKey: "Hits")
        let shots = UserDefaults.standard.integer(forKey: "Shots")
        let misses = UserDefaults.standard.integer(forKey: "Misses")
        let crashes = UserDefaults.standard.integer(forKey: "Crashes")
        
        let hitsLabel = SKLabelNode(text: "Hits: " + "\(hits)" + " x 200")
        hitsLabel.fontName = "AvenirNext-Bold"
        hitsLabel.fontSize = 25.0
        hitsLabel.fontColor = UIColor.white
        hitsLabel.position = CGPoint(x: frame.midX, y: frame.maxY - hitsLabel.frame.size.height*4)
        addChild(hitsLabel)
        
        let shotsLabel = SKLabelNode(text: "Shots: " + "\(shots)" + " x -50")
        shotsLabel.fontName = "AvenirNext-Bold"
        shotsLabel.fontSize = 25.0
        shotsLabel.fontColor = UIColor.red
        shotsLabel.position = CGPoint(x: frame.midX, y: hitsLabel.position.y - shotsLabel.frame.size.height*2)
        addChild(shotsLabel)
        
        let missesLabel = SKLabelNode(text: "Misses: " + "\(misses)" + " x -100")
        missesLabel.fontName = "AvenirNext-Bold"
        missesLabel.fontSize = 25.0
        missesLabel.fontColor = UIColor.red
        missesLabel.position = CGPoint(x: frame.midX, y: shotsLabel.position.y - missesLabel.frame.size.height*2)
        addChild(missesLabel)
        
        let crashesLabel = SKLabelNode(text: "Crashes: " + "\(crashes)" + " x 50")
        crashesLabel.fontName = "AvenirNext-Bold"
        crashesLabel.fontSize = 25.0
        crashesLabel.fontColor = UIColor.white
        crashesLabel.position = CGPoint(x: frame.midX, y: missesLabel.position.y - crashesLabel.frame.size.height*2)
        addChild(crashesLabel)
        
        let score = (hits * 200) - (shots * 50) - (misses * 100) + (crashes * 50)
        let scoreLabel = SKLabelNode(text: "Score: " + "\(score)")
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 30.0
        scoreLabel.fontColor = UIColor.yellow
        scoreLabel.position = CGPoint(x: frame.midX, y: crashesLabel.position.y - scoreLabel.frame.size.height*2)
        addChild(scoreLabel)
        
        UserDefaults.standard.set(score, forKey: "RecentScore")
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(gameScene)
    }
}


