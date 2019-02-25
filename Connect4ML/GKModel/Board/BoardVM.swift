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
    
    private(set) var gameOver = false
    
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
        let dlDiagonalCheck = downLeftDiagonalCount(colStart: col, rowStart: row)
        let urDiagonalCheck = upRightDiagonalCount(colStart: col, rowStart: row)
        
        if dlDiagonalCheck + urDiagonalCheck + 1 > 3 {
            gameOver = true
            return player
        }
        
        let ulDiagonalCheck = upLeftDiagonalCount(colStart: col, rowStart: row)
        let drDiagonalCheck = downRightDiagonalCount(colStart: col, rowStart: row)
        
        if ulDiagonalCheck + drDiagonalCheck + 1 > 3 {
            gameOver = true
            return player
        }

        let lHorizontalCheck = leftHorizontalCheck(colStart: col, rowStart: row)
        let rHorizontalCheck = rightHorizontalCheck(colStart: col, rowStart: row)
        
        if lHorizontalCheck + rHorizontalCheck + 1 > 3 {
            gameOver = true
            return player
        }
        
        if verticalCheck(colStart: col, rowStart: row) + 1 > 3 {
            gameOver = true
            return player
        }
        
        return nil
    }
    
    //MARK Horizontal Checks
    private func leftHorizontalCheck(colStart: Int,rowStart: Int) -> Int {
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
    
    //MARK Vertical Check
    private func verticalCheck(colStart: Int, rowStart: Int) -> Int {
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
    
    //MARK / diagonal check
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
    
    //MARK \ diagonal check
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
    }
}

extension BoardVM: GKGameModel {
    var players: [GKGameModelPlayer]? { return playerList }
    
    var activePlayer: GKGameModelPlayer? { return currentPlayer }
    
    func setGameModel(_ gameModel: GKGameModel) {
        guard let vm = gameModel as? BoardVM else { return }
        board = vm.board
        turns = vm.turns
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
        guard let player = player as? Player else { return 0 }
        let didCompWin = winningPlayer(col: player.lastMove.column, row: player.lastMove.row, player: player.name)
        let compScore = didCompWin == player.name ? 1000 : 0
        
        guard let opponent = playerList.filter({ $0.name != player.name }).first else { return 0 }
        let didHumanWin = winningPlayer(col: opponent.lastMove.column, row: opponent.lastMove.row, player: opponent.name)
        let humanScore = didHumanWin == opponent.name ? -1000 : 0
        
        return compScore + humanScore
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
