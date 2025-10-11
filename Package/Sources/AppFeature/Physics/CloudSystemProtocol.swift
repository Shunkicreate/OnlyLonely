//
//  CloudSystemProtocol.swift
//  OnlyLonely
//
//  雲システムのプロトコル定義
//

import Foundation
import CoreGraphics

/// 雲の種類
enum CloudType: String, Codable {
    case matsu  // 松：雷ギミック
    case take   // 竹：速度閾値
    case ume    // 梅：完全障害物
}

/// 雲データ
struct CloudData: Codable {
    let id: Int
    let type: CloudType
    let position: CGPoint
    let size: CGSize
    var lightningInterval: TimeInterval?
    var speedThreshold: CGFloat?

    enum CodingKeys: String, CodingKey {
        case id, type, position, size, lightningInterval, speedThreshold
    }

    init(
        id: Int,
        type: CloudType,
        position: CGPoint,
        size: CGSize,
        lightningInterval: TimeInterval? = nil,
        speedThreshold: CGFloat? = nil
    ) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.lightningInterval = lightningInterval
        self.speedThreshold = speedThreshold
    }
}

/// 衝突結果
enum CollisionResult {
    case none
    case blocked            // 跳ね返る
    case passThrough        // 通過
    case lightning          // 雷ダメージ
}

/// 雲システムのプロトコル
protocol CloudSystem {
    /// JSONから雲データを読み込み
    func loadClouds(from json: String) throws

    /// 雲との衝突チェック
    func checkCollision(balloonPosition: CGPoint, balloonVelocity: CGVector) -> CollisionResult

    /// 雷を発生（松の雲用）
    func triggerLightning(at cloudId: Int)
}
