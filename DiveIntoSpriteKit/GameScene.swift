//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit

@objcMembers
class GameScene: SKScene {
    let player = SKSpriteNode(imageNamed: "plane")
    var timer: Timer?
    
    override func didMove(to view: SKView) {
        player.position = CGPoint(x: -400, y: 250)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        addChild(player)
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
        physicsWorld.gravity = CGVector(dx: 0, dy: -5)
        
        parallaxScroll(image: "sky", y: 0, z: -3, duration: 10, needsPhysics: false)
        parallaxScroll(image: "ground", y: -340, z: -1, duration: 6, needsPhysics: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 300)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }
    
    override func update(_ currentTime: TimeInterval) {
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
            
            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)
            
            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)
            
            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)
            
            node.run(forever)
        }
    }
    
    func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "enemy-balloon")
        obstacle.zPosition = -2
        obstacle.position.x = 768
        addChild(obstacle)
        
        obstacle.position.y = CGFloat.random(in: -300..<350)
        
        let action = SKAction.moveTo(x: -768, duration: 9)
        obstacle.run(action)
        
    }
    
    
}

