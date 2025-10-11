//
//  PhysicsConstants.swift
//  OnlyLonely
//
//  物理パラメータの一元管理
//

import Foundation
import CoreGraphics

struct PhysicsConstants {
    // MARK: - 基本物理パラメータ

    /// 重力加速度 (m/s²)
    static let gravity: CGFloat = -1.6

    /// 子供の質量 (kg)
    static let childMass: CGFloat = 10.0

    /// 浮力係数（TBD: 調整が必要）
    static var liftCoefficient: CGFloat = 100.0

    /// 空気抵抗係数（値を上げると減速が早くなる）
    static var dragCoefficient: CGFloat = 1.4

    /// 左右傾きの最大角度（度）
    static var maxTiltDegrees: Double = 30.0

    /// 左右の傾きを速度へ変換するスケール（ポイント/秒）
    static var horizontalSpeed: CGFloat = 220.0

    /// 左右レーンの端からの余白
    static var laneHorizontalPadding: CGFloat = 80.0

    /// 風入力の感度（iPhone→iPad）
    static var windForceSensitivity: Float = 1.6

    /// 風力の上限（感度適用後）
    static func windForce(force: Float) -> Float {
        return force * 40.0
    }

    /// 地面ラインのY座標（SpriteKit空間）
    static var groundBaseline: CGFloat = 50.0


    // MARK: - 雲パラメータ

    /// 竹の雲の速度閾値 (m/s)
    static let takeCloudSpeedThreshold: CGFloat = 4.0

    /// 雷の発生間隔（秒）
    static let lightningIntervalMin: TimeInterval = 3.0

    // MARK: - ダメージ設定

    /// 雷ダメージ（落下距離 m）
    static let lightningDamage: CGFloat = -30.0

    /// 風船復活時間（秒）
    static let balloonRespawnTime: TimeInterval = 2.0
}
