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
    var splitBottomLine:SKSpriteNode!
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

    
    var fruitCategory:UInt32 = 0x1 << 2
    var blenderCatrgory:UInt32 = 0x1 << 0
    var appleCategory:UInt32 = 0x1 << 3
    var grapeCategory:UInt32 = 0x1 << 4
    var bottomLineCategory:UInt32 = 0x1 << 1
    var lineAndBlenderCategory:UInt32 = 3
    
    var touchLocation:CGPoint!
    
    var generate:UIImpactFeedbackGenerator!
    var splitLine:SKSpriteNode!
    
    /*
    self.physicsWorld.gravity = CGVector(dx: 0, dy: -0.6)
    self.physicsWorld.contactDelegate = self
 */
    
    
    override func didMove(to view: SKView) {
        // add score label
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 60)
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.zPosition = 2
        score = 0
        self.addChild(scoreLabel)
        
        // add top square
        let square = SKSpriteNode(color: self.backgroundColor, size:CGSize(width: self.frame.size.width, height: 70))
        square.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 35)
        square.zPosition = 1
        self.addChild(square)
        
        // add top split line
        splitLine = SKSpriteNode(color: UIColor.brown, size: CGSize(width: self.frame.size.width, height: 3))
        splitLine.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 70)
        splitLine.zPosition = 2
        self.addChild(splitLine)
        
        // add blender
        blenderNode = SKSpriteNode(imageNamed: "bowl_72")
        print(self.frame.size)
        blenderNode.position = CGPoint(x: self.frame.size.width / 2, y: blenderNode.size.height + self.frame.size.height / 35)
        // blenderNode.position = CGPoint(x: self.frame.size.width / 2, y: blenderNode.size.height + 20)
        blenderNode.physicsBody = SKPhysicsBody(rectangleOf: blenderNode.size)
        blenderNode.physicsBody?.isDynamic = true
        blenderNode.physicsBody?.categoryBitMask = blenderCatrgory
        // blenderNode.physicsBody?.contactTestBitMask = fruitCategory
        blenderNode.physicsBody?.collisionBitMask = 0
        self.addChild(blenderNode)
        // blenderNode.physicsBody!.affectedByGravity = false
        
        // add bottom split line
        splitBottomLine = SKSpriteNode(color: UIColor.brown, size: CGSize(width: self.frame.size.width, height: 3))
        splitBottomLine.position = CGPoint(x: self.frame.size.width / 2, y: blenderNode.position.y - blenderNode.size.height / 2 - splitLine.size.height / 2 )
        splitBottomLine.zPosition = 2
        splitBottomLine.physicsBody = SKPhysicsBody(rectangleOf: splitBottomLine.size)
        splitBottomLine.physicsBody?.categoryBitMask = bottomLineCategory
        splitBottomLine.physicsBody?.collisionBitMask = 0
        splitBottomLine.physicsBody?.isDynamic = true
        self.addChild(splitBottomLine)
        /*
        // add bottom square
        let squareBottom = SKSpriteNode(color: self.backgroundColor, size:CGSize(width: self.frame.size.width, height: 70))
        squareBottom.position = CGPoint(x: self.frame.size.width / 2, y: splitBottomLine.position.y - squareBottom.size.height / 2)
        squareBottom.zPosition = 1
        self.addChild(squareBottom)
 */
        
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
        fruit.position = CGPoint(x: fruitXPosition, y: splitLine.position.y + fruit.size.height / 2)
        fruit.zPosition = 0
        
        fruit.physicsBody = SKPhysicsBody(rectangleOf: fruit.size)
        fruit.physicsBody?.isDynamic = true
        
        if newFruit == "apple" {
            fruitCategory = appleCategory
        } else if newFruit == "grape" {
            fruitCategory = grapeCategory
        }
        
        fruit.physicsBody?.categoryBitMask = fruitCategory
        // fruit.physicsBody?.contactTestBitMask = blenderCatrgory
        fruit.physicsBody?.contactTestBitMask = lineAndBlenderCategory
        fruit.physicsBody?.collisionBitMask = 0
        fruit.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(fruit)
        fruit.speed = 10
        
        // let animationDuration:TimeInterval = 8
        var fruitsActions = [SKAction]()
        //fruitsActions.append(SKAction.move(to: CGPoint(x: fruitXPosition, y: -fruit.size.height), duration: animationDuration))
        fruitsActions.append(SKAction.move(to: CGPoint(x: fruitXPosition, y: -fruit.size.height), duration: Double(self.frame.size.height / fruit.speed)))
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
       
        print(firstBody.categoryBitMask, secondBody.categoryBitMask)
        if firstBody.categoryBitMask & bottomLineCategory == bottomLineCategory {
            print(1)
            dropOnFloor(fruit: secondBody, bottom: firstBody)
        } else {
            catchFruits(fruit: secondBody, blender: firstBody)
        }
    }
    
    func dropOnFloor(fruit:SKPhysicsBody, bottom:SKPhysicsBody) {
        var explosion:SKEmitterNode!
        explosion = SKEmitterNode(fileNamed: "explosion")
        explosion.position = CGPoint(x: fruit.node!.position.x, y: bottom.node!.position.y)
        self.addChild(explosion)
        fruit.node!.removeFromParent()
        self.run(SKAction.wait(forDuration: 0.5)) {
            explosion.removeFromParent()
        }
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
    
    @objc func genBonusFruitArray() {
        
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
