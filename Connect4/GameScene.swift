//
//  GameScene.swift
//  Connect4
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
    private var boardBase: SKSpriteNode!
    
    private var resetButton: ButtonNode?
    private var dropingCoin : SKShapeNode?
    private var coinsInPlay: [SKShapeNode] = []
    
    private lazy var coinController: CoinController = { return CoinController() }()
    private lazy var boardModel: BoardVM = { return BoardVM() }()
    
    private var boardTop: CGFloat = 0
    private var aiToggleButton: ButtonNode!
    
    var allowAIMoves: Bool = false

    //MARK: - AI Init
    private lazy var strategist: GKMinmaxStrategist = {
        let strategist = GKMinmaxStrategist()
        strategist.gameModel = boardModel
        strategist.maxLookAheadDepth = 5
        strategist.randomSource = nil
        return strategist
    }()
    
    private var aiMoveColumn: Int {
        guard let aiMove = strategist.bestMove(for: boardModel.currentPlayer) as? Move else { return 4 }
        return aiMove.column
    }
    
    //MARK: - Init funcs
    override func didMove(to view: SKView) {
        //setup the board and board base
        setupBoardBase()
        setupBoard()
        
        // Create shape node to use during mouse interaction
        setupCoins()
        
        //get the win label
        setupLabel()
        
        //setup ai button
        createAIToggleButton()
    }
    
    //MARK: - Setup Methods
    private func setupBoard() {
        guard let board = childNode(withName: SceneKeys.board) as? SKSpriteNode else {
            fatalError("board node not loaded")
        }
        let boardTexture = SKTexture(imageNamed: SceneKeys.boardImage)
        board.texture = boardTexture
        self.board = board
        boardTop = board.position.y + board.frame.size.height/2
    }
    
    private func setupCoins() {
        let coinRadius = board.size.height/12
        baseCoin = SKShapeNode(circleOfRadius: coinRadius)
        baseCoin.fillColor = .red
        baseCoin.position = CGPoint(x: -1000, y: -1000)
        baseCoin.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: coinRadius*2,
                                                                 height: coinRadius*2))
        generateWalls(atWidth: board.size.width/7)
    }
    
    private func setupLabel() {
        guard let winnerLabel = childNode(withName: SceneKeys.winnerLabel) as? SKLabelNode else {
            fatalError("failed to load label")
        }
        winnerLabel.text = "\(boardModel.currentPlayer.name) Player's turn"
        self.winnerLabel = winnerLabel
    }
    
    private func setupBoardBase() {
        guard let base = childNode(withName: SceneKeys.boardBase) as? SKSpriteNode else {
            fatalError("failed to load label")
        }
        boardBase = base
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
    
    private func createResetButton() {
        resetButton = ButtonNode(label: "Reset", action:{ [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.resetGame()
            }, anchorPoint: CGPoint(x: 0, y: 450))
        addChild(resetButton!)
    }
    
    private func createAIToggleButton() {
        aiToggleButton = ButtonNode(label: "Enable/Disable AI", action: { [unowned self] in
            self.allowAIMoves = !self.allowAIMoves
            self.aiToggleButton.bgColor = self.allowAIMoves ? .green : .red
            }, anchorPoint: CGPoint(x: 0, y: -600))
        aiToggleButton.bgColor = .red
        addChild(aiToggleButton)
    }
    
    //MARK: - On Touch Methods
    func touchDown(atPoint pos : CGPoint) {
        if !boardModel.gameOver && pos.y > -500 {
            dropingCoin = baseCoin.copy() as? SKShapeNode
            if let n = dropingCoin {
                n.fillColor = boardModel.currentPlayer.color
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
            coinsInPlay.append(n)
            if(endGameIfNecessary(winnerName: winner)){ return }
        }
        if !boardModel.gameOver && pos.y > -500  {
            continueGame()
            if allowAIMoves {
                startAITurn()
            }
        }
    }
    
    //MARK: - Game State Methods
    private func continueGame() {
        boardModel.advanceTurns()
        winnerLabel.text = "\(boardModel.currentPlayer.name) Player's turn"
    }
    
    private func endGameIfNecessary(winnerName: String?) -> Bool {
        if let winner = winnerName, winner.count > 0 {
            boardModel.gameOver = true
            winnerLabel.text = "\(winner) Player has won"
            createResetButton()
            return true
        }
        return false
    }
    
    private func resetGame() {
        boardBase.physicsBody = nil
    }
    
    private func restartGame() {
        winnerLabel.text = "\(boardModel.currentPlayer.name) Player's turn"
        boardBase.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: boardBase.frame.size.width,
                                                                  height: boardBase.frame.size.height))
        boardBase.physicsBody?.affectedByGravity = false
        boardBase.physicsBody?.isDynamic = false
        boardBase.physicsBody?.allowsRotation = false
        
        resetButton?.removeFromParent()
    }
    
    //MARK: - Touch Gestures
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
        resetButton?.touchesBegan(touches, with: event)
        aiToggleButton.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        resetButton?.touchesMoved(touches, with: event)
        aiToggleButton.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
        resetButton?.touchesEnded(touches, with: event)
        aiToggleButton.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    //MARK: - Time Counter
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if boardModel.gameOver {
            coinsInPlay.filter({ !$0.intersects(board) }).forEach({$0.removeFromParent()})
            coinsInPlay = coinsInPlay.filter({ $0.intersects(board) })
            if coinsInPlay.count == 0 {
                boardModel.resetModel()
                restartGame()
            }
        }
    }
    
    //MARK: - AI funcs
    func makeAIMove(col: Int) {
        dropingCoin = baseCoin.copy() as? SKShapeNode
        if let n = dropingCoin {
            n.fillColor = boardModel.currentPlayer.color
            n.position = CGPoint(x: coinController.xDropPosForCoinColumn(coinCol: col), y: boardTop)
            n.physicsBody?.affectedByGravity = true
            addChild(n)
            let winner = boardModel.placeInColumn(col: col)
            coinsInPlay.append(n)
            if(endGameIfNecessary(winnerName: winner)){ return }
            continueGame()
        }
    }
    
    func startAITurn() {
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            let column = self.aiMoveColumn
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            
            let aiTimeCeiling = 1.0
            let delayTime = aiTimeCeiling - delta
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: {[unowned self] in
                self.makeAIMove(col: column)
            })
        }
    }
}
