//
//  MatsuLightningEffect.swift
//  OnlyLonely
//
//  松の雲：雷ヒット時のビジュアルエフェクト
//

import SpriteKit

/// 松の雲の雷エフェクトを管理するクラス
class MatsuLightningEffect {

    /// 松の雲：雷ヒット時のエフェクト
    /// - Parameters:
    ///   - balloon: 風船ノード
    ///   - cloudId: 雲のID
    ///   - cloudNode: 雲のSKNode
    ///   - scene: エフェクトを表示するシーン
    ///   - lightningNodes: 雷エフェクトノードの辞書（参照渡し）
    static func playLightningHitEffect(
        for balloon: SKSpriteNode,
        nearCloud cloudId: Int,
        cloudNode: SKNode,
        in scene: SKScene,
        lightningNodes: inout [Int: SKNode]
    ) {
        // 1. 雷エフェクトを表示
        showLightning(at: cloudId, cloudNode: cloudNode, lightningNodes: &lightningNodes)

        // 2. 風船の点滅エフェクト（無敵時間の視覚化）
        let blinkOut = SKAction.fadeAlpha(to: 0.3, duration: 0.05)
        let blinkIn = SKAction.fadeAlpha(to: 1.0, duration: 0.05)
        let blinkSequence = SKAction.sequence([blinkOut, blinkIn])
        let blinkRepeat = SKAction.repeat(blinkSequence, count: 6)  // 0.6秒間点滅
        balloon.run(blinkRepeat)

        // 3. スローモーション演出（0.3倍速、0.2秒間）
        let originalSpeed = scene.speed
        scene.speed = 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak scene] in
            scene?.speed = originalSpeed
        }

        // 4. 風船が少し下がるアニメーション
        let pushDown = SKAction.moveBy(x: 0, y: -30, duration: 0.1)
        let bounceBack = SKAction.moveBy(x: 0, y: 15, duration: 0.1)
        let bounceSequence = SKAction.sequence([pushDown, bounceBack])
        balloon.run(bounceSequence)

        print("⚡ Lightning hit with full effects!")
    }

    /// 雷エフェクトを表示
    private static func showLightning(
        at cloudId: Int,
        cloudNode: SKNode,
        lightningNodes: inout [Int: SKNode]
    ) {
        // 既存の雷エフェクトを削除
        lightningNodes[cloudId]?.removeFromParent()

        // 雷エフェクトを作成
        let lightning = createLightningEffect()
        lightning.position = CGPoint(x: 0, y: -30)
        lightning.zPosition = 6
        cloudNode.addChild(lightning)
        lightningNodes[cloudId] = lightning

        // 0.5秒後に削除（SKActionを使用してクロージャを回避）
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        lightning.run(SKAction.sequence([wait, remove]))
    }

    /// 雷エフェクトの作成
    private static func createLightningEffect() -> SKNode {
        let container = SKNode()

        // ジグザグの雷
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: -5, y: -15))
        path.addLine(to: CGPoint(x: 5, y: -30))
        path.addLine(to: CGPoint(x: -3, y: -45))
        path.addLine(to: CGPoint(x: 0, y: -60))

        let lightningShape = SKShapeNode(path: path.cgPath)
        lightningShape.strokeColor = .yellow
        lightningShape.lineWidth = 3
        lightningShape.glowWidth = 5
        container.addChild(lightningShape)

        // 点滅アニメーション
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        let repeatAction = SKAction.repeat(blink, count: 3)
        lightningShape.run(repeatAction)

        return container
    }
}
