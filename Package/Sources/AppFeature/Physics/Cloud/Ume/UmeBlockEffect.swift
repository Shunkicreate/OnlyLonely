//
//  UmeBlockEffect.swift
//  OnlyLonely
//
//  梅の雲：ブロック時のビジュアルエフェクト
//

import SpriteKit

/// 梅の雲のブロックエフェクトを管理するクラス
class UmeBlockEffect {

    /// 梅の雲：ブロック時のエフェクト
    /// - Parameters:
    ///   - balloon: 風船ノード
    ///   - position: 衝突位置
    ///   - scene: エフェクトを表示するシーン
    static func playBlockEffect(
        for balloon: SKSpriteNode,
        at position: CGPoint,
        in scene: SKScene
    ) {
        // 1. 衝撃波エフェクト（白い円の波紋）
        let shockwave = SKShapeNode(circleOfRadius: 20)
        shockwave.position = position
        shockwave.strokeColor = .white
        shockwave.fillColor = .clear
        shockwave.lineWidth = 4
        shockwave.zPosition = 15
        scene.addChild(shockwave)

        // 衝撃波のアニメーション（拡大＋フェードアウト）
        let expand = SKAction.scale(to: 3.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let shockwaveAnimation = SKAction.sequence([
            SKAction.group([expand, fadeOut]),
            remove
        ])
        shockwave.run(shockwaveAnimation)

        // 2. フラッシュエフェクト（画面全体が白く点滅、alpha: 0.3）
        let flash = SKSpriteNode(color: .white, size: scene.size)
        flash.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        flash.alpha = 0.3
        flash.zPosition = 20
        scene.addChild(flash)

        let flashFadeOut = SKAction.fadeOut(withDuration: 0.15)
        let flashRemove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([flashFadeOut, flashRemove]))

        // 3. 風船が跳ね返るアニメーション
        let bounceBack = SKAction.moveBy(x: 0, y: -30, duration: 0.1)
        let bounceForward = SKAction.moveBy(x: 0, y: 15, duration: 0.1)
        let bounceSequence = SKAction.sequence([bounceBack, bounceForward])
        balloon.run(bounceSequence)

        print("🚫 Block effect with shockwave and flash!")
    }
}
