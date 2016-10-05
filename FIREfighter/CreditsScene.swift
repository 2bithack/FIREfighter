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
    
    override func didMove(to view: SKView) {
        
        self.view?.isMultipleTouchEnabled = false
        
        back = self.childNode(withName: "back") as! SKSpriteNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if back.contains(location)
            {
                /* Grab reference to our SpriteKit view */
                let skView = self.view as SKView!
                
                /* Load Game scene */
                let scene = MainScene(fileNamed:"MainMenuScene")
                
                /* Ensure correct aspect mode */
                scene!.scaleMode = .aspectFit
                
                /* Show debug */
                skView?.showsPhysics = false
                skView?.showsDrawCount = false
                skView?.showsFPS = false
                
                

                
                /* Start game scene */
                skView?.presentScene(scene)
                
            }
        }
    }
}
