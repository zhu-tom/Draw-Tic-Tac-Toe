//
//  TicTacToeGame.swift
//  Assignment4
//
//  Created by Tom Zhu on 2020-03-30.
//  Copyright © 2020 COMP1601. All rights reserved.
//

import Foundation

class TicTacToeGame {
    var gameBoard: [Character?]
    var isXTurn: Bool
    var isGameOver: Bool
    let winningCombos = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]]
    var winningLine: [Int]?
    
    init() {
        gameBoard = [Character?](repeating: nil, count: 9)
        isXTurn = true
        isGameOver = false
    }
    
    func play(square: Int) {
        if gameBoard[square] == nil {
            gameBoard[square] = isXTurn ? "X":"O"
            isXTurn = !isXTurn
            
            var notNil = 0
            for zone in gameBoard {
                if zone != nil {
                    notNil += 1
                }
            }
            if notNil == gameBoard.count {
                isGameOver = true
            }
            
            winningLine = checkWinner()
            
            if winningLine != nil {
                isGameOver = true
            }
            
        }
    }
    
    func checkWinner() -> [Int]? {
        for combo in winningCombos {
            if gameBoard[combo[0]] != nil && gameBoard[combo[0]] == gameBoard[combo[1]] && gameBoard[combo[1]] == gameBoard[combo[2]] {
                return combo
            }
        }
        return nil
    }
    
    func reset() {
        gameBoard = [Character?](repeating: nil, count: 9)
        isXTurn = true
        isGameOver = false
    }
}
