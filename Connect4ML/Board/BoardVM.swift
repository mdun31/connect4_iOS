//
//  BoardVM.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 2/10/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

class BoardVM {
    
    private static let MAX_ROWS = 6
    private static let MAX_COLS = 7

    private var board:[[Int]] = Array(repeating: Array(repeating: 0, count: BoardVM.MAX_ROWS), count: BoardVM.MAX_COLS)
    private static var turns: Int = 0
    var playerForTurn: Int { return BoardVM.turns%2 + 1 }
    
    private(set) var gameOver = false
    
    /**
     * placeInColumn
     * places a coin in the board's model
     * @param - column, which player
     * @returns the player who has won or nil for no winner
     */
    func placeInColumn(col: Int) -> Int? {
        let normalizedColumn = col - 1
        for row in 0 ... 5 {
            if board[normalizedColumn][row] == 0 {
                board[normalizedColumn][row] = playerForTurn
                return winningPlayer(col:normalizedColumn, row:row, player: playerForTurn)
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
    func winningPlayer(col: Int, row: Int, player: Int) -> Int? {
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
     * @param - none
     * @returns none
     */
    func advanceTurns() {
        BoardVM.turns += 1
    }
    
}
