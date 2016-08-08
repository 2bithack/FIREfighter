//
//  GameScene.swift
//  FIREfighter
//
//  Created by enzo bot on 6/29/16.
//  Copyright (c) 2016 GarbageGames. All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation


class GameScene: SKScene, SKPhysicsContactDelegate {
   
    enum GameSceneState {
        case Active, GameOver, Pause
    }
    
    enum Move {
        case None, Left, Right
    }
    
    var move: Move = .None
    
    var gameState: GameSceneState = .Active
    var hero: SKSpriteNode!
    var woodFloor: SKSpriteNode!
    var scrollLayer: SKNode!
    var obstacleLayer: SKNode!
    var variableLayer: SKNode!
    var tap: SKNode?
//    var tapLeft: SKNode?
//    var tapRight: SKNode?
    
    var scoreLabel: SKLabelNode!
    var scoreLabel2: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var highScoreLabel2: SKLabelNode!
    var pauseButton: MSButtonNode!
    var playButton: MSButtonNode!
    var replayButton: MSButtonNode!
    
    var points: Int = 0
    var sinceTouch: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    var smokeTimer: CFTimeInterval = 0
    var goalTimer: CFTimeInterval = 0
    var fireBallTimer: CFTimeInterval = 0
    var babyTimer: CFTimeInterval = 0
    var babyRescueTimer: CFTimeInterval = 0
    var boolHighScore: Bool = false

    
    let fixedDelta: CFTimeInterval = 1.0/60.0 //60 fps
    var moveSpeed: CGFloat = 275
    var scrollSpeed: CGFloat = 120
    var lastPoints: Int = 0
    var reset: Bool = false
    
    var heroForce: CGFloat = 20.0
    var babyCounter = 0
    
    var fireBallsRand: UInt32 = 5
    var fireBallsRate = 50
    var fireWallRate: UInt32 = 10
    var fireWallRateBase: UInt32 = 3
    
    var bgMusic: AVAudioPlayer?

    
    
    func wallSpawnRate() -> CFTimeInterval {
        return 0.6
    }
    
    
    override func didMoveToView(view: SKView) {
        //cage the scene
        super.didMoveToView(view)
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        //load hero
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        
        //load baby

        
        scrollLayer = self.childNodeWithName("scrollLayer")
        physicsWorld.contactDelegate = self
        pauseButton = self.childNodeWithName("pauseButton") as! MSButtonNode
        scoreLabel = self.childNodeWithName("scoreLabel") as! SKLabelNode
        scoreLabel2 = self.childNodeWithName("scoreLabel2") as! SKLabelNode
        highScoreLabel = self.childNodeWithName("highScoreLabel") as! SKLabelNode
        highScoreLabel.text = "High Score: " + String(NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel"))
        
        highScoreLabel2 = self.childNodeWithName("highScoreLabel2") as! SKLabelNode
        highScoreLabel2.text = "High Score: " + String(NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel2"))


        playButton = self.childNodeWithName("playButton") as! MSButtonNode
        replayButton = self.childNodeWithName("replayButton") as! MSButtonNode
//        tapLeft = self.childNodeWithName("//tapLeft")
//        tapRight = self.childNodeWithName("//tapRight")
        tap = self.childNodeWithName("//tap")
        
//        self.gameState = .Pause
        
        if self.reset == false {
            self.gameState = .Pause
            self.pauseButton.state = .Hidden
            pauseButton.hidden = true
            self.playButton.state = .Active
            self.replayButton.state = .Hidden
            replayButton.hidden = true
            
            
            
        }  else if self.reset == true {
            self.gameState = .Active
            self.playButton.hidden = true
            self.playButton.state = .Hidden
            self.pauseButton.state = .Active
            self.pauseButton.hidden = false
            self.replayButton.hidden = true
            self.replayButton.state = .Hidden
            self.physicsWorld.speed = 1
            self.highScoreLabel.hidden = true
            self.highScoreLabel2.hidden = true
            
            if let bgMusic = self.setupAudioPlayerWithFile("musicbyMicahVellian", type:"wav") {
                self.bgMusic = bgMusic
            }
            self.bgMusic!.play()
            self.bgMusic?.numberOfLoops = -1
            
        }
        
        //pause button action
        pauseButton.selectedHandler = {
            self.pauseButton.hidden = true
            self.replayButton.hidden = false
            self.replayButton.state = .Active
            self.playButton.state = .Active
            self.playButton.hidden = false
            self.gameState = .Pause
            self.physicsWorld.speed = 0
            self.highScoreLabel.hidden = false
            self.highScoreLabel2.hidden = false
            
            self.bgMusic!.stop()


        }
        
        replayButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.reset = true
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            
            
            self.reset = true
            

            
        }
        
        //play button action
        playButton.selectedHandler = {
            
            
            self.gameState = .Active
            self.playButton.hidden = true
            self.playButton.state = .Hidden
            self.pauseButton.state = .Active
            self.pauseButton.hidden = false
            self.replayButton.hidden = true
            self.replayButton.state = .Hidden
            self.physicsWorld.speed = 1
            self.highScoreLabel.hidden = true
            self.highScoreLabel2.hidden = true
            
            if let bgMusic = self.setupAudioPlayerWithFile("musicbyMicahVellian", type:"wav") {
                self.bgMusic = bgMusic
            }
            self.bgMusic!.play()
            self.bgMusic?.numberOfLoops = -1
            
        }
        
        
        scoreLabel.text = String(points)
        scoreLabel2.text = String(points)
        
        //spawn boss for boss fight
        if points >= 5000 {
            
        }


    }
    
    
    
    //call for audio player
    func setupAudioPlayerWithFile(file:NSString, type:NSString) -> AVAudioPlayer?  {
        
        let soundFilePath = NSBundle.mainBundle().pathForResource("musicbyMicahVellian", ofType: "wav")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: soundFileURL)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        hero.physicsBody?.applyForce(CGVectorMake(0.0, 10.0))

        
        for touch in touches {
            let location = touch.locationInNode(self)
            if move == .None
            {
                if location.x >= self.size.width / 2
                {
                    move = .Left
                } else if location.x <= self.size.width / 2
                {
                    move = .Right
                }
            }
        }
        /* Called when a touch begins */
        switch move
        {
            case .None:
                break
            case .Right:
                move = .Left
            case .Left:
                move = .Right
        }
        
        //controls for boss level
        if points >= 5000{
            hero.physicsBody!.dynamic = false
            
        }
        
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        //let moveAction = "moveAction"
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        
        // Called when a touch ends
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        
        /* Skip game update if game no longer active */
        if gameState != .Active { return }
        hero.physicsBody?.applyForce(CGVectorMake(0.0, heroForce))
        hero.position.x.clamp(0, 320)
        hero.position.y.clamp(0, 568)
        sinceTouch += fixedDelta
        
        scrollWorld()
        updateObstacles()
        spawnTimer+=fixedDelta
        smokeTimer+=fixedDelta
        goalTimer+=fixedDelta
        babyRescueTimer+=fixedDelta
        
        
        
        if (move == .Left) {
            hero.position.x -= moveSpeed * CGFloat(fixedDelta)
        } else if (move == .Right) {
            hero.position.x += moveSpeed * CGFloat(fixedDelta)
        }
        
        if points > Int(highScoreLabel.text!) {
            highScoreLabel.text = String(points)
            highScoreLabel2.text = String(points)
            

        }
        
        if points > NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel") {
            
            if boolHighScore == false {
                let congrats = NSBundle.mainBundle().pathForResource("newHighScore", ofType: "sks")
                let newHighScore = SKReferenceNode (URL: NSURL (fileURLWithPath: congrats!))
                
                self.addChild(newHighScore)
                newHighScore.zPosition = 1
                newHighScore.position = CGPoint(x: 0, y: self.size.height/2)
                newHighScore.runAction(SKAction.sequence([
                    SKAction.fadeInWithDuration(0.5),
                    SKAction.fadeOutWithDuration(1),
                    SKAction.removeFromParent()
                    ]))
                boolHighScore = true
            }
            
            NSUserDefaults.standardUserDefaults().setInteger(points, forKey: "highScoreLabel")
            NSUserDefaults.standardUserDefaults().setInteger(points, forKey: "highScoreLabel2")

            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        highScoreLabel.text = "High Score: " + String(NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel"))
        highScoreLabel2.text = "High Score: " + String(NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel2"))


        
    }
    
    func scrollWorld() {
        //world scroll
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        //obstacle scroll
        obstacleLayer = self.childNodeWithName("obstacleLayer")!
        variableLayer = self.childNodeWithName("variableLayer")!
        
        
        //loop scroll layer nodes
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            //get ground node position, convert node position to scene space
            let floorPosition = scrollLayer.convertPoint(ground.position, toNode: self)
            //let instrucPosition = scrollLayer.convertPoint(ground.position, toNode: self)
            
            //check ground position has left scene
            if floorPosition.y <= -ground.size.height/2 {
                
                if ground == tap {
                    ground.removeFromParent()
                }
                else {
                    ground.position.y += ground.size.height * 2

                }
            }
        }
    }
    
    
    
    func updateObstacles() {
        
        obstacleLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        variableLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        
        //add baby power ups every 500 points after
  
        if points >= 500 && Int(points / 300) != Int(lastPoints / 300) {
            
            babyTimer = Double(arc4random_uniform(4) + 1)
            fireWallRateBase = 2

        }
        //spawn the baby power up at a random x position after a
        if babyTimer > 0 {
            babyTimer -= fixedDelta
            if babyTimer < 0 {

                
                let babyPath = NSBundle.mainBundle().pathForResource("baby", ofType: "sks")
                let babyNode = SKReferenceNode (URL: NSURL (fileURLWithPath: babyPath!))
                
                let randomBabyPosition = CGPointMake(CGFloat.random(min: 40, max: 280), 556)
                obstacleLayer.addChild(babyNode)
                babyNode.zPosition = 1
                babyNode.position = self.convertPoint(randomBabyPosition, toNode: obstacleLayer)

            }
        }
        
        
        //spawn fireballs that RAIN from the sky after 500 points and set timer for next fireball
        
        if points >= 1500 && Int(points / fireBallsRate) != Int(lastPoints / fireBallsRate) {
            
            fireBallTimer = Double(arc4random_uniform(fireBallsRand)) + 1
            
        }
        //action for spawning fireballs
        if fireBallTimer > 0 {
            fireBallTimer -= fixedDelta
            if fireBallTimer < 0 {
                
                
                let fireBallPath = NSBundle.mainBundle().pathForResource("fireball", ofType: "sks")
                let fireBallNode = SKReferenceNode (URL: NSURL (fileURLWithPath: fireBallPath!))
                
                self.addChild(fireBallNode)
                fireBallNode.zPosition = 3
                fireBallNode.position = CGPointMake(CGFloat.random(min: 20, max:300), 568)
                fireBallNode.runAction(SKAction.sequence([
                    SKAction.waitForDuration(3),
                    SKAction.removeFromParent()
                ]))
            }
        }
        //increase difficulty at 2500 points
        if points >= 2500 && Int(points / 100) != Int(lastPoints / 100) {
            if fireBallsRand >= 1 {
                fireBallsRand -= 1
            }
            fireBallsRate = 30
            fireWallRateBase = 1
        }
        
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convertPoint(obstacle.position, toNode: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.y <= -20 {
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
                
            }

            
        }
        
        /* Loop through variable obstacle layer nodes */
        for variableObstacle in variableLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let variablePosition = variableLayer.convertPoint(variableObstacle.position, toNode: self)
            
            /* Check if obstacle has left the scene */
            if variablePosition.y <= -20 {
                
                /* Remove obstacle node from obstacle layer */
                variableObstacle.removeFromParent()
            }
            
        }
        
        //scaling adjustable obstacle spawn rates

        
        if Int(points / 250) != Int(lastPoints / 250) {
            if fireWallRate >= 2 {
                fireWallRate -= 2
            }
            scrollSpeed += 20
            moveSpeed += 25
            
        }
        
        lastPoints = points
        //maximum smoke wall spawn rate

        //maximum wall obstacle spawn rate
        //maximum firefighter movement speed
        if moveSpeed >= 600 {
            moveSpeed = 600
        }
        //maximum scroll speed
        if scrollSpeed >= 320{
            scrollSpeed = 320
            heroForce = 30.0
        }
        //maximum fireball rate

        
        /* Time to add a new obstacle? */
        if spawnTimer >= wallSpawnRate() {
            
            /* Create an array of obstacles */
            let filenames = ["twoMidCB", "twoEndCB", "rightEndWallCB", "leftEndWallCB", "threeMidCO", "threeEndCO", "twoLMidCO", "twoRMidCO", "variableWall2"]
            
            // represent the selected obstacle from array
            let filename = filenames[random() % filenames.count]
            
            //set variable wall position
            if filename == "variableWall2" {
                
                let resourcePath = NSBundle.mainBundle().pathForResource(filename, ofType: "sks")
                let randomPosition = CGPointMake( CGFloat.random(min: -270, max: 0), 568)
                
                let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))

                obstacleLayer.addChild(newObstacle)
                newObstacle.position = self.convertPoint(randomPosition, toNode: variableLayer)
                spawnTimer = 0
            }
            //send in the other walls
            else {
            let resourcePath = NSBundle.mainBundle().pathForResource(filename, ofType: "sks")
            let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            obstacleLayer.addChild(newObstacle)
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convertPoint(CGPoint(x: 0.0, y: 568.0), toNode: obstacleLayer)
            
            // Reset spawn timer
            spawnTimer = 0
                
                //add in moving smoke walls randomly
                //set random spawn rate within range
                let randomFire = Float(arc4random_uniform(fireWallRate) + fireWallRateBase) * 0.5
                
                //smoke wall spawn rate
                if Float(smokeTimer) >= randomFire {
                    let moveLeft = SKAction.moveToX(-180, duration: 1.4)
                    let moveRight = SKAction.moveToX(340, duration: 1.4)
                    
                    let firePath = NSBundle.mainBundle().pathForResource("fireWall", ofType: "sks")
                    
                    let fireWall = SKReferenceNode (URL: NSURL (fileURLWithPath: firePath!))
                    fireWall.runAction(SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight])))

                    variableLayer.addChild(fireWall)
                    /* Generate new obstacle position, start just outside screen and with a random x value */
                    let randomPosition = CGPointMake( CGFloat.random(min: -180, max: 340), 569)
                    fireWall.position = self.convertPoint(randomPosition, toNode: variableLayer)
                    smokeTimer = 0
                    
                }

            }
            
        }
        
        //remove obstacles for boss fight
        
        if points >= 5000 {
            obstacleLayer.removeAllChildren()
            variableLayer.removeAllChildren()
            
        }
        
        
        
        
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Did our hero pass through the 'goal'? */
        if nodeA.name == "goal" && nodeB.name == "hero" || nodeB.name == "goal" && nodeA.name == "hero" {
            
            if goalTimer >= 0.09 {
            /* Increment points */
            points += 10
            
            /* Update score label */
            scoreLabel.text = String(points)
            scoreLabel2.text = String(points)

            goalTimer = 0
            /* We can return now */
            return
            }
            
        } else if (nodeA.name == "kill" && nodeB.name == "hero") || (nodeB.name == "kill" && nodeA.name == "hero") || (nodeA.name == "fireball" && nodeB.name == "hero") || (nodeB.name == "fireball" && nodeA.name == "hero") {
            
            /* Change game state to game over */
            gameState = .GameOver
            self.removeAllActions()
            
            let heroDeath = SKAction.runBlock({
                
                /* Put our hero face down in the dirt */
                self.hero.zRotation = CGFloat(-90).degreesToRadians()
                /* Stop hero from colliding with anything else */
                self.hero.physicsBody?.collisionBitMask = 0
                self.hero.removeAllActions()
            })
            
            //end music
            
            /* Create our hero death action */
            hero.runAction(heroDeath)
            
            /* Load the shake action resource */
            let shakeScene:SKAction = SKAction.init(named: "Shake")!
            
            /* Loop through all nodes  */
            for node in self.children {
                
                /* Apply effect each ground node */
                node.runAction(shakeScene)
                
            }
            pauseButton.hidden = true
            replayButton.hidden = false
            replayButton.state = .Active
            playButton.hidden = true
            playButton.state = .Hidden
            self.highScoreLabel.hidden = false
            self.highScoreLabel2.hidden = false
            self.bgMusic!.stop()
            
            /* We can return now */
            return
           
            
            //collecting babies feature
        } else if (nodeA.name == "baby" && nodeB.name == "hero") || (nodeB.name == "baby" && nodeA.name == "hero") {
            
            let babyPosition: CGPoint?
            //baby power ups slows time
            if nodeA.name == "hero" {
                 babyPosition = nodeA.position

            }else {
                 babyPosition = nodeB.position
            }
            
            if babyRescueTimer >= 0.09 {
                points += 100
                scoreLabel.text = String(points)
                scoreLabel2.text = String(points)
                
                if nodeA.name == "babyNode" {
                    nodeA.removeFromParent()
                }
                else {
                    nodeB.removeFromParent()
                }
                
                let hunnid = SKSpriteNode(imageNamed: "hunnid")
                self.addChild(hunnid)
                hunnid.position = babyPosition!
                hunnid.setScale(0.7)
                hunnid.zPosition = 4
                hunnid.runAction(SKAction.sequence([
                    SKAction.moveToY(babyPosition!.y + (20), duration: 1),
                    //SKAction.waitForDuration(1),
                    SKAction.fadeOutWithDuration(0.5),
                    SKAction.removeFromParent()
                    ]))
                
                let seconds = 5.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    self.scrollSpeed += 40
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.8)
                })
                
                scrollSpeed -= 60
                moveSpeed += 25
                physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.8)
                babyCounter += 1
                print(babyCounter)
                
                babyRescueTimer = 0
                
//                if babyCounter >= 3 {
//                    let powerUp: SKAction = SKAction.init(named: "3babies")!
//                    
//                    babyCounter = 0
//                }
            
                
            }
            
        }
        
    }
    
}
