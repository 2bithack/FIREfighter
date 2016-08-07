//
//  BossFight.swift
//  FIREfighter
//
//  Created by enzo bot on 8/4/16.
//  Copyright © 2016 GarbageGames. All rights reserved.
//

import Foundation




















//
//func scrollWorld() {
//    //world scroll
//    scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
//    
//    //obstacle scroll
//    obstacleLayer = self.childNodeWithName("obstacleLayer")!
//    variableLayer = self.childNodeWithName("variableLayer")!
//    
//    
//    //loop scroll layer nodes
//    for ground in scrollLayer.children as! [SKSpriteNode] {
//        
//        //get ground node position, convert node position to scene space
//        let floorPosition = scrollLayer.convertPoint(ground.position, toNode: self)
//        //let instrucPosition = scrollLayer.convertPoint(ground.position, toNode: self)
//        
//        //check ground position has left scene
//        if floorPosition.y <= -ground.size.height/2 {
//            
//            if ground == tap {
//                ground.removeFromParent()
//            }
//            else {
//                ground.position.y += ground.size.height * 2
//                
//            }
//        }
//    }
//}