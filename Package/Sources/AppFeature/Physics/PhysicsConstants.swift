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
    static let gravity: CGFloat = -9.8

    /// 子供の質量 (kg)
    static let childMass: CGFloat = 10.0

    /// 浮力係数（TBD: 調整が必要）
    static var liftCoefficient: CGFloat = 50.0

    /// 空気抵抗係数（TBD: 調整が必要）
    static var dragCoefficient: CGFloat = 0.5

    // MARK: - ゲーム設定

    /// ゲーム時間（秒）
    static let gameDuration: TimeInterval = 30.0

    /// 更新頻度（Hz）
    static let updateFrequency: Double = 60.0

    /// 入力頻度（Hz）- iPhoneからの音圧データ
    static let inputFrequency: Double = 30.0

    // MARK: - 高度設定

    /// ゴール（星）の高度 (m)
    static let goalAltitude: CGFloat = 800.0

    /// 宇宙飛行士の登場高度 (m)
    static let astronautAltitude: CGFloat = 800.0

    // MARK: - 雲パラメータ

    /// 竹の雲の速度閾値 (m/s)
    static let takeCloudSpeedThreshold: CGFloat = 4.0

    /// 雷の発生間隔（秒）
    static let lightningIntervalMin: TimeInterval = 3.0
    static let lightningIntervalMax: TimeInterval = 5.0

    // MARK: - ダメージ設定

    /// 雷ダメージ（落下距離 m）
    static let lightningDamage: CGFloat = -30.0

    /// 風船復活時間（秒）
    static let balloonRespawnTime: TimeInterval = 2.0

    /// カラスの押し下げ距離 (m)
    static let crowPushDownDistance: CGFloat = -20.0

    /// 隕石ダメージ（落下距離 m）
    static let meteoriteDamage: CGFloat = -50.0

    // MARK: - 障害物設定

    /// 電線での停止時間（秒）
    static let powerLineFreezeDuration: TimeInterval = 1.5
}
