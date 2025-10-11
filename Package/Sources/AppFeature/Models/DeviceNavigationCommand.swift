//
//  DeviceNavigationCommand.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/17.
//

import Foundation

/// 接続が完了し、画面遷移するための構造体
struct DeviceNavigationCommand: Codable {
    enum Action: String, Codable {
        case showCountdown
    }

    let action: Action
}
