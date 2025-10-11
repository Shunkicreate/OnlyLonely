//
//  GameEventMessage.swift
//  OnlyLonely
//

import Foundation

/// ゲーム進行に関するイベントをデバイス間で共有するメッセージ
struct GameEventMessage: Codable, Equatable {
    enum EventType: String, Codable {
        case gameFinished
        case lightningHit
    }

    let type: EventType
    let timestamp: Date
    let playerId: String?

    init(type: EventType, timestamp: Date = Date(), playerId: String? = nil) {
        self.type = type
        self.timestamp = timestamp
        self.playerId = playerId
    }
}
