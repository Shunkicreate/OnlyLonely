//
//  PlayerWindForceMessage.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/21.
//

import Foundation

/// iPhone のマイク入力から算出した風力と端末の傾きを iPad へ共有するメッセージ
struct PlayerWindForceMessage: Codable, Equatable {
    /// 送信元プレイヤーの識別子（例: "A"）
    let playerId: String
    /// 0.0〜1.0 の範囲で正規化された風力値
    let force: Float
    /// 左右の傾き（roll, 度）
    let roll: Double
    /// 送信タイムスタンプ（デバッグ用）
    let timestamp: Date
}
