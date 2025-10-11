//
//  GameState.swift
//  OnlyLonely
//

import Foundation

enum GamePhase {
    case idle
    case waitingForPlayers
    case countdown
    case playing
    case finished
}

struct GameResult: Codable {
    let winner: PlayerSlot?
    let playerAltitude: Double
    let opponentAltitude: Double

    var isDraw: Bool {
        winner == nil
    }
}
