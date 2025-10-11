//
//  CloudLoader.swift
//  OnlyLonely
//
//  雲データの生成と読み込み管理
//

import SpriteKit

/// 雲データの生成と読み込みを管理するクラス
class CloudLoader {

    /// ランダムに雲データを生成して配置
    /// - Parameters:
    ///   - sceneSize: シーンのサイズ
    ///   - cloudsPerPlayer: 各プレイヤー領域に配置する雲の数
    ///   - physicsCoordinator: 物理エンジンコーディネーター
    ///   - scene: 雲を追加するシーン
    /// - Returns: 生成された雲ノードの辞書 [cloudId: SKNode]
    @MainActor
    static func loadRandomClouds(
        sceneSize: CGSize,
        cloudsPerPlayer: Int = 5,
        physicsCoordinator: GamePhysicsCoordinator?,
        scene: SKScene
    ) -> [Int: SKNode] {
        let halfWidth = sceneSize.width / 2
        let cloudTypes: [CloudType] = [.matsu, .take, .ume]
        var allCloudData: [CloudData] = []
        var cloudNodes: [Int: SKNode] = [:]

        // Player A（左側）に重ならないように配置（必ず指定数配置）
        var cloudCountA = 0
        var retryCountA = 0
        let maxRetries = 500  // 最大リトライ回数

        while cloudCountA < cloudsPerPlayer && retryCountA < maxRetries {
            let randomType = cloudTypes.randomElement() ?? .matsu
            let randomX = CGFloat.random(in: 80...(halfWidth - 80))
            let randomY = CGFloat.random(in: 150...(sceneSize.height - 100))
            let randomWidth = CGFloat.random(in: 50...90)
            let randomHeight = CGFloat.random(in: 30...50)

            let candidateData = CloudData(
                id: cloudCountA + 1,
                type: randomType,
                position: CGPoint(x: randomX, y: randomY),
                size: CGSize(width: randomWidth, height: randomHeight),
                lightningInterval: randomType == .matsu ? Double.random(in: 2.5...4.0) : nil,
                speedThreshold: randomType == .take ? CGFloat.random(in: 40...60) : nil
            )

            // 既存の雲と重なっていないかチェック
            if !isOverlapping(candidateData, with: allCloudData) {
                allCloudData.append(candidateData)

                let cloudNode = createCloudNode(cloudData: candidateData)
                cloudNode.position = candidateData.position
                cloudNode.zPosition = 5
                scene.addChild(cloudNode)
                cloudNodes[candidateData.id] = cloudNode

                cloudCountA += 1
            }

            retryCountA += 1
        }

        // Player B（右側）に重ならないように配置（必ず指定数配置）
        var cloudCountB = 0
        var retryCountB = 0

        while cloudCountB < cloudsPerPlayer && retryCountB < maxRetries {
            let randomType = cloudTypes.randomElement() ?? .matsu
            let randomX = CGFloat.random(in: (halfWidth + 80)...(sceneSize.width - 80))
            let randomY = CGFloat.random(in: 150...(sceneSize.height - 100))
            let randomWidth = CGFloat.random(in: 50...90)
            let randomHeight = CGFloat.random(in: 30...50)

            let candidateData = CloudData(
                id: cloudCountB + 101,
                type: randomType,
                position: CGPoint(x: randomX, y: randomY),
                size: CGSize(width: randomWidth, height: randomHeight),
                lightningInterval: randomType == .matsu ? Double.random(in: 2.5...4.0) : nil,
                speedThreshold: randomType == .take ? CGFloat.random(in: 40...60) : nil
            )

            // 既存の雲と重なっていないかチェック
            if !isOverlapping(candidateData, with: allCloudData) {
                allCloudData.append(candidateData)

                let cloudNode = createCloudNode(cloudData: candidateData)
                cloudNode.position = candidateData.position
                cloudNode.zPosition = 5
                scene.addChild(cloudNode)
                cloudNodes[candidateData.id] = cloudNode

                cloudCountB += 1
            }

            retryCountB += 1
        }

        // 雲データを物理エンジンに送信
        sendCloudDataToPhysicsEngine(cloudData: allCloudData, physicsCoordinator: physicsCoordinator)

        print("✅ Loaded \(cloudNodes.count) clouds to GameScene")
        return cloudNodes
    }

    /// 雲データを物理エンジンに送信
    @MainActor
    private static func sendCloudDataToPhysicsEngine(
        cloudData: [CloudData],
        physicsCoordinator: GamePhysicsCoordinator?
    ) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let cloudConfig = CloudConfig(clouds: cloudData)
            let jsonData = try encoder.encode(cloudConfig)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                try physicsCoordinator?.loadCloudData(json: jsonString)
                print("✅ Cloud data sent to physics engine")
                print("📋 Cloud data:\n\(jsonString)")
            }
        } catch {
            print("❌ Failed to send cloud data to physics engine: \(error)")
        }
    }

    /// 雲のビジュアルノードを作成
    private static func createCloudNode(cloudData: CloudData) -> SKNode {
        let container = SKNode()

        // 雲の種類に応じた画像名（現在は雷雲のみ使用）
        let imageName: String
        switch cloudData.type {
        case .matsu:  // 松：雷ギミック付き
            imageName = "kaminari_kumo"
        case .take, .ume:   // 竹・梅：障害物雲（現在は非表示）
            // 空のノードを返す（将来の実装用）
            return container
        }

        // Assets画像を使った雲（アスペクト比を保持）
        let cloudTexture = SKTexture(imageNamed: imageName)

        // テクスチャの元のアスペクト比を取得
        let textureSize = cloudTexture.size()
        let aspectRatio = textureSize.width / textureSize.height

        // cloudData.size.widthを基準に、アスペクト比を保持したサイズを計算
        let targetWidth = cloudData.size.width
        let targetHeight = targetWidth / aspectRatio

        let cloudSprite = SKSpriteNode(texture: cloudTexture, size: CGSize(width: targetWidth, height: targetHeight))
        cloudSprite.position = CGPoint(x: 0, y: 0)
        container.addChild(cloudSprite)

        // ふわふわと上下に動くアニメーション
        let randomDuration = Double.random(in: 3.0...5.0)
        let randomDistance = CGFloat.random(in: 15...25)
        let moveUp = SKAction.moveBy(x: 0, y: randomDistance, duration: randomDuration)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = moveUp.reversed()
        let sequence = SKAction.sequence([moveUp, moveDown])
        cloudSprite.run(SKAction.repeatForever(sequence))

        return container
    }

    /// 雲が既存の雲と重なっているかチェック
    /// - Parameters:
    ///   - newCloud: 新しい雲のデータ
    ///   - existingClouds: 既存の雲のリスト
    /// - Returns: 重なっている場合は true
    private static func isOverlapping(_ newCloud: CloudData, with existingClouds: [CloudData]) -> Bool {
        let margin: CGFloat = 20  // 雲同士の最小間隔

        for existingCloud in existingClouds {
            // 新しい雲の矩形（マージン込み）
            let newRect = CGRect(
                x: newCloud.position.x - newCloud.size.width / 2 - margin,
                y: newCloud.position.y - newCloud.size.height / 2 - margin,
                width: newCloud.size.width + margin * 2,
                height: newCloud.size.height + margin * 2
            )

            // 既存の雲の矩形（マージン込み）
            let existingRect = CGRect(
                x: existingCloud.position.x - existingCloud.size.width / 2 - margin,
                y: existingCloud.position.y - existingCloud.size.height / 2 - margin,
                width: existingCloud.size.width + margin * 2,
                height: existingCloud.size.height + margin * 2
            )

            // 矩形の重なりチェック
            if newRect.intersects(existingRect) {
                return true
            }
        }

        return false
    }

    // MARK: - Helper Structures

    /// JSON構造
    struct CloudConfig: Codable {
        let clouds: [CloudData]
    }
}
