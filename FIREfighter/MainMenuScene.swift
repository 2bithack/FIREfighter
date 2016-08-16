//
//  MainMenu.swift
//  FIREfighter
//
//  Created by enzo bot on 6/29/16.
//  Copyright © 2016 GarbageGames. All rights reserved.
//

import Foundation
import SpriteKit

var playSound:Bool!
var cheating:Bool!

class MainScene: SKScene {
    
    var baby1: SKSpriteNode!
    var baby2: SKSpriteNode!
    var baby3: SKSpriteNode!
    var about: SKSpriteNode!
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    
    override func didMoveToView(view: SKView) {
        
        self.view?.multipleTouchEnabled = false

        
        baby1 = self.childNodeWithName("baby1") as! SKSpriteNode
        baby2 = self.childNodeWithName("baby2") as! SKSpriteNode
        baby3 = self.childNodeWithName("baby3") as! SKSpriteNode
        about = self.childNodeWithName("about") as! SKSpriteNode
        
        
        let intro = SKAction.playSoundFileNamed("FirefighterIntro.wav", waitForCompletion: false)
        self.runAction(intro)
        
        /* Setup your scene here */
        if let bool = NSUserDefaults.standardUserDefaults().objectForKey("playSound") as! Bool?
        {
            playSound = bool
        } else
        {
            playSound = true
        }
        
        if let bool2 = NSUserDefaults.standardUserDefaults().objectForKey("cheating") as! Bool?
        {
            cheating = bool2
        } else
        {
            cheating = false
        }
        
        /* Set UI connections */
        buttonPlay = self.childNodeWithName("buttonPlay") as! MSButtonNode
        /* Setup restart button selection handler */
        buttonPlay.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            
            /* Start game scene */
            skView.presentScene(scene)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if baby2.containsPoint(location) {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .AspectFit
                
                /* Show debug */
                skView.showsPhysics = false
                skView.showsDrawCount = false
                skView.showsFPS = false
                
                scene.points = 5000
                cheating = true
                
                /* Start game scene */
                skView.presentScene(scene)
                
            }
            
            if baby3.containsPoint(location) {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .AspectFit
                
                /* Show debug */
                skView.showsPhysics = false
                skView.showsDrawCount = false
                skView.showsFPS = false
                
                scene.points = 590
                
                /* Start game scene */
                skView.presentScene(scene)
                
            }
            
            if baby1.containsPoint(location) {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene.scaleMode = .AspectFit
                
                /* Show debug */
                skView.showsPhysics = false
                skView.showsDrawCount = false
                skView.showsFPS = false
                
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScoreLabel")
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScoreLabel2")
                NSUserDefaults.standardUserDefaults().synchronize()

                /* Start game scene */
                skView.presentScene(scene)

            }
            
            if about.containsPoint(location) {
                let skView = self.view as SKView!
                let scene = CreditsScene(fileNamed:"CreditsScene") as CreditsScene!
                scene.scaleMode = .AspectFit
                skView.presentScene(scene)
            }
            
        }
        
    }
    
}