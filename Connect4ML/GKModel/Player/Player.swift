//
//  Player.swift
//  Connect4ML
//
//  Created by Dunn, Michael R on 2/23/19.
//  Copyright © 2019 Dunn, Michael R. All rights reserved.
//

import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    var playerId: Int
    var color: UIColor
    var name: String
    var lastMove: (column: Int, row: Int) = (0,0)
    
    init(color: UIColor, name: String) {
        self.color = color
        playerId = color.hashValue
        self.name = name
        super.init()
    }
}
