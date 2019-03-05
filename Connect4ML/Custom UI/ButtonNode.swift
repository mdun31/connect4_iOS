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
    var bgColor: UIColor = .gray {
        didSet {
            buttonSprite.color = bgColor
        }
    }
    
    var bgHighlightColor: UIColor { return bgColor.withAlphaComponent(0.5) }
    
    init(label: String, action:@escaping ()->Void, anchorPoint: CGPoint) {
        onTouchUpAction = action
        labelNode = SKLabelNode(text: label)
        labelNode.fontColor = .black
        labelNode.position = CGPoint(x: 0, y: -12.5)
        buttonSprite = SKSpriteNode(color: bgColor, size: CGSize(width: labelNode.frame.width + 20, height: 50))
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
            buttonSprite.color = bgColor
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if buttonSprite.contains(touch.location(in: self)) {
            buttonSprite.color = bgHighlightColor
        } else {
            buttonSprite.color = bgColor
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if buttonSprite.contains(touch.location(in: self)) {
            onTouchUpAction()
        }
        buttonSprite.color = bgColor
    }
}
