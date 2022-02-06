//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "plane2")
    let music = SKAudioNode(fileNamed: "DangerZone.mp3")
    var timer: Timer?
    var scoreLabel = SKLabelNode(fontNamed: "Baskerville-Bold")
    var score = 0 {
        didSet {
            scoreLabel.text = "Millie Cash:  $\(score).00"
        }
    }
    
    override func didMove(to view: SKView) {
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.collisionBitMask = 0
        addChild(player)
        
        scoreLabel.fontColor = UIColor.black.withAlphaComponent(0.5)
        scoreLabel.position.y = 320
        addChild(scoreLabel)
        score = 0
        
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        physicsWorld.contactDelegate = self
        
        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -340, z: -1, duration: 6, needsPhysics: true)
        addChild(music)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }
    
    override func update(_ currentTime: TimeInterval) {
        if player.position.y > 300 {
            player.position.y = 300
        }
        
        
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        player.run(rotate)
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        // run this code twice
        for i in 0...1 {
            let node = SKSpriteNode(imageNamed: image)
            
            
            node.position = CGPoint( x: 1023 * CGFloat(i), y: y)
            node.zPosition = z
            addChild(node)
            if needsPhysics {
                node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
                node.physicsBody?.isDynamic = false
                node.physicsBody?.contactTestBitMask = 1
                node.name = "obstacle"
            }
            
            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)
            
            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)
            
            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)
            
            node.run(forever)
        }
    }
    
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "pig")
        obstacle.zPosition = -2
        obstacle.position.x = 768
        addChild(obstacle)
        
        
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.texture!.size())
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.name = "obstacle"
        
        
        obstacle.position.y = CGFloat.random(in: -300..<350)
        let move = SKAction.moveTo(x: -768, duration: 9)
        let remove = SKAction.removeFromParent()
        let action = SKAction.sequence([move, remove])
        obstacle.run(action)
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            let coin = SKSpriteNode(imageNamed: "cash")
            coin.physicsBody = SKPhysicsBody(texture: coin.texture!, size: coin.texture!.size())
            coin.physicsBody?.contactTestBitMask = 1
            coin.physicsBody?.isDynamic = false
            coin.position.y = CGFloat.random(in: -300..<350)
            coin.position.x = 768
            coin.name = "score"
            coin.run(action)
            
            self.addChild(coin)
        }
        
    }
    
    
    func playerHit(_ node: SKNode) {
        
        if node.name == "obstacle" {
            if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                explosion.position = player.position
                addChild(explosion)
            }
            run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            player.removeFromParent()
            music.removeFromParent()
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let scene = GameScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    
                    self.view?.presentScene(scene)
                }
            }
            
        } else if node.name == "score" {
            run(SKAction.playSoundFileNamed("score.wav", waitForCompletion: false))
            node.removeFromParent()
            score += 1
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerHit(nodeB)
        } else if nodeB == player {
            playerHit(nodeA)
        }
    }
    
}

