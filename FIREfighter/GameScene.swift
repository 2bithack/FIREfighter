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
    
    var points: Int = 0
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
    var soundButton:MSButtonNode!
    
    
    var sinceTouch: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    var smokeTimer: CFTimeInterval = 0
    var goalTimer: CFTimeInterval = 0
    var fireBallTimer: CFTimeInterval = 0
    var babyTimer: CFTimeInterval = 0
    var babyRescueTimer: CFTimeInterval = 0
    var bossHitTimer: CFTimeInterval = 0
    var blastTimer: CFTimeInterval = 0
    var boolHighScore: Bool = false
    var boss: SKNode!

    
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
    
    static var stayPaused = false as Bool
    
    override var paused: Bool {
        get {
            return super.paused
        }
        set {
            if (newValue || !GameScene.stayPaused) {
                super.paused = newValue
            }
            GameScene.stayPaused = false
        }
    }
    
    
    override func didMoveToView(view: SKView) {
        

        
        self.view?.multipleTouchEnabled = false

        //cage the scene
        super.didMoveToView(view)
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        //load hero
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        scrollLayer = self.childNodeWithName("scrollLayer")
        physicsWorld.contactDelegate = self
        soundButton = self.childNodeWithName("sound") as! MSButtonNode
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
        
        soundButton.hidden = true

//button settings to load game on fresh start and different settings when reset
        
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
        soundButton.selectedHandler =
            
        {
            playSound = !playSound
            if playSound == true
            {
                self.soundButton.texture = SKTexture(imageNamed: "sound")
                
            } else
            {
                self.bgMusic?.pause()
                self.soundButton.texture = SKTexture(imageNamed: "soundOFF")

            }

            NSUserDefaults.standardUserDefaults().setObject(playSound, forKey: "playSound")
        }
        
        
        pauseButton.selectedHandler = {
            self.pauseButton.hidden = true
            self.soundButton.hidden = false
            self.replayButton.hidden = false
            self.replayButton.state = .Active
            self.playButton.state = .Active
            self.playButton.hidden = false
            self.gameState = .Pause
            self.physicsWorld.speed = 0
            self.highScoreLabel.hidden = false
            self.highScoreLabel2.hidden = false
            
            self.paused = true
            
            if let _ = self.bgMusic
            {
                self.bgMusic!.stop()
            }
            

        }
        
        replayButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene.reset = true

            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit//.AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            
            
            self.reset = true
            
        }
        
        //play button action
        playButton.selectedHandler = {
            
            self.gameState = .Active
            self.playButton.hidden = true
            self.soundButton.hidden = true
            self.playButton.state = .Hidden
            self.pauseButton.state = .Active
            self.pauseButton.hidden = false
            self.replayButton.hidden = true
            self.replayButton.state = .Hidden
            self.physicsWorld.speed = 1
            self.highScoreLabel.hidden = true
            self.highScoreLabel2.hidden = true
            self.paused = false
            if playSound == true
            {
                self.startBackgroundMusic()
            }
                        
            
        }
        
        
        scoreLabel.text = String(points)
        scoreLabel2.text = String(points)
        

        //mute music preference stored
        if let bool = NSUserDefaults.standardUserDefaults().objectForKey("playSound") as! Bool?
        {
            playSound = bool
        } else
        {
            playSound = true
        }
        
        if playSound == true
        {
            self.soundButton.texture = SKTexture(imageNamed: "sound")
            
        } else
        {
            self.bgMusic?.pause()
            self.soundButton.texture = SKTexture(imageNamed: "soundOFF")
            
        }

        
    }
    
    func spawnBoss() {
        
        hero.physicsBody!.dynamic = false
        
        //move to firefighter to locked y position
        hero.runAction(SKAction.moveTo(CGPoint(x: hero.position.x, y: self.frame.height * 0.1), duration: 1))
        //hero.position.y = (self.frame.height * 0.1)
        
        //load fireboss
        let bossPath = NSBundle.mainBundle().pathForResource("fireBoss", ofType: "sks")
        let bossNode = SKReferenceNode (URL: NSURL (fileURLWithPath: bossPath!))
        let moveLeft = SKAction.moveToX(0, duration: 1.4)
        let moveRight = SKAction.moveToX(300, duration: 1.4)
        self.addChild(bossNode)
        
        let shootCommand = SKSpriteNode(imageNamed: "swipeUp")
        self.addChild(shootCommand)
        shootCommand.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        shootCommand.setScale(0.5)
        shootCommand.zPosition = 4
        shootCommand.runAction(SKAction.sequence([
            SKAction.fadeInWithDuration(0.5),
            SKAction.waitForDuration(0.5),
            SKAction.fadeOutWithDuration(0.5),
            SKAction.fadeInWithDuration(0.5),
            SKAction.waitForDuration(0.5),
            SKAction.fadeOutWithDuration(0.5),
            SKAction.fadeInWithDuration(0.5),
            SKAction.waitForDuration(0.5),
            SKAction.fadeOutWithDuration(0.5),
            SKAction.removeFromParent()
            ]))
        
        bossNode.position = CGPoint(x: self.frame.width/2,y: 600)
        bossNode.runAction(SKAction.sequence([(SKAction.moveToY(self.frame.height * 0.85, duration: 2)),
            SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight]))]))
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action:#selector(GameScene.swipe(_:)))
        swipeUp.direction = .Up
        self.view!.addGestureRecognizer(swipeUp)
        self.boss = bossNode
    }
    
    func startBackgroundMusic()
    {
        if let bgMusic = self.setupAudioPlayerWithFile("musicbyMicahVellian", type:"wav") {
            self.bgMusic = bgMusic
        }
        self.bgMusic!.play()
        self.bgMusic?.numberOfLoops = -1
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
    
    func swipe(sender:UISwipeGestureRecognizer){
        
        var swipeLocation: CGPoint = sender.locationInView(sender.view)
        swipeLocation = self.convertPointFromView(swipeLocation)
        
        let blastPath = NSBundle.mainBundle().pathForResource("extinguisher", ofType: "sks")
        let blastNode = SKReferenceNode (URL: NSURL (fileURLWithPath: blastPath!))
        
        if blastTimer >= 0.5 {
            self.addChild(blastNode)
            
            blastNode.zPosition = 3
            blastNode.position = CGPointMake(hero.position.x, (self.frame.height * 0.11))
            
            blastNode.runAction(SKAction.sequence([
                
                SKAction.moveToY(600, duration: 1),
                SKAction.waitForDuration(3),
                SKAction.removeFromParent()
                ]))
            hero.removeActionForKey("move")

            blastTimer = 0
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        

        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        hero.physicsBody?.applyForce(CGVectorMake(0.0, 10.0))
        
        
        //runner mode controls
        
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
        

    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
        
        /* Skip game update if game no longer active */
        if gameState != .Active { return }
        hero.physicsBody?.applyForce(CGVectorMake(0.0, heroForce))
        hero.position.x.clamp(10, 310)
        hero.position.y.clamp(0, 560)
        sinceTouch += fixedDelta
        
        scrollWorld()
        updateObstacles()
        spawnTimer+=fixedDelta
        smokeTimer+=fixedDelta
        goalTimer+=fixedDelta
        babyRescueTimer+=fixedDelta
        bossHitTimer+=fixedDelta
        blastTimer+=fixedDelta
        
        
        
        if (move == .Left) {
            hero.position.x -= moveSpeed * CGFloat(fixedDelta)
        } else if (move == .Right) {
            hero.position.x += moveSpeed * CGFloat(fixedDelta)
        }
        
        if points > Int(highScoreLabel.text!) {
            highScoreLabel.text = String(points)
            highScoreLabel2.text = String(points)
            

            
        }
        //store new high score and display high score
        if points > NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel") && cheating == false {
            
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
        

        //add baby power ups every 300 points after 500
  
        if points >= 5000 && lastPoints < 5000 {
            obstacleLayer.removeAllChildren()
            variableLayer.removeAllChildren()
            fireBallsRand = 1
            fireBallTimer = Double(arc4random_uniform(fireBallsRand)) + 1
            self.spawnBoss()
        }
        
        //action for spawning fireballs
        if fireBallTimer > 0 {
            fireBallTimer -= fixedDelta
            if fireBallTimer < 0 {
                let fireBallPath = NSBundle.mainBundle().pathForResource("fireball", ofType: "sks")
                let fireBallNode = SKReferenceNode (URL: NSURL (fileURLWithPath: fireBallPath!))
                self.addChild(fireBallNode)
                fireBallNode.zPosition = 3
                
                fireBallNode.runAction(SKAction.sequence([
                    SKAction.waitForDuration(3),
                    SKAction.removeFromParent()
                    ]))
                
                if self.boss == nil {
                    fireBallNode.position = CGPointMake(CGFloat.random(min: 20, max:300), 568)
                }
                else {
                    // boss mode
                    
                    fireBallNode.position = CGPoint(x: boss.position.x, y: boss.position.y - 50)
                    fireBallTimer = Double(CGFloat.random())
                    boss.childNodeWithName("//boss")!.runAction(SKAction(named: "bossShoot")!)

                }
            }
        }
        
        if self.boss != nil {
            lastPoints = points
            return
        }
        
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
                    babyNode.name = "baby"
                    babyNode.zPosition = 1
                    babyNode.position = self.convertPoint(randomBabyPosition, toNode: obstacleLayer)

                }
            }

            //spawn fireballs that RAIN from the sky after 500 points and set timer for next fireball
            
            if points >= 1500 && Int(points / fireBallsRate) != Int(lastPoints / fireBallsRate) {
                
                fireBallTimer = Double(arc4random_uniform(fireBallsRand)) + 1
                
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
                    
                    if obstacle.name == "baby" {
                        
                        
                        self.runAction(SKAction.playSoundFileNamed("screamingBaby", waitForCompletion: false))
                        
                        print("wah")
                        babyCounter = 0
                        
                    }

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
                        let randomPosition = CGPointMake( CGFloat.random(min: 0, max: 340), 569)
                        fireWall.position = self.convertPoint(randomPosition, toNode: variableLayer)
                        smokeTimer = 0
                        
                    }

                }
                
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
            

            if self.hero.physicsBody!.contactTestBitMask == 0 {
                // we're invincible
                return
            }
            
            /* Change game state to game over */
            gameState = .GameOver
            self.removeAllActions()
            
            let heroDeath = SKAction.runBlock({
                
                self.runAction(SKAction.playSoundFileNamed("zachFail", waitForCompletion: false))
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
            self.soundButton.hidden = false
            if self.bgMusic?.playing == true
            {
                self.bgMusic!.stop()
            }
            
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
                
                if nodeA.name == "baby" {
                    nodeA.parent!.parent!.removeFromParent()
                }
                else {
                    nodeB.parent!.parent!.removeFromParent()
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
                
                let seconds = 4.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    self.scrollSpeed += 40
                    self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.8)
                    self.heroForce = 20
                })
                heroForce = 10
                scrollSpeed -= 40
                moveSpeed += 25
                physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.8)
                babyCounter += 1
                if babyCounter < 3 {
                    self.runAction(SKAction.playSoundFileNamed("screamingPaul", waitForCompletion: false))
                }
                print(babyCounter)
                
                babyRescueTimer = 0
                
                if babyCounter >= 3 {
                    
    

                    self.hero.physicsBody!.collisionBitMask = 0
                    self.hero.physicsBody!.contactTestBitMask = 0
                    
                    hero.runAction(SKAction.sequence([
                        SKAction.playSoundFileNamed("Elieee", waitForCompletion: false),

                        SKAction.init(named: "3babies")!,
                        SKAction.runBlock({
                            self.hero.physicsBody!.collisionBitMask = 7
                            self.hero.physicsBody!.contactTestBitMask = 4294967295
                        })
                        ]))
                    points += 50
                    babyCounter = 0
                }
            
                
            }
            
        } else if (nodeA.name == "blast" && nodeB.name == "fireball") || (nodeB.name == "blast" && nodeA.name == "fireball") {
        
            self.runAction(SKAction.playSoundFileNamed("jACKsss", waitForCompletion: false))

            if nodeA.name == "blast" {
                nodeA.parent!.parent!.removeFromParent()
            }
            else {
                nodeB.parent!.parent!.removeFromParent()
            }
            
        }else if (nodeA.name == "blast" && nodeB.name == "boss") || (nodeB.name == "blast" && nodeA.name == "boss") {
            
            var hitPosition: CGPoint?
            if bossHitTimer >= 0.4 {
                if nodeA.name == "boss" {
                    
                    hitPosition = nodeA.parent!.parent!.position

                    points += 100
                    nodeA.runAction(SKAction(named: "hit")!)
                    self.runAction(SKAction.playSoundFileNamed("jACKsss", waitForCompletion: false))
                    self.runAction(SKAction.playSoundFileNamed("olJack", waitForCompletion: false))

                    scoreLabel.text = String(points)
                    scoreLabel2.text = String(points)
                    
                    let hunnid = SKSpriteNode(imageNamed: "hunnid")
                    self.addChild(hunnid)
                    hunnid.position = hitPosition!
                    hunnid.setScale(0.7)
                    hunnid.zPosition = 10
                    hunnid.runAction(SKAction.sequence([
                        SKAction.moveToY(hitPosition!.y + (100), duration: 1),
                        //SKAction.waitForDuration(1),
                        SKAction.fadeOutWithDuration(0.5),
                        SKAction.removeFromParent()
                        ]))
                    bossHitTimer = 0
                }
                else {
                    
                    hitPosition = nodeB.parent!.parent!.position
                 
                    points += 100
                    nodeB.runAction(SKAction(named: "hit")!)
                    self.runAction(SKAction.playSoundFileNamed("jACKsss", waitForCompletion: false))
                    self.runAction(SKAction.playSoundFileNamed("olJack", waitForCompletion: false))

                    scoreLabel.text = String(points)
                    scoreLabel2.text = String(points)
                    let hunnid = SKSpriteNode(imageNamed: "hunnid")
                    self.addChild(hunnid)
                    hunnid.position = hitPosition!
                    hunnid.setScale(0.7)
                    hunnid.zPosition = 4
                    hunnid.runAction(SKAction.sequence([
                        SKAction.moveToY(hitPosition!.y + (100), duration: 2),
                        //SKAction.waitForDuration(1),
                        SKAction.fadeOutWithDuration(0.5),
                        SKAction.removeFromParent()
                        ]))
                    bossHitTimer = 0
                }
            }
        
        }
    
    }
    
}
