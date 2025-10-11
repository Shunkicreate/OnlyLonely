//
//  PlayerInfo.swift
//  OnlyLonely
//

import Foundation

struct PlayerInfo: Identifiable, Codable {
    let id: String
    var altitude: Double
}

enum PlayerSlot: Int, Codable {
    case playerA = 0
    case playerB = 1
}
