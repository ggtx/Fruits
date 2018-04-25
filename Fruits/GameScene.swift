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
    var energyLabel:SKLabelNode!
    var energy:Int = 0 {
        didSet {
            energyLabel.text = "Energy: \(energy)"
        }
    }
    var levelLabel:SKLabelNode!
    var level:Int = 0 {
        didSet {
            levelLabel.text = "Level: \(level)"
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
    var leftMiddleLineCategory:UInt32 = 0x1 << 3
    var rightMiddleLineCategory:UInt32 = 0x1 << 4
    var appleCategory:UInt32 = 0x1 << 10
    var grapeCategory:UInt32 = 0x1 << 11
    var pearCategory:UInt32 = 0x1 << 12
    var allCatchersCategory:UInt32 = 31
    
    var touchLocation:CGPoint!
    
    var generate:UIImpactFeedbackGenerator!
    var splitLine:SKSpriteNode!
    var square:SKSpriteNode!
    var leftMiddleLine:SKSpriteNode!
    var rightMiddleLine:SKSpriteNode!
    
    var callStones:Bool = false
    var bonusFruitArray = [String]()
    var tmpCatchFruitArray = [String]()
    var bonusFruitNodes = [SKSpriteNode]()
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
    
    var stoneNameStr:String = ""
    
    var isBlender:Bool = false
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        
        self.view!.addGestureRecognizer(recognizer)
        // add score label
        scoreLabel = SKLabelNode(text: "Level 1!")
        scoreLabel.position = CGPoint(x: self.frame.size.width / 20, y: self.frame.size.height - 40)
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.fontColor = UIColor.white
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 18
        scoreLabel.zPosition = scoreZPosition
        score = 0
        self.addChild(scoreLabel)
        
        // add energy label
        energyLabel = SKLabelNode(text: "Energy: 0")
        energyLabel.position = CGPoint(x: self.frame.size.width / 20, y: self.frame.size.height - 60)
        energyLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        energyLabel.fontColor = UIColor.white
        energyLabel.fontName = "AmericanTypewriter-Bold"
        energyLabel.fontSize = 18
        energyLabel.zPosition = scoreZPosition
        energy = 0
        self.addChild(energyLabel)
        
        // add level label
        // add score label
        levelLabel = SKLabelNode(text: "Level 1!")
        levelLabel.position = CGPoint(x: self.frame.size.width / 20, y: self.frame.size.height / 40)
        levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        levelLabel.fontColor = UIColor.white
        levelLabel.fontName = "AmericanTypewriter-Bold"
        levelLabel.fontSize = 24
        levelLabel.zPosition = scoreZPosition
        level = 1
        self.addChild(levelLabel)
        
        // add top square
        square = SKSpriteNode(color: self.backgroundColor, size:CGSize(width: self.frame.size.width, height: 70))
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
        // print(self.frame.size)
        blenderNode.position = CGPoint(x: self.frame.size.width / 2, y: blenderNode.size.height + self.frame.size.height / 35)
        blenderNode.physicsBody = SKPhysicsBody(rectangleOf: blenderNode.size)
        blenderNode.physicsBody?.isDynamic = true
        blenderNode.physicsBody?.categoryBitMask = blenderCatrgory
        // blenderNode.physicsBody?.contactTestBitMask = fruitCategory
        blenderNode.physicsBody?.collisionBitMask = 0
        self.addChild(blenderNode)
        var panGesture = UIPanGestureRecognizer()
        
        blenderNode.isUserInteractionEnabled = true
        
        
        // add middle line
        // 375*667
        leftMiddleLine = SKSpriteNode(color: UIColor.brown, size: CGSize(width: self.frame.size.width / 4, height: self.frame.size.height / 222))
        leftMiddleLine.position = CGPoint(x: self.frame.size.width / 6, y: self.frame.size.height / 2)
        leftMiddleLine.physicsBody = SKPhysicsBody(rectangleOf: leftMiddleLine.size)
        leftMiddleLine.physicsBody?.isDynamic = true
        leftMiddleLine.physicsBody?.categoryBitMask = leftMiddleLineCategory
        leftMiddleLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addChild(leftMiddleLine)
        
        rightMiddleLine = SKSpriteNode(color: UIColor.brown, size: CGSize(width: self.frame.size.width / 4, height: self.frame.size.height / 222))
        rightMiddleLine.position = CGPoint(x: self.frame.size.width * 5 / 6, y: self.frame.size.height / 2)
        rightMiddleLine.physicsBody = SKPhysicsBody(rectangleOf: rightMiddleLine.size)
        rightMiddleLine.physicsBody?.isDynamic = true
        rightMiddleLine.physicsBody?.categoryBitMask = rightMiddleLineCategory
        rightMiddleLine.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.addChild(rightMiddleLine)
        
        
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
        // gameTimer = Timer.scheduledTimer(timeInterval: fruitAddInterval, target: self, selector: #selector(addFruit), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(changeScoreLabelColor), userInfo: nil, repeats: true)
    }
    
    @objc func tap(recognizer: UIGestureRecognizer) {
        
    }
    
    @objc func changeScoreLabelColor() {
        if randomFruits.count == 2 {
            randomColors = ["red", "purple"]
        } else if randomFruits.count == 3 {
            randomColors.append("green")
        }
        randomColors = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: randomColors) as! [String]
        let newColor:String = randomColors[0]
        if newColor == "red" {
            scoreLabel.fontColor = redUIColor
        } else if newColor == "purple" {
            scoreLabel.fontColor = purpleUIColor
        } else if newColor == "green" {
            scoreLabel.fontColor = greenUIColor
        }
    }
    
    func levelFruits() -> [String] {
        var farray = [String]()
        if score <= 100 {
            if level != 1 {
                level = 1
            }
            farray = ["apple", "grape"]
        } else if score > 100 {
            if level != 2 {
                level = 2
                scoreLabel.text = "Level 2!"
                self.backgroundColor = UIColor.darkGray
                self.square.color = UIColor.darkGray
            }
            farray = ["apple", "grape", "pear"]
        }
        return farray
    }
    
    @objc func addFruit() {
        randomFruits = levelFruits()
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
        } else if newFruit == "pear" {
            fruitCategory = pearCategory
        }
        
        fruit.name = newFruit
        
        fruit.physicsBody?.categoryBitMask = fruitCategory
        fruit.physicsBody?.contactTestBitMask = allCatchersCategory
        fruit.physicsBody?.collisionBitMask = 0
        fruit.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(fruit)
        fruit.speed = CGFloat(level) * 1.5 + 8
        
        
        if callStones {
            fruit.speed = 2 * (CGFloat(level) * 1.5 + 8)
        }
        
        /*
        if callStones {
            fruit.speed = CGFloat(level) * 5 + 8
            let bonusFruit1 = fruit.copy() as! SKSpriteNode
            bonusFruit1.position.x = CGFloat(GKRandomDistribution(lowestValue: Int(fruit.size.width / 2) + 5, highestValue: Int(self.frame.size.width - fruit.size.width / 2)).nextInt())
            let bonusFruit2 = fruit.copy() as! SKSpriteNode
            bonusFruit2.position.x = CGFloat(GKRandomDistribution(lowestValue: Int(fruit.size.width / 2) + 5, highestValue: Int(self.frame.size.width - fruit.size.width / 2)).nextInt())
            self.addChild(bonusFruit1)
            self.addChild(bonusFruit2)
        }
 */
        
        var fruitsActions = [SKAction]()
        fruitsActions.append(SKAction.move(to: CGPoint(x: fruitXPosition, y: -fruit.size.height), duration: Double(self.frame.size.height / fruit.speed)))
        fruitsActions.append(SKAction.removeFromParent())
        fruit.run(SKAction.sequence(fruitsActions))
        
        if score > 0 && bonusFruitArray.count < 4 {
            bonusFruitArray.append(newFruit)
        }
        print(self.frame.size)
        if bonusFruitArray.count == 3 && !isBonusArrayReady {
            SKAction.wait(forDuration: 3)
            var tmpF:SKSpriteNode!
            for i in 0...2 {
                tmpF = SKSpriteNode(imageNamed: bonusFruitArray[i])
                tmpF.position = CGPoint(x: (self.frame.size.width / 18) * CGFloat(18 - i) - fruit.size.width, y: square.position.y - fruit.size.height / 3)
                tmpF.zPosition = bonusFruitsZPosition
                bonusFruitNodes.append(tmpF)
                self.addChild(bonusFruitNodes[i])
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
        } else if firstBody.categoryBitMask & leftMiddleLineCategory == leftMiddleLineCategory {
            
        } else if firstBody.categoryBitMask & rightMiddleLineCategory == rightMiddleLineCategory {
            
        }
    }
    
    func middleLineCatchFruites(fruit:SKPhysicsBody, line:SKPhysicsBody) {
        
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
        energy -= 15 + level * 2
    }
    
    func catchFruits(fruit:SKPhysicsBody, blender:SKPhysicsBody) {
        energy += 10
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
        } else if fruit.categoryBitMask & pearCategory == pearCategory {
            splatter = SKEmitterNode(fileNamed: "green_spark")
            if scoreLabel.fontColor!.description == greenUIColor.description {
                score += 7
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
        
        // print(bonusFruitArray.count)
        
        if isBonusArrayReady && !callStones {
            tmpCatchFruitArray.append(fnode.name!)
            print(tmpCatchFruitArray)
            print(bonusFruitArray)
            if tmpCatchFruitArray.last != bonusFruitArray[tmpCatchFruitArray.count - 1] {
                tmpCatchFruitArray = [String]()
            }
            if tmpCatchFruitArray.count + 1 == bonusFruitArray.count {
                callStones = true
                isBonusArrayReady = false
                callStoneStartTs = Date().timeIntervalSince1970
                tmpCatchFruitArray = [String]()
                bonusFruitArray = [String]()
                for i in 0...2 {
                    bonusFruitNodes[i].removeFromParent()
                }
                bonusFruitNodes = [SKSpriteNode]()
                energy -= 50
                stoneNameStr = randomFruits[0]
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
            if callStones && energy > 0 {
                // print("calling stones...")
                fireStones()
            } else if callStones && energy <= 0 {
                energyLabel.text = "Unable to Fire!"
            }
        }
    }
    
    func fireStones() {
        let stone = SKSpriteNode(imageNamed: stoneNameStr)
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
