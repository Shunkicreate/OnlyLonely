//
//  PlayerInfo.swift
//  OnlyLonely
//

import Foundation

struct PlayerInfo: Identifiable, Codable {
    let id: String
    var name: String
    var altitude: Double
    var isReady: Bool

    init(id: String = UUID().uuidString, name: String = "", altitude: Double = 0.0, isReady: Bool = false) {
        self.id = id
        self.name = name
        self.altitude = altitude
        self.isReady = isReady
    }
}

enum PlayerSlot: Int, Codable {
    case playerA = 0
    case playerB = 1
}

enum PlayerState: Codable {
    case disconnected
    case connected
    case ready
}
