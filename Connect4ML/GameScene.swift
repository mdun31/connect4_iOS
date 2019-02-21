//
//  GameScene.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 1/28/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var board : SKSpriteNode!
    private var baseCoin : SKShapeNode!
    private var winnerLabel : SKLabelNode!
    private var dropingCoin : SKShapeNode?
    
    private lazy var coinController: CoinController = { return CoinController() }()
    private lazy var boardModel: BoardVM = { return BoardVM() }()
    
    private var boardTop: CGFloat = 0
    
    //MARK: - Init funcs
    override func didMove(to view: SKView) {
        guard let board = childNode(withName: SceneKeys.board) as? SKSpriteNode else {
            fatalError("board node not loaded")
        }
        let boardTexture = SKTexture(imageNamed: SceneKeys.boardImage)
        board.texture = boardTexture
        self.board = board
        boardTop = board.position.y + board.frame.size.height/2
        
        // Create shape node to use during mouse interaction
        let coinRadius = board.size.height/12
        baseCoin = SKShapeNode(circleOfRadius: coinRadius)
        baseCoin.fillColor = .red
        baseCoin.position = CGPoint(x: -1000, y: -1000)
        baseCoin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coinRadius*2,
                                                             height: coinRadius*2))
        generateWalls(atWidth: board.size.width/7)
        
        //get label
        guard let winnerLabel = childNode(withName: SceneKeys.winnerLabel) as? SKLabelNode else {
            fatalError("failed to load label")
        }
        winnerLabel.text = ""
        winnerLabel.fontSize = 20.0
        self.winnerLabel = winnerLabel
        
        
    }
    
    private func generateWalls(atWidth width: CGFloat) {
        let boardBeginningPos = board.position.x - board.frame.size.width/2
        for i in 0...7 {
            let dividerWall = SKShapeNode(rect: CGRect(x:boardBeginningPos + CGFloat(i) * width,
                                                       y: board.position.y - board.size.height/2,
                                                       width: 2,
                                                       height: board.size.height))
            dividerWall.fillColor = .clear
            
            dividerWall.physicsBody = SKPhysicsBody(rectangleOf: dividerWall.frame.size,
                                                    center: CGPoint(x: dividerWall.frame.origin.x, y: board.position.y))
            dividerWall.physicsBody?.allowsRotation = false
            dividerWall.physicsBody?.affectedByGravity = false
            dividerWall.physicsBody?.isDynamic = false
            
            coinController.importWalls(wallXPos: dividerWall.frame.origin.x)
            
            addChild(dividerWall)
        }
    }
    
    //MARK: - On Touch Methods
    func touchDown(atPoint pos : CGPoint) {
        if !boardModel.gameOver {
            dropingCoin = baseCoin.copy() as? SKShapeNode
            if let n = dropingCoin {
                n.fillColor = coinController.coinColor(player: boardModel.playerForTurn)
                let col = coinController.columnForTouch(xTouchPos: pos.x)
                n.position = CGPoint(x: coinController.xDropPosForCoinColumn(coinCol: col), y: boardTop)
                n.physicsBody?.affectedByGravity = false
                addChild(n)
            }
        } else {
            dropingCoin = nil
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = dropingCoin {
            let col = coinController.columnForTouch(xTouchPos: pos.x)
            n.position = CGPoint(x: coinController.xDropPosForCoinColumn(coinCol: col), y: boardTop)
        }
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = dropingCoin {
            n.physicsBody?.affectedByGravity = true
            let col = coinController.columnForTouch(xTouchPos: pos.x)
            let winner = boardModel.placeInColumn(col: col)
            if let winner = winner, winner > 0 {
                winnerLabel.text = "Player \(winner) has won"
                return
            }
        }
        boardModel.advanceTurns()
    }
    
    //MARK: - Touch Gestures
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //MARK: - Time Counter
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
