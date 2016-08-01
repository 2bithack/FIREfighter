//
//  GameScene.swift
//  FIREfighter
//
//  Created by enzo bot on 6/29/16.
//  Copyright (c) 2016 GarbageGames. All rights reserved.
//

import SpriteKit
import Foundation

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
    var pauseButton: MSButtonNode!
    var playButton: MSButtonNode!
    var replayButton: MSButtonNode!
    
    var points = 0
    var sinceTouch: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    var fireTimer: CFTimeInterval = 0
    var goalTimer: CFTimeInterval = 0

    
    let fixedDelta: CFTimeInterval = 1.0/60.0 //60 fps
    var moveSpeed: CGFloat = 275
    var scrollSpeed: CGFloat = 120
    var lastPoints = 0
    var reset: Bool = false
    var heroForce: CGFloat = 20.0
    
    
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
            
            
        }
        
        
        scoreLabel.text = String(points)
        scoreLabel2.text = String(points)


    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        hero.physicsBody?.applyForce(CGVectorMake(0.0, 5.0))

        
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
        
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        //let moveAction = "moveAction"
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        
        /* Called when a touch moves */

        
//        for touch in touches {
//            /* Get touch position in scene */
//            let location = touch.locationInNode(self)
//
//            hero.runAction(SKAction.moveToX(location.x, duration: 0.5))//, withKey: "moveAction")
//        }
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
        fireTimer+=fixedDelta
        goalTimer+=fixedDelta
        
        if (move == .Left) {
            hero.position.x -= moveSpeed * CGFloat(fixedDelta)
        } else if (move == .Right) {
            hero.position.x += moveSpeed * CGFloat(fixedDelta)
        }
        
        if points > Int(highScoreLabel.text!) {
            highScoreLabel.text = String(points)
        }
        
        if points > NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel") {
            NSUserDefaults.standardUserDefaults().setInteger(points, forKey: "highScoreLabel")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        highScoreLabel.text = "High Score: " + String(NSUserDefaults.standardUserDefaults().integerForKey("highScoreLabel"))
        
    }
    
    func scrollWorld(){
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
        var wallSpawnRate = 0.6
        var fireWallRate: UInt32 = 6
        
        if Int(points / 250) != Int(lastPoints / 250) {
            fireWallRate -= 2
            scrollSpeed += 20
            moveSpeed += 25
            wallSpawnRate -= 0.1
            
        }
        
        lastPoints = points
        //maximum smoke wall spawn rate
        if Float(fireWallRate) <= Float(-2) {
            fireWallRate = 1
        }
        //maximum wall obstacle spawn rate
        if  wallSpawnRate <= 0.0 {
            wallSpawnRate = 0.005
        }
        //maximum firefighter movement speed
        if moveSpeed >= 600 {
            moveSpeed = 600
        }
        //maximum scroll speed
        if scrollSpeed >= 320{
            scrollSpeed = 320
            heroForce = 30.0
        }
        
        
        /* Time to add a new obstacle? */
        if spawnTimer >= wallSpawnRate {
            

            
            /* Create an array of obstacles */
            let filenames = ["twoMidCB", "twoEndCB", "rightEndWallCB", "leftEndWallCB", "threeMidCO", "threeEndCO", "twoLMidCO", "twoRMidCO", "variableWall2"]
            
            // represent the selected obstacle from array
            let filename = filenames[random() % filenames.count]
            
            if Int(points / 250) != Int(lastPoints / 250){
                let babyPath = NSBundle.mainBundle().pathForResource("baby", ofType: "sks")
                let babyNode = SKReferenceNode (URL: NSURL (fileURLWithPath: babyPath!))
                let randomBabyPosition = CGPointMake(CGFloat.random(min: 20, max: 300), 556)
                obstacleLayer.addChild(babyNode)
                babyNode.zPosition = 1
                babyNode.position = self.convertPoint(randomBabyPosition, toNode: obstacleLayer)
                
            }
            
            
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
                let randomFire = Float(arc4random_uniform(fireWallRate) + 1) * 0.5
                
                //smoke wall spawn rate
                if Float(fireTimer) >= randomFire {
                    let moveLeft = SKAction.moveToX(-180, duration: 1.4)
                    let moveRight = SKAction.moveToX(340, duration: 1.4)
                    
                    let firePath = NSBundle.mainBundle().pathForResource("fireWall", ofType: "sks")
                    
                    let fireWall = SKReferenceNode (URL: NSURL (fileURLWithPath: firePath!))
                    fireWall.runAction(SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight])))

                    variableLayer.addChild(fireWall)
                    /* Generate new obstacle position, start just outside screen and with a random x value */
                    let randomPosition = CGPointMake( CGFloat.random(min: -180, max: 340), 569)
                    fireWall.position = self.convertPoint(randomPosition, toNode: variableLayer)
                    fireTimer = 0
                    
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
            
        } else if nodeA.name == "kill" && nodeB.name == "hero" || nodeB.name == "kill" && nodeA.name == "hero" {
            
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
            /* We can return now */
            return
        }
        
        /* Ensure only called while game running */
        if gameState != .Active { return }
        
        
        /* Change game state to game over */
        //gameState = .GameOver
        //hero.removeAllActions()
        
        /* Show restart button */
        //playButton.state = .Active
        
        

    }
    
}
