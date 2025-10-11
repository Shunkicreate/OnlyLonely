//
//  SimpleBalloonPhysics.swift
//  OnlyLonely
//
//  シンプルな風船物理演算の実装
//

import Foundation
import CoreGraphics

/// シンプルな風船物理エンジン
class SimpleBalloonPhysics: BalloonPhysicsEngine {

    func update(state: inout BalloonPhysicsState, deltaTime: TimeInterval) {
        guard !state.isPopped else { return }

        // 浮力計算
        let liftForce = CGFloat(state.windForce) * PhysicsConstants.liftCoefficient

        // 空気抵抗計算
        let drag = state.velocity.dy * PhysicsConstants.dragCoefficient

        // 加速度計算
        let acceleration = (liftForce + PhysicsConstants.gravity - drag) / PhysicsConstants.childMass

        // 速度更新
        state.velocity.dy += acceleration * deltaTime

        // 位置更新
        state.position.y += state.velocity.dy * deltaTime

        // 高度更新（画面座標系とは逆）
        state.altitude = state.position.y / 10.0 // 10px = 1m として計算

        // 地面判定
        if state.position.y < 0 {
            state.position.y = 0
            state.velocity.dy = 0
        }
    }

    func applyWindForce(_ force: Float, to state: inout BalloonPhysicsState) {
        state.windForce = max(0, min(1.0, force))
    }

    func popBalloon(state: inout BalloonPhysicsState) {
        state.isPopped = true
        state.windForce = 0

        // 落下開始
        state.velocity.dy = PhysicsConstants.lightningDamage
    }

    func respawnBalloon(state: inout BalloonPhysicsState) {
        state.isPopped = false
        state.velocity.dy = 0
    }
}
