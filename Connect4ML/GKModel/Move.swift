//
//  Move.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 2/23/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var column: Int
    
    init(col: Int) {
        column = col
    }
}
