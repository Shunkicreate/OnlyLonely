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

    // JSONでは英語名 (pine, bamboo, plum) を使用
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "pine":
            self = .matsu
        case "bamboo":
            self = .take
        case "plum":
            self = .ume
        case "matsu":
            self = .matsu
        case "take":
            self = .take
        case "ume":
            self = .ume
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid cloud type: \(rawValue)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .matsu:
            try container.encode("pine")
        case .take:
            try container.encode("bamboo")
        case .ume:
            try container.encode("plum")
        }
    }
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

    // Codable実装（CGPoint/CGSizeのカスタムデコード）
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        type = try container.decode(CloudType.self, forKey: .type)

        // CGPointのデコード
        let positionDict = try container.decode([String: CGFloat].self, forKey: .position)
        guard let x = positionDict["x"], let y = positionDict["y"] else {
            throw DecodingError.dataCorruptedError(
                forKey: .position,
                in: container,
                debugDescription: "Position must have 'x' and 'y' fields"
            )
        }
        position = CGPoint(x: x, y: y)

        // CGSizeのデコード
        let sizeDict = try container.decode([String: CGFloat].self, forKey: .size)
        guard let width = sizeDict["width"], let height = sizeDict["height"] else {
            throw DecodingError.dataCorruptedError(
                forKey: .size,
                in: container,
                debugDescription: "Size must have 'width' and 'height' fields"
            )
        }
        size = CGSize(width: width, height: height)

        lightningInterval = try container.decodeIfPresent(TimeInterval.self, forKey: .lightningInterval)
        speedThreshold = try container.decodeIfPresent(CGFloat.self, forKey: .speedThreshold)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(["x": position.x, "y": position.y], forKey: .position)
        try container.encode(["width": size.width, "height": size.height], forKey: .size)
        try container.encodeIfPresent(lightningInterval, forKey: .lightningInterval)
        try container.encodeIfPresent(speedThreshold, forKey: .speedThreshold)
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
}
