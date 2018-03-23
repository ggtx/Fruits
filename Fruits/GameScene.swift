//
//  GameScene.swift
//  Fruits
//
//  Created by GAO on 2018/3/18.
//  Copyright © 2018年 GAO. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var blenderNode:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var gameTimer:Timer!
    var randomFruits = ["apple", "grape"]
    var randomColors = ["red", "purple"]
    var newFruit:String = ""
    var redUIColor = UIColor(red: 1, green: 0.3333, blue: 0.3333, alpha: 1.0) /* #ff5555 */
    var purpleUIColor = UIColor(red: 0.8039, green: 0.5294, blue: 0.8667, alpha: 1.0) /* #cd87dd */
    var greenUIColor = UIColor(red: 0.7373, green: 0.8275, blue: 0.3725, alpha: 1.0) /* #bcd35f */
    var yellowUIColor = UIColor(red: 1, green: 0.8667, blue: 0.3333, alpha: 1.0) /* #ffdd55 */

    
    var fruitCategory:UInt32 = 0x1 << 1
    var blenderCatrgory:UInt32 = 0x1 << 0
    var appleCategory:UInt32 = 0x1 << 2
    var grapeCategory:UInt32 = 0x1 << 3
    
    var touchLocation:CGPoint!
    
    var generate:UIImpactFeedbackGenerator!
    
    override func didMove(to view: SKView) {
        blenderNode = SKSpriteNode(imageNamed: "red_blender_72")
        blenderNode.position = CGPoint(x: self.frame.size.width / 2, y: blenderNode.size.height + 20)
        blenderNode.physicsBody = SKPhysicsBody(rectangleOf: blenderNode.size)
        blenderNode.physicsBody?.isDynamic = true
        blenderNode.physicsBody?.categoryBitMask = blenderCatrgory
        blenderNode.physicsBody?.contactTestBitMask = fruitCategory
        blenderNode.physicsBody?.collisionBitMask = 0
        self.addChild(blenderNode)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 60)
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.zPosition = 1
        score = 0
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addFruit), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(targetColor), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func targetColor() {
        randomColors = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: randomColors) as! [String]
        let newColor:String = randomColors[0]
        if newColor == "red" {
            scoreLabel.fontColor = redUIColor
        } else if newColor == "purple" {
            scoreLabel.fontColor = purpleUIColor
        }
    }
    
    @objc func addFruit() {
        randomFruits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: randomFruits) as! [String]
        newFruit = randomFruits[0]
        let fruit = SKSpriteNode(imageNamed: newFruit)
        let randomFruitXPosition = GKRandomDistribution(lowestValue: Int(fruit.size.width / 2) + 5, highestValue: Int(self.frame.size.width - fruit.size.width / 2))
        let fruitXPosition = CGFloat(randomFruitXPosition.nextInt())
        fruit.position = CGPoint(x: fruitXPosition, y: self.frame.size.height + fruit.size.height)
        
        fruit.physicsBody = SKPhysicsBody(rectangleOf: fruit.size)
        fruit.physicsBody?.isDynamic = true
        
        if newFruit == "apple" {
            fruitCategory = appleCategory
        } else if newFruit == "grape" {
            fruitCategory = grapeCategory
        }
        
        fruit.physicsBody?.categoryBitMask = fruitCategory
        fruit.physicsBody?.contactTestBitMask = blenderCatrgory
        fruit.physicsBody?.collisionBitMask = 0
        fruit.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(fruit)
        
        let animationDuration:TimeInterval = 8
        var fruitsActions = [SKAction]()
        fruitsActions.append(SKAction.move(to: CGPoint(x: fruitXPosition, y: -fruit.size.height), duration: animationDuration))
        fruitsActions.append(SKAction.removeFromParent())
        
        fruit.run(SKAction.sequence(fruitsActions))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody!
        var secondBody:SKPhysicsBody!
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA // blender is smaller
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
       
        catchFruits(fruit: secondBody, blender: firstBody)
    }
    
    func catchFruits(fruit:SKPhysicsBody, blender:SKPhysicsBody) {
        var splatter:SKEmitterNode!
        if fruit.categoryBitMask & appleCategory == appleCategory {
            splatter = SKEmitterNode(fileNamed: "red_spark")
            if scoreLabel.fontColor!.description == redUIColor.description {
                score += 5
            }
        } else if fruit.categoryBitMask & grapeCategory == grapeCategory {
            splatter = SKEmitterNode(fileNamed: "purple_spark")
            if scoreLabel.fontColor!.description == purpleUIColor.description {
                score += 3
            }
        }
        let bnode = blender.node as! SKSpriteNode
        splatter.position = CGPoint(x: CGFloat(bnode.position.x), y: CGFloat(bnode.position.y + blenderNode.size.height / 2))
        // splatter.position = CGPoint(x: CGFloat(bnode.position.x), y: CGFloat(bnode.position.y))
        self.addChild(splatter)
        
        self.generate = UIImpactFeedbackGenerator(style: .light)
        self.generate.impactOccurred()
        
        let fnode = fruit.node as! SKSpriteNode
        fnode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            splatter.removeFromParent()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
            blenderNode.position.x = touchLocation.x
        }
    }
 
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
