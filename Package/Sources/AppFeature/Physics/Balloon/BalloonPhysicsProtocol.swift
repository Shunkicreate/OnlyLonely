//
//  BalloonPhysicsProtocol.swift
//  OnlyLonely
//
//  風船物理演算のプロトコル定義
//

import Foundation
import CoreGraphics

/// 風船の物理状態
struct BalloonPhysicsState {
    var position: CGPoint
    var velocity: CGVector
    var altitude: CGFloat
    var isPopped: Bool
    var windForce: Float

    init(
        position: CGPoint = .zero,
        velocity: CGVector = .zero,
        altitude: CGFloat = 0,
        isPopped: Bool = false,
        windForce: Float = 0
    ) {
        self.position = position
        self.velocity = velocity
        self.altitude = altitude
        self.isPopped = isPopped
        self.windForce = windForce
    }
}

/// 風船物理演算のプロトコル
protocol BalloonPhysicsEngine {
    /// 物理状態を更新
    func update(state: inout BalloonPhysicsState, deltaTime: TimeInterval)

    /// 風力を適用
    func applyWindForce(_ force: Float, to state: inout BalloonPhysicsState)

    /// 風船を破裂
    func popBalloon(state: inout BalloonPhysicsState)

    /// 風船を復活
    func respawnBalloon(state: inout BalloonPhysicsState)
}
