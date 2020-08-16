//
//  GameScene.swift
//  Project17
//
//  Created by Subhrajyoti Chakraborty on 16/08/20.
//  Copyright © 2020 Subhrajyoti Chakraborty. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    var spaceDebris = 0
    var enemyCreationDelay = 1.0
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    func addShip(_ texture: SKTexture, how: String) {
        player = SKSpriteNode(texture: texture)
        player.position = CGPoint(x: 100, y: 384)
        
        player.physicsBody = SKPhysicsBody(texture: texture, size: player.size)
        if (player.physicsBody != nil) {
            player.physicsBody!.contactTestBitMask = 1
        }
        if player.physicsBody == nil {
            print("\(how) failed")
        } else {
            print("\(how) worked")
        }
        addChild(player)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        //      The atlas version of a texture
        addShip(SKTexture(imageNamed: "tv"), how: "simple atlas reference")
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: enemyCreationDelay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        checkDebrisCreation()
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        spaceDebris += 1
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        if (sprite.physicsBody != nil) {
            sprite.physicsBody!.categoryBitMask = 1
        }
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        gameTimer?.invalidate()
    }
    
    func checkDebrisCreation() {
        if spaceDebris > 20 {
             gameTimer?.invalidate()
             enemyCreationDelay = enemyCreationDelay - 0.1
             gameTimer = Timer.scheduledTimer(timeInterval: enemyCreationDelay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
             spaceDebris = 0
             print("enemyCreationDelay =>", enemyCreationDelay)
         }
    }
}
