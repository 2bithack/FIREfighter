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
    var scoreLabel: SKLabelNode!
    var pauseButton: MSButtonNode!
    var playButton: MSButtonNode!
    var replayButton: MSButtonNode!
    
    var points = 0
    var sinceTouch: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 //60 fps
    let scrollSpeed: CGFloat = 200
    
    
    
    override func didMoveToView(view: SKView) {
        //load hero
        
        hero = self.childNodeWithName("//hero") as! SKSpriteNode
        scrollLayer = self.childNodeWithName("scrollLayer")
        physicsWorld.contactDelegate = self
        pauseButton = self.childNodeWithName("pauseButton") as! MSButtonNode
        scoreLabel = self.childNodeWithName("scoreLabel") as! SKLabelNode
        playButton = self.childNodeWithName("playButton") as! MSButtonNode
        replayButton = self.childNodeWithName("replayButton") as! MSButtonNode
        
        //play button action
        playButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            
        }
        playButton.state = .Hidden
        
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
        
        /* Called when a touch begins */
        
        for touch in touches {
            /* Get touch position in scene */
            let location = touch.locationInNode(self)
            

            hero.runAction(SKAction.moveToX(location.x, duration: 0.2))//, withKey: "moveAction")
        }
    }
   
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        
        /* Called when a touch moves */
        
        for touch in touches {
            /* Get touch position in scene */
            let location = touch.locationInNode(self)

            hero.runAction(SKAction.moveToX(location.x, duration: 0.2))//, withKey: "moveAction")
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* Disable touch if game state is not active */
        if gameState != .Active { return }
        
        hero.physicsBody?.velocity = CGVectorMake(0, 0)
        
        //hero.removeActionForKey("moveAction")
        
        /* Called when a touch ends */
        

    }
    
    override func update(currentTime: CFTimeInterval) {
        
        /* Skip game update if game no longer active */
        if gameState != .Active { return }
        
        
        sinceTouch += fixedDelta
        
        scrollWorld()
        updateObstacles()
        spawnTimer+=fixedDelta
    }
    
    func scrollWorld(){
        //world scroll
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        //obstacle scroll
        obstacleLayer = self.childNodeWithName("obstacleLayer")!
        
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
        /* Update Obstacles */
        
        obstacleLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convertPoint(obstacle.position, toNode: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.y <= -10 {
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.0 {
            
            /* Create a new obstacle reference object using a resource path*/
            let resourcePath = NSBundle.mainBundle().pathForResource("variableWall", ofType: "sks")
            let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            obstacleLayer.addChild(newObstacle)
            
            /* Generate new obstacle position, start just outside screen and with a random x value */
            let randomPosition = CGPointMake( CGFloat.random(min: -140, max: 140), 568)
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convertPoint(randomPosition, toNode: obstacleLayer)
            
            
            // Reset spawn timer
            spawnTimer = 0
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
        if nodeA.name == "goal" || nodeB.name == "goal" {
            
            /* Increment points */
            points += 1
            
            /* Update score label */
            scoreLabel.text = String(points)
            
            /* We can return now */
            return
        }
        
        /* Ensure only called while game running */
        if gameState != .Active { return }
        
        
        /* Change game state to game over */
       // gameState = .GameOver
        

        
        hero.removeAllActions()
        
        /* Show restart button */
        //playButton.state = .Active
        
        /* Create our hero death action */
//        let heroDeath = SKAction.runBlock({
//            
//            /* Put our hero face down in the dirt */
//            self.hero.zRotation = CGFloat(-90).degreesToRadians()
//            /* Stop hero from colliding with anything else */
//            self.hero.physicsBody?.collisionBitMask = 0
//        })
//        
//        /* Run action */
//        hero.runAction(heroDeath)
        

        

    }
    
}
