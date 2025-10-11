//
//  TakePassThroughEffect.swift
//  OnlyLonely
//
//  竹の雲：通過時のビジュアルエフェクト
//

import SpriteKit

/// 竹の雲の通過エフェクトを管理するクラス
class TakePassThroughEffect {

    /// 竹の雲：通過時のエフェクト
    /// - Parameters:
    ///   - balloon: 風船ノード
    ///   - cloudId: 雲のID
    ///   - cloudNode: 雲のSKNode
    ///   - position: 衝突位置
    ///   - scene: エフェクトを表示するシーン
    static func playPassThroughEffect(
        for balloon: SKSpriteNode,
        cloudId: Int,
        cloudNode: SKNode,
        at position: CGPoint,
        in scene: SKScene
    ) {
        // 1. 雲が半透明になる
        let fadeOut = SKAction.fadeAlpha(to: 0.4, duration: 0.2)
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.3)
        let fadeSequence = SKAction.sequence([fadeOut, fadeIn])
        cloudNode.run(fadeSequence)

        // 2. 風船が少し下がるアニメーション（通過時の抵抗）
        let slowDown = SKAction.moveBy(x: 0, y: -20, duration: 0.1)
        let recover = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
        let slowSequence = SKAction.sequence([slowDown, recover])
        balloon.run(slowSequence)

        // 3. パーティクルエフェクト（雲が少し散る）
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            particle.fillColor = .white.withAlphaComponent(0.6)
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 6
            scene.addChild(particle)

            // ランダムな方向に飛び散る
            let randomAngle = CGFloat.random(in: 0...(2 * .pi))
            let randomDistance = CGFloat.random(in: 30...60)
            let dx = cos(randomAngle) * randomDistance
            let dy = sin(randomAngle) * randomDistance

            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let particleAnimation = SKAction.sequence([
                SKAction.group([move, fade]),
                remove
            ])
            particle.run(particleAnimation)
        }

        print("💨 Pass through effect with cloud particles!")
    }
}
