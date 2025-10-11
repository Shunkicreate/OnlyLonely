//
//  GameEventMessage.swift
//  OnlyLonely
//

import Foundation

/// ゲーム進行に関するイベントをデバイス間で共有するメッセージ
struct GameEventMessage: Codable, Equatable {
    enum EventType: String, Codable {
        case gameFinished
    }

    let type: EventType
    let timestamp: Date
}
