//
//  BoardVM.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 2/10/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

import GameplayKit

class BoardVM: NSObject {
    fileprivate static let MAX_ROWS = 6
    fileprivate static let MAX_COLS = 7

    private var board:[[Int]] = Array(repeating: Array(repeating: 0, count: BoardVM.MAX_ROWS), count: BoardVM.MAX_COLS)
    private var turns: Int = 0
    fileprivate var playerList: [Player] = [Player(color: .red, name: "Red"), Player(color: .yellow, name: "Yellow")]
    var currentPlayer: Player { return playerList[turns%2] }
    
    var gameOver = false
    
    /**
     * placeInColumn
     * places a coin in the board's model
     * @param - column, which player
     * @returns the player who has won or nil for no winner
     */
    func placeInColumn(col: Int) -> String? {
        let normalizedColumn = col - 1
        for row in 0 ... 5 {
            if board[normalizedColumn][row] == 0 {
                board[normalizedColumn][row] = currentPlayer.playerId
                currentPlayer.lastMove = (normalizedColumn, row)
                return winningPlayer(col:normalizedColumn, row:row, player: currentPlayer.name)
            }
        }
        return nil
    }
    
    /**
     * winningPlayer
     * designed to check the board for any winning players
     * @param - none
     * @returns the player who has won or nil for no winner
     */
    func winningPlayer(col: Int, row: Int, player: String) -> String? {
        
        if forwardDiagonalScore(colStart: col, rowStart: row) + 1 > 3 {
            return player
        }
        
        if backwardDiagonalScore(colStart: col, rowStart: row) + 1 > 3 {
            return player
        }

        if horizontalScore(colStart: col, rowStart: row) + 1 > 3 {
            return player
        }
        
        if verticalScore(colStart: col, rowStart: row) + 1 > 3 {
            return player
        }
        
        return nil
    }
    
    //MARK: - Horizontal Checks
    fileprivate func horizontalScore(colStart: Int, rowStart: Int) -> Int {
        return leftHorizontalCheck(colStart:colStart, rowStart:rowStart) + rightHorizontalCheck(colStart:colStart, rowStart:rowStart)
    }
    
    private func leftHorizontalCheck(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var col = colStart - 1
        let player = board[colStart][rowStart]
        while col >= 0 && sequenceNumber <= 4 {
            if board[col][rowStart] == player {
                sequenceNumber += 1
            } else {
                break
            }
            col-=1
        }
        return sequenceNumber
    }
    
    private func rightHorizontalCheck(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var col = colStart + 1
        let player = board[colStart][rowStart]
        while col < BoardVM.MAX_COLS && sequenceNumber <= 4 {
            if board[col][rowStart] == player {
                sequenceNumber += 1
            } else {
                break
            }
            col+=1
        }
        return sequenceNumber
    }
    
    //MARK: - Vertical Check
    private func verticalScore(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var row = rowStart - 1
        let player = board[colStart][rowStart]
        while row >= 0 && sequenceNumber <= 4 {
            if board[colStart][row] == player {
                sequenceNumber += 1
            } else {
                break
            }
            row-=1
        }
        return sequenceNumber
    }
    
    //MARK: - / diagonal check
    private func forwardDiagonalScore(colStart: Int, rowStart: Int) -> Int {
        return downLeftDiagonalCount(colStart:colStart, rowStart:rowStart) + upRightDiagonalCount(colStart:colStart, rowStart:rowStart)
    }
    
    private func downLeftDiagonalCount(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var row = rowStart + 1
        var col = colStart + 1
        let player = board[colStart][rowStart]
        while row < BoardVM.MAX_ROWS && col < BoardVM.MAX_COLS && sequenceNumber <= 4 {
            if board[col][row] == player {
                sequenceNumber += 1
            } else {
                break
            }
            row+=1
            col+=1
        }
        return sequenceNumber
    }
    
    private func upRightDiagonalCount(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var row = rowStart - 1
        var col = colStart - 1
        let player = board[colStart][rowStart]
        while row >= 0 && col >= 0 && sequenceNumber <= 4 {
            if board[col][row] == player {
                sequenceNumber += 1
            } else {
                break
            }
            row-=1
            col-=1
        }
        return sequenceNumber
    }
    
    //MARK: - \ diagonal check
    private func backwardDiagonalScore(colStart: Int, rowStart: Int) -> Int {
        return upLeftDiagonalCount(colStart:colStart, rowStart:rowStart) + downRightDiagonalCount(colStart:colStart, rowStart:rowStart)
    }
    
    private func upLeftDiagonalCount(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var row = rowStart + 1
        var col = colStart - 1
        let player = board[colStart][rowStart]
        while row < BoardVM.MAX_ROWS && col >= 0 && sequenceNumber <= 4 {
            if board[col][row] == player {
                sequenceNumber += 1
            } else {
                break
            }
            row+=1
            col-=1
        }
        return sequenceNumber
    }
    
    private func downRightDiagonalCount(colStart: Int, rowStart: Int) -> Int {
        var sequenceNumber = 0
        var row = rowStart - 1
        var col = colStart + 1
        let player = board[colStart][rowStart]
        while row >= 0 && col < BoardVM.MAX_COLS && sequenceNumber <= 4 {
            if board[col][row] == player {
                sequenceNumber += 1
            } else {
                break
            }
            row-=1
            col+=1
        }
        return sequenceNumber
    }
    //MARK: - Total Score
    fileprivate func getTotalScore(col: Int, row:Int) -> Int {
        return verticalScore(colStart: col, rowStart: row) + horizontalScore(colStart: col, rowStart: row) +
            forwardDiagonalScore(colStart: col, rowStart: row) + backwardDiagonalScore(colStart: col, rowStart: row)
    }
    //MARK: - Model states
    /**
     * advanceTurns
     * increments turn counter by 1
     */
    func advanceTurns() {
        turns += 1
    }
    
    /**
     * resetModel
     * sets model back to starting values
     */
    func resetModel() {
        gameOver = false
        turns = 0
        board = Array(repeating: Array(repeating: 0, count: BoardVM.MAX_ROWS), count: BoardVM.MAX_COLS)
        playerList = [Player(color: .red, name: "Red"), Player(color: .yellow, name: "Yellow")]
    }
}

//MARK: - Game Model -
extension BoardVM: GKGameModel {
    var players: [GKGameModelPlayer]? { return playerList }
    
    var activePlayer: GKGameModelPlayer? { return currentPlayer }
    
    func setGameModel(_ gameModel: GKGameModel) {
        guard let vm = gameModel as? BoardVM else { return }
        board = vm.board
        turns = vm.turns

        guard let redPlayer = playerList.filter({$0.name == "Red"}).first else { return }
        let copyRed = Player(color: .red, name: "Red")
        copyRed.lastMove = redPlayer.lastMove
        
        guard let yellowPlayer = playerList.filter({$0.name == "Yellow"}).first else { return }
        let copyYellow = Player(color: .yellow, name: "Yellow")
        copyYellow.lastMove = yellowPlayer.lastMove
        
        playerList = [copyRed, copyYellow]
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let _ = player as? Player, !gameOver else { return nil }
        var moveList:[Move] = []
        for i in 1...board.count {
            if board[i-1][BoardVM.MAX_ROWS-1] == 0 {
                moveList.append(Move(col: i))
            }
        }
        return moveList
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        if isWin(for: player) {
            return 1000
        } else if isLoss(for: player) {
            return -1000
        } else {
            guard let player = player as? Player,
                let playerCol = player.lastMove.column,
                let playerRow = player.lastMove.row else { return 0 }
            return getTotalScore(col: playerCol, row: playerRow)
        }
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let player = player as? Player,
            let col = player.lastMove.column, let row = player.lastMove.row else { return false }
        let didCompWin = winningPlayer(col: col, row: row, player: player.name)
        return didCompWin == player.name
    }
    
    func isLoss(for player: GKGameModelPlayer) -> Bool {
        guard let player = player as? Player,
            let opponent = playerList.filter({ $0.name != player.name }).first,
            let col = opponent.lastMove.column, let row = opponent.lastMove.row else { return false }
        let didHumanWin = winningPlayer(col: col, row: row, player: opponent.name)
        return didHumanWin == opponent.name
        
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else { return }
        _ = placeInColumn(col: move.column)
        advanceTurns()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyVM = BoardVM()
        copyVM.setGameModel(self)
        return copyVM
    }
}
