//
//  WindForceMessage.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/12.
//

import Foundation

struct WindForceMessage: Codable {
    enum MessageType: String, Codable {
        case wind
    }

    let type: MessageType
    let force: Float

    init(force: Float) {
        self.type = .wind
        self.force = force
    }
}
