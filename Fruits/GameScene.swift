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

    var blenderCatrgory:UInt32 = 0x1 << 0
    var floorCategory:UInt32 = 0x1 << 1
    var stoneCategory:UInt32 = 0x1 << 2
    var appleCategory:UInt32 = 0x1 << 3
    var grapeCategory:UInt32 = 0x1 << 4
    var allCatchersCategory:UInt32 = 7
    
    var touchLocation:CGPoint!
    
    var generate:UIImpactFeedbackGenerator!
    var splitLine:SKSpriteNode!
    
    var callStones:Bool = false
    var bonusFruitArray = [String]()
    var tmpCatchFruitArray = [String]()
    var isBonusArrayReady:Bool = false
    
    let topSquareZPosition:CGFloat = 2.3
    let topSplitLineZPosition:CGFloat = 2.4
    let stoneZPosition:CGFloat = 2.2
    let scoreZPosition:CGFloat = 3
    let bonusFruitsZPosition:CGFloat = 3
    let fruitsZPosition:CGFloat = 1.8
    let blenderZPosition:CGFloat = 1.9
    let bottomLineZPosition:CGFloat = 1.9
    
    var callStoneStartTs:Double = 0
    
    override func didMove(to view: SKView) {
        // add score label
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 80, y: self.frame.size.height - 60)
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 24
        scoreLabel.zPosition = scoreZPosition
        score = 0
        self.addChild(scoreLabel)
        
        // add top square
        let square = SKSpriteNode(color: self.backgroundColor, size:CGSize(width: self.frame.size.width, height: 70))
        square.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 35)
        square.zPosition = topSquareZPosition
        self.addChild(square)
        
        // add top split line
        splitLine = SKSpriteNode(color: UIColor.brown, size: CGSize(width: self.frame.size.width, height: 3))
        splitLine.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height - 70)
        splitLine.zPosition = topSplitLineZPosition
    
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
        
        // add bottom split line
        splitBottomLine = SKSpriteNode(color: UIColor.brown, size: CGSize(width: self.frame.size.width, height: 3))
        splitBottomLine.position = CGPoint(x: self.frame.size.width / 2, y: blenderNode.position.y - blenderNode.size.height / 2 - splitLine.size.height / 2 )
        splitBottomLine.zPosition = bottomLineZPosition
        splitBottomLine.physicsBody = SKPhysicsBody(rectangleOf: splitBottomLine.size)
        splitBottomLine.physicsBody?.categoryBitMask = floorCategory
        splitBottomLine.physicsBody?.collisionBitMask = 0
        splitBottomLine.physicsBody?.isDynamic = true
        self.addChild(splitBottomLine)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addFruit), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeScoreLabelColor), userInfo: nil, repeats: true)
    }
    
    @objc func changeScoreLabelColor() {
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
        fruit.zPosition = fruitsZPosition
        
        fruit.physicsBody = SKPhysicsBody(rectangleOf: fruit.size)
        fruit.physicsBody?.isDynamic = true
        
        var fruitCategory:UInt32 = 0
        if newFruit == "apple" {
            fruitCategory = appleCategory
        } else if newFruit == "grape" {
            fruitCategory = grapeCategory
        }
        
        fruit.name = newFruit
        
        fruit.physicsBody?.categoryBitMask = fruitCategory
        fruit.physicsBody?.contactTestBitMask = allCatchersCategory
        fruit.physicsBody?.collisionBitMask = 0
        fruit.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(fruit)
        fruit.speed = 10
        
        var fruitsActions = [SKAction]()
        fruitsActions.append(SKAction.move(to: CGPoint(x: fruitXPosition, y: -fruit.size.height), duration: Double(self.frame.size.height / fruit.speed)))
        fruitsActions.append(SKAction.removeFromParent())
        fruit.run(SKAction.sequence(fruitsActions))
        
        if score > 0 && bonusFruitArray.count < 4 {
            bonusFruitArray.append(newFruit)
        }
        // print(self.frame.size)
        if bonusFruitArray.count == 3 && !isBonusArrayReady {
            var tmpF:SKSpriteNode!
            for i in 0...2 {
                tmpF = SKSpriteNode(imageNamed: bonusFruitArray[i])
                tmpF.position = CGPoint(x: (self.frame.size.width / 24) * CGFloat(22 - i), y: scoreLabel.position.y + fruit.size.height / 3)
                tmpF.zPosition = bonusFruitsZPosition
                self.addChild(tmpF)
            }
            isBonusArrayReady = true
            bonusFruitArray.reverse()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody!
        var secondBody:SKPhysicsBody!
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA // catcher is smaller
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
       
        // print(firstBody.categoryBitMask, secondBody.categoryBitMask)
        if firstBody.categoryBitMask & floorCategory == floorCategory {
            dropOnFloor(fruit: secondBody, bottom: firstBody)
        } else if firstBody.categoryBitMask & blenderCatrgory == blenderCatrgory {
            catchFruits(fruit: secondBody, blender: firstBody)
        } else if firstBody.categoryBitMask & stoneCategory == stoneCategory {
            stoneFireToFruites(fruit: secondBody, stone: firstBody)
        }
    }
    
    func stoneFireToFruites(fruit:SKPhysicsBody, stone:SKPhysicsBody) {
        var explosion:SKEmitterNode!
        explosion = SKEmitterNode(fileNamed: "explosion")
        explosion.position = CGPoint(x: fruit.node!.position.x, y: fruit.node!.position.y)
        self.addChild(explosion)
        fruit.node!.removeFromParent()
        stone.node!.removeFromParent()
        self.run(SKAction.wait(forDuration: 0.5)) {
            explosion.removeFromParent()
        }
        score += 8
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
        self.addChild(splatter)
        
        self.generate = UIImpactFeedbackGenerator(style: .light)
        self.generate.impactOccurred()
        
        let fnode = fruit.node as! SKSpriteNode
        fnode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)) {
            splatter.removeFromParent()
        }
        
        print(bonusFruitArray.count)
        
        if isBonusArrayReady && !callStones {
            if tmpCatchFruitArray.count + 1 == bonusFruitArray.count {
                callStones = true
                callStoneStartTs = Date().timeIntervalSince1970
                tmpCatchFruitArray = [String]()
                bonusFruitArray = [String]()
            } else {
                tmpCatchFruitArray.append(fnode.name!)
                print(tmpCatchFruitArray)
                print(bonusFruitArray)
                if tmpCatchFruitArray.last != bonusFruitArray[tmpCatchFruitArray.count - 1] {
                    tmpCatchFruitArray = [String]()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if callStones && (Date().timeIntervalSince1970 - callStoneStartTs > 5) {
            callStones = false
        }
        
        for touch in touches {
            touchLocation = touch.location(in: self)
            blenderNode.position.x = touchLocation.x
            if callStones {
                print("calling stones...")
                fireStones()
            }
        }
    }
    
    func fireStones() {
        let stone = SKSpriteNode(imageNamed: "apple")
        stone.position = CGPoint(x: blenderNode.position.x, y: blenderNode.position.y + blenderNode.size.height / 2)
        stone.zPosition = stoneZPosition
        stone.physicsBody = SKPhysicsBody(rectangleOf: stone.size)
        stone.physicsBody!.categoryBitMask = stoneCategory
        stone.physicsBody!.isDynamic = true
        stone.physicsBody!.usesPreciseCollisionDetection = true
        self.addChild(stone)
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: blenderNode.position.x, y: splitLine.position.y + stone.size.height), duration: 0.3))
        actionArray.append(SKAction.removeFromParent())
        
        stone.run(SKAction.sequence(actionArray))
    }
 
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
