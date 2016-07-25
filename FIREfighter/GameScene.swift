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
    
    
    
    var gameState: GameSceneState = .Active
    var hero: SKSpriteNode!
    var woodFloor: SKSpriteNode!
    var scrollLayer: SKNode!
    var obstacleLayer: SKNode!
    var variableLayer: SKNode!
    
    var scoreLabel: SKLabelNode!
    var pauseButton: MSButtonNode!
    var playButton: MSButtonNode!
    var replayButton: MSButtonNode!
    
    var points = 0
    var sinceTouch: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    var fireTimer: CFTimeInterval = 0

    
    let fixedDelta: CFTimeInterval = 1.0/60.0 //60 fps
    let scrollSpeed: CGFloat = 160
    

    
    
    override func didMoveToView(view: SKView) {
        //cage the scene
        super.didMoveToView(view)
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        
        //load hero
        
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        
        
        scrollLayer = self.childNodeWithName("scrollLayer")
        physicsWorld.contactDelegate = self
        pauseButton = self.childNodeWithName("pauseButton") as! MSButtonNode
        scoreLabel = self.childNodeWithName("scoreLabel") as! SKLabelNode
        playButton = self.childNodeWithName("playButton") as! MSButtonNode
        replayButton = self.childNodeWithName("replayButton") as! MSButtonNode
        //self.gameState = .Pause
        self.pauseButton.state = .Hidden
        
        //play button action
        playButton.selectedHandler = {
            self.gameState = .Active
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            self.playButton.state = .Hidden
            self.pauseButton.state = .Active
        }
        //playButton.state = .Hidden
        
        replayButton.hidden = true
        
        
        //pause button action
        pauseButton.selectedHandler = {
            
            self.replayButton.state = .Active
            self.replayButton.hidden = false
            self.gameState = .Pause
            self.physicsWorld.speed = 0
            
        }
        
        
        
        scoreLabel.text = String(points)

    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        hero.physicsBody?.applyForce(CGVectorMake(0.0, 5.0))

        /* Called when a touch begins */
        for touch in touches {
            /* Get touch position in scene */
            let location = touch.locationInNode(self)
                //move right
                if location.x >= hero.position.x {
                    hero.runAction(SKAction.moveToX(310, duration: 0.6), withKey: "moveAction")
                }
                //move left
                else {
                    hero.runAction(SKAction.moveToX(10, duration: 0.6), withKey: "moveAction")
                }
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
//            //move right
//            if location.x >= hero.position.x {
//                hero.runAction(SKAction.moveToX(320, duration: 0.5), withKey: "moveAction")
//            }
//                //move left
//            else {
//                hero.runAction(SKAction.moveToX(10, duration: 0.5), withKey: "moveAction")
//            }
//        }
        
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
        
        hero.removeActionForKey("moveAction")
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        /* Skip game update if game no longer active */
        if gameState != .Active { return }
        hero.physicsBody?.applyForce(CGVectorMake(0.0, 10.0))

        
        sinceTouch += fixedDelta
        
        scrollWorld()
        updateObstacles()
        spawnTimer+=fixedDelta
        fireTimer+=fixedDelta
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
            
            //check ground position has left scene
            if floorPosition.y <= -ground.size.height/2 {
                //reposition ground to second starting position
                let newPosition = CGPointMake(floorPosition.x, (self.size.height / 2 ) + ground.size.height)
                //convert new node position back to scroll layer space
                ground.position = self.convertPoint(newPosition, toNode: scrollLayer)
                
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
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 0.5 {
            
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
            
            
            /* Generate new obstacle position, start just outside screen and with a random x value */
            //let randomPosition = CGPointMake( CGFloat.random(min: -270, max: 0), 568)
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convertPoint(CGPoint(x: 0.0, y: 568.0), toNode: obstacleLayer)
            
            //fireWall.position = self.convertPoint(randomPosition, toNode: variableLayer)
            
            // Reset spawn timer
            spawnTimer = 0
                //add in moving firewalls every 5 walls
                let randomFire = Float(arc4random_uniform(10) + 4) * 0.5
                if Float(fireTimer) >= randomFire {
                    let moveLeft = SKAction.moveToX(-270, duration: 0.6)
                    let moveRight = SKAction.moveToX(270, duration: 0.6)
                    
                    let firePath = NSBundle.mainBundle().pathForResource("fireWall", ofType: "sks")
                    let fireWall = SKReferenceNode (URL: NSURL (fileURLWithPath: firePath!))
                    fireWall.runAction(SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight])))

                    variableLayer.addChild(fireWall)
                    
                    let randomPosition = CGPointMake( CGFloat.random(min: -270, max: 0), 568)
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
            
            /* Increment points */
            points += 1
            
            /* Update score label */
            scoreLabel.text = String(points)
            
            /* We can return now */
            return
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
            
            /* Run action */
            hero.runAction(heroDeath)
            
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
        
        /* Create our hero death action */

        

        

    }
    
}
