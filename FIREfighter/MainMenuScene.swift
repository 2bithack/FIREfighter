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
    
    override func didMove(to view: SKView) {
        
        self.view?.isMultipleTouchEnabled = false

        
        baby1 = self.childNode(withName: "baby1") as! SKSpriteNode
        baby2 = self.childNode(withName: "baby2") as! SKSpriteNode
        baby3 = self.childNode(withName: "baby3") as! SKSpriteNode
        about = self.childNode(withName: "about") as! SKSpriteNode
        
        
        let intro = SKAction.playSoundFileNamed("FirefighterIntro.wav", waitForCompletion: false)
        self.run(intro)
        
        /* Setup your scene here */
        if let bool = UserDefaults.standard.object(forKey: "playSound") as! Bool?
        {
            playSound = bool
        } else
        {
            playSound = true
        }
        
        if let bool2 = UserDefaults.standard.object(forKey: "cheating") as! Bool?
        {
            cheating = bool2
        } else
        {
            cheating = false
        }
        
        /* Set UI connections */
        buttonPlay = self.childNode(withName: "buttonPlay") as! MSButtonNode
        /* Setup restart button selection handler */
        buttonPlay.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFit
            
            /* Show debug */
            skView?.showsPhysics = false
            skView?.showsDrawCount = false
            skView?.showsFPS = false
            
            /* Start game scene */
            skView?.presentScene(scene)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {
            
            let location = touch.location(in: self)
            
            if baby2.contains(location) {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene?.scaleMode = .aspectFit
                
                /* Show debug */
                skView?.showsPhysics = false
                skView?.showsDrawCount = false
                skView?.showsFPS = false
                
                scene?.points = 5000
                cheating = true
                
                /* Start game scene */
                skView?.presentScene(scene)
                
            }
            
            if baby3.contains(location) {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene?.scaleMode = .aspectFit
                
                /* Show debug */
                skView?.showsPhysics = false
                skView?.showsDrawCount = false
                skView?.showsFPS = false
                
                scene?.points = 590
                
                /* Start game scene */
                skView?.presentScene(scene)
                
            }
            
            if baby1.contains(location) {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = GameScene(fileNamed:"GameScene") as GameScene!
                
                /* Ensure correct aspect mode */
                scene?.scaleMode = .aspectFit
                
                /* Show debug */
                skView?.showsPhysics = false
                skView?.showsDrawCount = false
                skView?.showsFPS = false
                
                UserDefaults.standard.set(0, forKey: "highScoreLabel")
                UserDefaults.standard.set(0, forKey: "highScoreLabel2")
                UserDefaults.standard.synchronize()

                /* Start game scene */
                skView?.presentScene(scene)

            }
            
            if about.contains(location) {
                let skView = self.view as SKView!
                let scene = CreditsScene(fileNamed:"CreditsScene") as CreditsScene!
                scene?.scaleMode = .aspectFit
                skView?.presentScene(scene)
            }
            
        }
        
    }
    
}
