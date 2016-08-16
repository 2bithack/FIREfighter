//
//  about.swift
//  FIREfighter
//
//  Created by enzo bot on 8/15/16.
//  Copyright © 2016 GarbageGames. All rights reserved.
//

import Foundation
import SpriteKit


class CreditsScene: SKScene {
    
    var back: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        self.view?.multipleTouchEnabled = false
        
        back = self.childNodeWithName("back") as! SKSpriteNode
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if back.containsPoint(location)
            {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = MainScene(fileNamed:"MainMenuScene")
                
                /* Ensure correct aspect mode */
                scene!.scaleMode = .AspectFit
                
                /* Show debug */
                skView.showsPhysics = false
                skView.showsDrawCount = false
                skView.showsFPS = false
                
                

                
                /* Start game scene */
                skView.presentScene(scene)
                
            }
        }
    }
}