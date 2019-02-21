//
//  ButtonNode.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 2/20/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

import Foundation
import SpriteKit

class ButtonNode: SKNode {
    
    var onTouchUpAction: (() -> Void)
    var buttonSprite: SKSpriteNode
    var labelNode: SKLabelNode
    
    init(label: String, action:@escaping ()->Void, anchorPoint: CGPoint) {
        onTouchUpAction = action
        buttonSprite = SKSpriteNode(color: .gray, size: CGSize(width: 200, height: 50))
        labelNode = SKLabelNode(text: label)
        labelNode.color = .black
        labelNode.position = CGPoint(x: 0, y: -12.5)
        super.init()
        
        addChild(buttonSprite)
        addChild(labelNode)
        self.position = anchorPoint
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if buttonSprite.contains(touch.location(in: self)) {
            buttonSprite.color = .lightGray
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if buttonSprite.contains(touch.location(in: self)) {
            buttonSprite.color = .lightGray
        } else {
            buttonSprite.color = .gray
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if buttonSprite.contains(touch.location(in: self)) {
            onTouchUpAction()
        }
        buttonSprite.color = .gray
    }
}
