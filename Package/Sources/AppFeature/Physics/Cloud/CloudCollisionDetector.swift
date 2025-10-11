//
//  CloudCollisionDetector.swift
//  OnlyLonely
//
//  雲との衝突判定ロジック管理
//

import SpriteKit

/// 雲との衝突判定を管理するクラス
class CloudCollisionDetector {

    /// 風船と雲の衝突をチェックし、エフェクトを再生
    /// - Parameters:
    ///   - balloon: 風船ノード
    ///   - playerId: プレイヤーID ("A" または "B")
    ///   - balloonPosition: 風船の位置
    ///   - balloonVelocity: 風船の速度
    ///   - physicsCoordinator: 物理演算コーディネーター
    ///   - clouds: 雲ノードの辞書 [cloudId: SKNode]
    ///   - lightningNodes: 雷エフェクトノードの辞書（参照渡し）
    ///   - scene: エフェクトを表示するシーン
    @MainActor
    static func checkBalloonCloudCollision(
        balloon: SKSpriteNode,
        playerId: String,
        balloonPosition: CGPoint,
        balloonVelocity: CGVector,
        physicsCoordinator: GamePhysicsCoordinator,
        clouds: [Int: SKNode],
        lightningNodes: inout [Int: SKNode],
        scene: SKScene
    ) {
        // 物理エンジンから衝突結果を取得
        let collisionResult = physicsCoordinator.checkCollision(
            balloonPosition: balloonPosition,
            balloonVelocity: balloonVelocity
        )

        // 衝突がない場合は終了
        if collisionResult == .none {
            return
        }

        // 衝突した雲を特定
        guard let cloudId = findCollidedCloud(
            balloonPosition: balloonPosition,
            clouds: clouds
        ) else {
            return
        }

        // 衝突タイプに応じてエフェクトを再生
        handleCollision(
            collisionResult,
            forPlayer: playerId,
            balloon: balloon,
            cloudId: cloudId,
            at: balloonPosition,
            clouds: clouds,
            lightningNodes: &lightningNodes,
            scene: scene
        )
    }

    /// 衝突した雲のIDを特定
    /// - Parameters:
    ///   - balloonPosition: 風船の位置
    ///   - clouds: 雲ノードの辞書
    /// - Returns: 衝突した雲のID、衝突がない場合は nil
    private static func findCollidedCloud(
        balloonPosition: CGPoint,
        clouds: [Int: SKNode]
    ) -> Int? {
        for (cloudId, cloudNode) in clouds {
            // 雲のバウンディングボックスを計算
            let cloudFrame = cloudNode.calculateAccumulatedFrame()

            // 風船との衝突判定
            if cloudFrame.contains(balloonPosition) {
                return cloudId
            }
        }
        return nil
    }

    /// 衝突結果の処理とエフェクト再生
    /// - Parameters:
    ///   - result: 衝突結果
    ///   - playerId: プレイヤーID
    ///   - balloon: 風船ノード
    ///   - cloudId: 雲のID
    ///   - position: 衝突位置
    ///   - clouds: 雲ノードの辞書
    ///   - lightningNodes: 雷エフェクトノードの辞書（参照渡し）
    ///   - scene: エフェクトを表示するシーン
    private static func handleCollision(
        _ result: CollisionResult,
        forPlayer playerId: String,
        balloon: SKSpriteNode,
        cloudId: Int,
        at position: CGPoint,
        clouds: [Int: SKNode],
        lightningNodes: inout [Int: SKNode],
        scene: SKScene
    ) {
        guard let cloudNode = clouds[cloudId] else { return }

        switch result {
        case .lightning:
            // 松の雲：雷ヒット時のエフェクト
            MatsuLightningEffect.playLightningHitEffect(
                for: balloon,
                nearCloud: cloudId,
                cloudNode: cloudNode,
                in: scene,
                lightningNodes: &lightningNodes
            )
            print("⚡ Lightning hit player \(playerId)!")

        case .blocked:
            // 梅の雲：ブロック時のエフェクト
            UmeBlockEffect.playBlockEffect(
                for: balloon,
                at: position,
                in: scene
            )
            print("🚫 Player \(playerId) blocked by cloud")

        case .passThrough:
            // 竹の雲：通過時のエフェクト
            TakePassThroughEffect.playPassThroughEffect(
                for: balloon,
                cloudId: cloudId,
                cloudNode: cloudNode,
                at: position,
                in: scene
            )
            print("💨 Player \(playerId) passing through cloud")

        case .none:
            break
        }
    }
}
