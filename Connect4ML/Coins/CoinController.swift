//
//  CoinController.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 2/10/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

import UIKit

class CoinController {
    
    private var wallXArray: [CGFloat] = []
    
    func importWalls(wallXPos: CGFloat) {
        wallXArray.append(wallXPos)
    }
    
    func columnForTouch(xTouchPos: CGFloat) -> Int {
        for wallNumber in 1...(wallXArray.count-1) {
            if xTouchPos < wallXArray[wallNumber] {
                return wallNumber
            }
        }
        return 7
    }
    
    func xDropPosForCoinColumn(coinCol: Int) -> CGFloat {
        return (wallXArray[coinCol - 1] + wallXArray[coinCol])/2
    }
}
