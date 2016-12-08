//
//  GameScene.swift
//  FIREfighter
//
//  Created by enzo bot on 6/29/16.
//  Copyright (c) 2016 GarbageGames. All rights reserved.
//

import SpriteKit
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

import Foundation
import AVFoundation



fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

/* Social profile structure */
struct Profile {
    var name = ""
    var imgURL = ""
    var facebookId = ""
    var score = 0
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    /* High score custom dictionary */
    var topScores: [Profile]!
    
    /* Firebase connection */
//    let firebaseRef = FIRDatabase.database().reference(withPath: "highscore")
    let firebaseRef = FIRDatabase.database().reference().child("highscore")
    
    
    enum GameSceneState {
        case active, gameOver, pause
    }
    
    enum Move {
        case none, left, right
    }
    
    var move: Move = .none
    
    var points: Int = 0
    var gameState: GameSceneState = .active
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
    
    override var isPaused: Bool {
        get {
            return super.isPaused
        }
        set {
            if (newValue || !GameScene.stayPaused) {
                super.isPaused = newValue
            }
            GameScene.stayPaused = false
        }
    }
    
    
    override func didMove(to view: SKView) {
       
        firebaseRef.queryOrdered(byChild: "score").queryLimited(toLast: 5).observe(.value, with: { snapshot in
            
            /* Check snapshot has results */
            if snapshot.exists() {
                
                /* Loop through data entries */
                self.topScores = []

                for child in snapshot.children {
                    
                    /* Create new player profile */
                    var profile = Profile()
                                        
                    /* Assign player name */
                    profile.name = (child as AnyObject).key
                    let valueDict = snapshot.childSnapshot(forPath: profile.name).value as! [String: AnyObject]
                    
                    /* Assign profile data */
                    //profile.imgURL = valueDict["image"] as! String
                    profile.score = valueDict["score"] as! Int
                    profile.facebookId = valueDict["id"] as! String
                    /* Add new high score profile to score tower using score as index */
                    
                    self.topScores.append(profile)
                    
                    print("\n\n\n\(profile.score)\n\n\n")
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadAds"), object: nil)
        
        self.view?.isMultipleTouchEnabled = false

        //cage the scene
        super.didMove(to: view)
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        //load hero
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
        scrollLayer = self.childNode(withName: "scrollLayer")
        physicsWorld.contactDelegate = self
        soundButton = self.childNode(withName: "sound") as! MSButtonNode
        pauseButton = self.childNode(withName: "pauseButton") as! MSButtonNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel2 = self.childNode(withName: "scoreLabel2") as! SKLabelNode
        highScoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScoreLabel"))
        
        highScoreLabel2 = self.childNode(withName: "highScoreLabel2") as! SKLabelNode
        highScoreLabel2.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScoreLabel2"))


        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        replayButton = self.childNode(withName: "replayButton") as! MSButtonNode
//        tapLeft = self.childNodeWithName("//tapLeft")
//        tapRight = self.childNodeWithName("//tapRight")
        tap = self.childNode(withName: "//tap")
        
        soundButton.isHidden = true

        
        highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScoreLabel"))
        highScoreLabel2.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScoreLabel2"))
//button settings to load game on fresh start and different settings when reset
        
        if self.reset == false {
            self.gameState = .pause
            self.pauseButton.state = .hidden
            pauseButton.isHidden = true
            self.playButton.state = .active
            self.replayButton.state = .hidden
            replayButton.isHidden = true
            
            
        }  else if self.reset == true {
            self.gameState = .active
            self.playButton.isHidden = true
            self.playButton.state = .hidden
            self.pauseButton.state = .active
            self.pauseButton.isHidden = false
            self.replayButton.isHidden = true
            self.replayButton.state = .hidden
            self.physicsWorld.speed = 1
            self.highScoreLabel.isHidden = true
            self.highScoreLabel2.isHidden = true
            
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

            UserDefaults.standard.set(playSound, forKey: "playSound")
        }
        
        
        pauseButton.selectedHandler = {
            self.pauseButton.isHidden = true
            self.soundButton.isHidden = false
            self.replayButton.isHidden = false
            self.replayButton.state = .active
            self.playButton.state = .active
            self.playButton.isHidden = false
            self.gameState = .pause
            self.physicsWorld.speed = 0
            self.highScoreLabel.isHidden = false
            self.highScoreLabel2.isHidden = false
            
            self.isPaused = true
            
            if let _ = self.bgMusic
            {
                self.bgMusic!.stop()
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showAds"), object: nil)

        }
        
        replayButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            scene?.reset = true

            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFit//.AspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            
            
            self.reset = true
            
        }
        
        //play button action
        playButton.selectedHandler = {
            
            self.gameState = .active
            self.playButton.isHidden = true
            self.soundButton.isHidden = true
            self.playButton.state = .hidden
            self.pauseButton.state = .active
            self.pauseButton.isHidden = false
            self.replayButton.isHidden = true
            self.replayButton.state = .hidden
            self.physicsWorld.speed = 1
            self.highScoreLabel.isHidden = true
            self.highScoreLabel2.isHidden = true
            self.isPaused = false
            if playSound == true
            {
                self.startBackgroundMusic()
            }
                        
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideAds"), object: nil)
        }
        
        
        scoreLabel.text = String(points)
        scoreLabel2.text = String(points)
        

        //mute music preference stored
        if let bool = UserDefaults.standard.object(forKey: "playSound") as! Bool?
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
        
        GameViewController.loginButton.isHidden = true
        
    }
    
    func spawnBoss() {
        
        hero.physicsBody!.isDynamic = false
        
        //move to firefighter to locked y position
        hero.run(SKAction.move(to: CGPoint(x: hero.position.x, y: self.frame.height * 0.1), duration: 1))
        //hero.position.y = (self.frame.height * 0.1)
        
        //load fireboss
        let bossPath = Bundle.main.path(forResource: "fireBoss", ofType: "sks")
        let bossNode = SKReferenceNode (url: URL (fileURLWithPath: bossPath!))
        let moveLeft = SKAction.moveTo(x: 0, duration: 1.4)
        let moveRight = SKAction.moveTo(x: 300, duration: 1.4)
        self.addChild(bossNode)
        
        let shootCommand = SKSpriteNode(imageNamed: "swipeUp")
        self.addChild(shootCommand)
        shootCommand.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        shootCommand.setScale(0.5)
        shootCommand.zPosition = 4
        shootCommand.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
            ]))
        
        bossNode.position = CGPoint(x: self.frame.width/2,y: 600)
        bossNode.run(SKAction.sequence([(SKAction.moveTo(y: self.frame.height * 0.85, duration: 2)),
            SKAction.repeatForever(SKAction.sequence([moveLeft, moveRight]))]))
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action:#selector(GameScene.swipe(_:)))
        swipeUp.direction = .up
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
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer?  {
        
        let soundFilePath = Bundle.main.path(forResource: "musicbyMicahVellian", ofType: "wav")
        let soundFileURL = URL(fileURLWithPath: soundFilePath!)
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: soundFileURL)
        } catch {
            print("Player not available")
        }
        return audioPlayer
    }
    
    func swipe(_ sender:UISwipeGestureRecognizer){
        
        var swipeLocation: CGPoint = sender.location(in: sender.view)
        swipeLocation = self.convertPoint(fromView: swipeLocation)
        
        let blastPath = Bundle.main.path(forResource: "extinguisher", ofType: "sks")
        let blastNode = SKReferenceNode (url: URL (fileURLWithPath: blastPath!))
        
        if blastTimer >= 0.5 {
            self.addChild(blastNode)
            
            blastNode.zPosition = 3
            blastNode.position = CGPoint(x: hero.position.x, y: (self.frame.height * 0.11))
            
            blastNode.run(SKAction.sequence([
                
                SKAction.moveTo(y: 600, duration: 1),
                SKAction.wait(forDuration: 3),
                SKAction.removeFromParent()
                ]))
            hero.removeAction(forKey: "move")

            blastTimer = 0
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        

        /* Disable touch if game state is not active */
        if gameState != .active { return }
        
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        hero.physicsBody?.applyForce(CGVector(dx: 0.0, dy: 10.0))
        
        
        //runner mode controls
        
            for touch in touches {
                let location = touch.location(in: self)
                if move == .none
                {
                    if location.x >= self.size.width / 2
                    {
                        move = .left
                    } else if location.x <= self.size.width / 2
                    {
                        move = .right
                    }
                }
            }
            /* Called when a touch begins */
            switch move
            {
                case .none:
                    break
                case .right:
                    move = .left
                case .left:
                    move = .right
            }
            
            //controls for boss level
        }
        
    
   
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .active { return }
        //let moveAction = "moveAction"
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .active { return }
        
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        
        /* Skip game update if game no longer active */
        if gameState != .active { return }
        hero.physicsBody?.applyForce(CGVector(dx: 0.0, dy: heroForce))
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
        
        
        
        if (move == .left) {
            hero.position.x -= moveSpeed * CGFloat(fixedDelta)
        } else if (move == .right) {
            hero.position.x += moveSpeed * CGFloat(fixedDelta)
        }
        
//        if points > Int(highScoreLabel.text!) {
//            highScoreLabel.text = String(points)
//            highScoreLabel2.text = String(points)
//            
//
//            
//        }
        //store new high score and display high score
        if points > UserDefaults.standard.integer(forKey: "highScoreLabel") && cheating == false {
            
            if boolHighScore == false {
                let congrats = Bundle.main.path(forResource: "newHighScore", ofType: "sks")
                let newHighScore = SKReferenceNode (url: URL (fileURLWithPath: congrats!))
                
                self.addChild(newHighScore)
                newHighScore.zPosition = 1
                newHighScore.position = CGPoint(x: 0, y: self.size.height/2)
                newHighScore.run(SKAction.sequence([
                    SKAction.fadeIn(withDuration: 0.5),
                    SKAction.fadeOut(withDuration: 1),
                    SKAction.removeFromParent()
                    ]))
                boolHighScore = true
            }
            
//            UserDefaults.standard.set(points, forKey: "highScoreLabel")
//            UserDefaults.standard.set(points, forKey: "highScoreLabel2")
//            UserDefaults.standard.synchronize()
        }
        
//        highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScoreLabel"))
//        highScoreLabel2.text = "High Score: " + String(UserDefaults.standard.integer(forKey: "highScoreLabel2"))
        
        
    }
    
    func scrollWorld() {
        //world scroll
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        //obstacle scroll
        obstacleLayer = self.childNode(withName: "obstacleLayer")!
        variableLayer = self.childNode(withName: "variableLayer")!
        
        //loop scroll layer nodes
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            //get ground node position, convert node position to scene space
            let floorPosition = scrollLayer.convert(ground.position, to: self)
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
                let fireBallPath = Bundle.main.path(forResource: "fireball", ofType: "sks")
                let fireBallNode = SKReferenceNode (url: URL (fileURLWithPath: fireBallPath!))
                self.addChild(fireBallNode)
                fireBallNode.zPosition = 3
                
                fireBallNode.run(SKAction.sequence([
                    SKAction.wait(forDuration: 3),
                    SKAction.removeFromParent()
                    ]))
                
                if self.boss == nil {
                    fireBallNode.position = CGPoint(x: CGFloat.random(min: 20, max:300), y: 568)
                }
                else {
                    // boss mode
                    
                    fireBallNode.position = CGPoint(x: boss.position.x, y: boss.position.y - 50)
                    fireBallTimer = Double(CGFloat.random())
                    boss.childNode(withName: "//boss")!.run(SKAction(named: "bossShoot")!)

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
                    let babyPath = Bundle.main.path(forResource: "baby", ofType: "sks")
                    let babyNode = SKReferenceNode (url: URL (fileURLWithPath: babyPath!))
                    let randomBabyPosition = CGPoint(x: CGFloat.random(min: 40, max: 280), y: 556)
                    obstacleLayer.addChild(babyNode)
                    babyNode.name = "baby"
                    babyNode.zPosition = 1
                    babyNode.position = self.convert(randomBabyPosition, to: obstacleLayer)

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
                let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
                
                /* Check if obstacle has left the scene */
                if obstaclePosition.y <= -20 {
                    
                    /* Remove obstacle node from obstacle layer */
                    
                    if obstacle.name == "baby" {
                        
                        
                        self.run(SKAction.playSoundFileNamed("screamingBaby", waitForCompletion: false))
                        
                        print("wah")
                        babyCounter = 0
                        
                    }

                    obstacle.removeFromParent()
                    
                }

            }
            
            /* Loop through variable obstacle layer nodes */
            for variableObstacle in variableLayer.children as! [SKReferenceNode] {
                
                /* Get obstacle node position, convert node position to scene space */
                let variablePosition = variableLayer.convert(variableObstacle.position, to: self)
                
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
                let filename = filenames[Int(arc4random()) % filenames.count]
                
                //set variable wall position
                if filename == "variableWall2" {
                    
                    let resourcePath = Bundle.main.path(forResource: filename, ofType: "sks")
                    let randomPosition = CGPoint( x: CGFloat.random(min: -270, max: 0), y: 568)
                    
                    let newObstacle = SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))

                    obstacleLayer.addChild(newObstacle)
                    newObstacle.position = self.convert(randomPosition, to: variableLayer)
                    spawnTimer = 0
                }
                //send in the other walls
                else {
                let resourcePath = Bundle.main.path(forResource: filename, ofType: "sks")
                let newObstacle = SKReferenceNode (url: URL (fileURLWithPath: resourcePath!))
                obstacleLayer.addChild(newObstacle)
                
                /* Convert new node position back to obstacle layer space */
                newObstacle.position = self.convert(CGPoint(x: 0.0, y: 568.0), to: obstacleLayer)
                
                // Reset spawn timer
                spawnTimer = 0
                    
                    //add in moving smoke walls randomly
                    //set random spawn rate within range
                    let randomFire = Float(arc4random_uniform(fireWallRate) + fireWallRateBase) * 0.5
                    
                    //smoke wall spawn rate
                    if Float(smokeTimer) >= randomFire {
                        let moveLeft = SKAction.moveTo(x: -180, duration: 1.4)
                        let moveRight = SKAction.moveTo(x: 340, duration: 1.4)
                        
                        let firePath = Bundle.main.path(forResource: "fireWall", ofType: "sks")
                        
                        let fireWall = SKReferenceNode (url: URL (fileURLWithPath: firePath!))
                        fireWall.run(SKAction.repeatForever(SKAction.sequence([moveLeft, moveRight])))

                        variableLayer.addChild(fireWall)
                        /* Generate new obstacle position, start just outside screen and with a random x value */
                        let randomPosition = CGPoint( x: CGFloat.random(min: 0, max: 340), y: 569)
                        fireWall.position = self.convert(randomPosition, to: variableLayer)
                        smokeTimer = 0
                        
                    }

                }
                
            }
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
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
            gameState = .gameOver
            self.removeAllActions()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showInterstitial"), object: nil)
            let heroDeath = SKAction.run({
                
                self.run(SKAction.playSoundFileNamed("zachFail", waitForCompletion: false))
                /* Put our hero face down in the dirt */
                self.hero.zRotation = CGFloat(-90).degreesToRadians()
                /* Stop hero from colliding with anything else */
                self.hero.physicsBody?.collisionBitMask = 0
                self.hero.removeAllActions()
            })
            
            //end music
            
            /* Create our hero death action */
            hero.run(heroDeath)
            
            /* Load the shake action resource */
            let shakeScene:SKAction = SKAction.init(named: "Shake")!
            
            /* Loop through all nodes  */
            for node in self.children {
                
                /* Apply effect each ground node */
                node.run(shakeScene)
                
            }
            pauseButton.isHidden = true
            replayButton.isHidden = false
            replayButton.state = .active
            playButton.isHidden = true
            playButton.state = .hidden
            self.highScoreLabel.isHidden = false
            self.highScoreLabel2.isHidden = false
            self.soundButton.isHidden = false
            if self.bgMusic?.isPlaying == true
            {
                self.bgMusic!.stop()
            }
            
            //save score
            if points > UserDefaults.standard.integer(forKey: "highScoreLabel")  && cheating == false {
                UserDefaults.standard.set(points, forKey: "highScoreLabel")
                UserDefaults.standard.set(points, forKey: "highScoreLabel2")
                UserDefaults.standard.synchronize()
                
                highScoreLabel.text = "High Score: " + String(points)
                highScoreLabel2.text = "High Score: " + String(points)
                
                // print(playerProfile)
                if !MainScene.playerProfile.facebookId.isEmpty {
                    
                    //* Update profile score */
                    MainScene.playerProfile.score = points
                    
                    /* Build data structure to be saved to firebase */
                    let saveProfile = [MainScene.playerProfile.name :
                        ["score" : MainScene.playerProfile.score,
                         "id" : MainScene.playerProfile.facebookId ]]
                    
                    /* Save to Firebase */
                    firebaseRef.updateChildValues(saveProfile, withCompletionBlock: {
                        (error:Error?, ref:FIRDatabaseReference!) in
                        if (error != nil) {
                            print("\n\n\nData save failed: \(error)\n\n\n")
                        } else {
                            print("\n\n\nData saved success\n\n\n")
                            
                            var y = self.highScoreLabel.position.y - 60
                            for index in stride(from: self.topScores.count - 1, through: 0, by: -1) {
                                print("\n\n\n\(index)\n\n\n")
                                let player = self.topScores[index]
                                let highScore = player.score
                                let scoreLabel = SKLabelNode(fontNamed: "8-bit pusab")
                                scoreLabel.fontSize = 14
                                scoreLabel.color = SKColor.black
                                scoreLabel.position.y = y
                                scoreLabel.position.x = self.size.width * 0.5
                                scoreLabel.text = "\(player.name): \(highScore)"
                                scoreLabel.zPosition = 5
                                //print("\(player.name): \(highScore)")
                                self.addChild(scoreLabel)
                                y -= 24
                            }
                        }
                    })
                    
                }
            }
            else {
                var y = self.highScoreLabel.position.y - 60
                for index in stride(from: self.topScores.count - 1, through: 0, by: -1) {
                    print("\n\n\n\(index)\n\n\n")
                    let player = self.topScores[index]
                    let highScore = player.score
                    let scoreLabel = SKLabelNode(fontNamed: "8-bit pusab")
                    scoreLabel.fontSize = 14
                    scoreLabel.color = SKColor.black
                    scoreLabel.position.y = y
                    scoreLabel.position.x = self.size.width * 0.5
                    scoreLabel.text = "\(player.name): \(highScore)"
                    scoreLabel.zPosition = 5
                    //print("\(player.name): \(highScore)")
                    self.addChild(scoreLabel)
                    y -= 24
                }
            }
            
            
            //display topscores
            
            
            
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
                hunnid.run(SKAction.sequence([
                    SKAction.moveTo(y: babyPosition!.y + (20), duration: 1),
                    //SKAction.waitForDuration(1),
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.removeFromParent()
                    ]))
                
                let seconds = 4.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    
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
                    self.run(SKAction.playSoundFileNamed("screamingPaul", waitForCompletion: false))
                }
                print(babyCounter)
                
                babyRescueTimer = 0
                
                if babyCounter >= 3 {
                    
    

                    self.hero.physicsBody!.collisionBitMask = 0
                    self.hero.physicsBody!.contactTestBitMask = 0
                    
                    hero.run(SKAction.sequence([
                        SKAction.playSoundFileNamed("Elieee", waitForCompletion: false),

                        SKAction.init(named: "3babies")!,
                        SKAction.run({
                            self.hero.physicsBody!.collisionBitMask = 7
                            self.hero.physicsBody!.contactTestBitMask = 4294967295
                        })
                        ]))
                    points += 50
                    babyCounter = 0
                }
            
                
            }
            
        } else if (nodeA.name == "blast" && nodeB.name == "fireball") || (nodeB.name == "blast" && nodeA.name == "fireball") {
        
            self.run(SKAction.playSoundFileNamed("jACKsss", waitForCompletion: false))

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
                    nodeA.run(SKAction(named: "hit")!)
                    self.run(SKAction.playSoundFileNamed("jACKsss", waitForCompletion: false))
                    self.run(SKAction.playSoundFileNamed("olJack", waitForCompletion: false))

                    scoreLabel.text = String(points)
                    scoreLabel2.text = String(points)
                    
                    let hunnid = SKSpriteNode(imageNamed: "hunnid")
                    self.addChild(hunnid)
                    hunnid.position = hitPosition!
                    hunnid.setScale(0.7)
                    hunnid.zPosition = 10
                    hunnid.run(SKAction.sequence([
                        SKAction.moveTo(y: hitPosition!.y + (100), duration: 1),
                        //SKAction.waitForDuration(1),
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                        ]))
                    bossHitTimer = 0
                }
                else {
                    
                    hitPosition = nodeB.parent!.parent!.position
                 
                    points += 100
                    nodeB.run(SKAction(named: "hit")!)
                    self.run(SKAction.playSoundFileNamed("jACKsss", waitForCompletion: false))
                    self.run(SKAction.playSoundFileNamed("olJack", waitForCompletion: false))

                    scoreLabel.text = String(points)
                    scoreLabel2.text = String(points)
                    let hunnid = SKSpriteNode(imageNamed: "hunnid")
                    self.addChild(hunnid)
                    hunnid.position = hitPosition!
                    hunnid.setScale(0.7)
                    hunnid.zPosition = 4
                    hunnid.run(SKAction.sequence([
                        SKAction.moveTo(y: hitPosition!.y + (100), duration: 2),
                        //SKAction.waitForDuration(1),
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                        ]))
                    bossHitTimer = 0
                }
            }
        
        }
    
    }
    
}
