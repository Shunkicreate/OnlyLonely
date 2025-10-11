//
//  GameState.swift
//  OnlyLonely
//

import Foundation

enum GamePhase {
    case idle
    case playing
    case finished
}

struct GameResult: Codable {
    let winner: PlayerSlot?
}
