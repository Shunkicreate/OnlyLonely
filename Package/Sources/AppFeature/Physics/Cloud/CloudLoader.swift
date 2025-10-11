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

        // Player A（左側）に重ならないように配置
        for i in 0..<cloudsPerPlayer {
            let randomType = cloudTypes.randomElement() ?? .matsu
            var cloudData: CloudData?
            var attempts = 0
            let maxAttempts = 50  // 最大試行回数

            // 重ならない位置を見つけるまで試行
            while cloudData == nil && attempts < maxAttempts {
                let randomX = CGFloat.random(in: 50...(halfWidth - 50))
                let randomY = CGFloat.random(in: 200...(sceneSize.height - 100))
                let randomWidth = CGFloat.random(in: 80...140)
                let randomHeight = CGFloat.random(in: 40...70)

                let candidateData = CloudData(
                    id: i + 1,
                    type: randomType,
                    position: CGPoint(x: randomX, y: randomY),
                    size: CGSize(width: randomWidth, height: randomHeight),
                    lightningInterval: randomType == .matsu ? Double.random(in: 2.5...4.0) : nil,
                    speedThreshold: randomType == .take ? CGFloat.random(in: 40...60) : nil
                )

                // 既存の雲と重なっていないかチェック
                if !isOverlapping(candidateData, with: allCloudData) {
                    cloudData = candidateData
                }
                attempts += 1
            }

            // 有効な位置が見つかった場合のみ追加
            if let validCloudData = cloudData {
                allCloudData.append(validCloudData)

                let cloudNode = createCloudNode(cloudData: validCloudData)
                cloudNode.position = validCloudData.position
                cloudNode.zPosition = 5
                scene.addChild(cloudNode)
                cloudNodes[validCloudData.id] = cloudNode
            }
        }

        // Player B（右側）に重ならないように配置
        for i in 0..<cloudsPerPlayer {
            let randomType = cloudTypes.randomElement() ?? .matsu
            var cloudData: CloudData?
            var attempts = 0
            let maxAttempts = 50

            while cloudData == nil && attempts < maxAttempts {
                let randomX = CGFloat.random(in: (halfWidth + 50)...(sceneSize.width - 50))
                let randomY = CGFloat.random(in: 200...(sceneSize.height - 100))
                let randomWidth = CGFloat.random(in: 80...140)
                let randomHeight = CGFloat.random(in: 40...70)

                let candidateData = CloudData(
                    id: i + 101,
                    type: randomType,
                    position: CGPoint(x: randomX, y: randomY),
                    size: CGSize(width: randomWidth, height: randomHeight),
                    lightningInterval: randomType == .matsu ? Double.random(in: 2.5...4.0) : nil,
                    speedThreshold: randomType == .take ? CGFloat.random(in: 40...60) : nil
                )

                if !isOverlapping(candidateData, with: allCloudData) {
                    cloudData = candidateData
                }
                attempts += 1
            }

            if let validCloudData = cloudData {
                allCloudData.append(validCloudData)

                let cloudNode = createCloudNode(cloudData: validCloudData)
                cloudNode.position = validCloudData.position
                cloudNode.zPosition = 5
                scene.addChild(cloudNode)
                cloudNodes[validCloudData.id] = cloudNode
            }
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

        // 雲の画像を使用
        let cloudTexture = SKTexture(imageNamed: "kumo")
        let cloudSprite = SKSpriteNode(texture: cloudTexture, size: cloudData.size)

        // 雲の種類に応じた色調整（カラーブレンド）
        switch cloudData.type {
        case .matsu:  // 松：雷ギミック付き（暗めのグレー）
            cloudSprite.colorBlendFactor = 0.3
            cloudSprite.color = UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
        case .take:   // 竹：速度依存（薄い白）
            cloudSprite.colorBlendFactor = 0.1
            cloudSprite.color = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        case .ume:    // 梅：完全障害物（デフォルトカラー）
            cloudSprite.colorBlendFactor = 0
        }

        container.addChild(cloudSprite)

        // 雲の種類を示すアイコン（小さめに表示）
        let typeLabel = SKLabelNode(text: cloudTypeEmoji(cloudData.type))
        typeLabel.fontSize = 20
        typeLabel.fontName = "HiraginoSans-W6"
        typeLabel.verticalAlignmentMode = .center
        typeLabel.position = CGPoint(x: 0, y: 0)
        typeLabel.zPosition = 1

        // アイコンの背景（見やすくするため）
        let iconBackground = SKShapeNode(circleOfRadius: 15)
        iconBackground.fillColor = .white.withAlphaComponent(0.7)
        iconBackground.strokeColor = .clear
        iconBackground.position = CGPoint(x: 0, y: 0)
        iconBackground.zPosition = 0.5
        container.addChild(iconBackground)
        container.addChild(typeLabel)

        // ふわふわアニメーション
        let floatUp = SKAction.moveBy(x: 0, y: 10, duration: TimeInterval.random(in: 2.0...3.0))
        let floatDown = SKAction.moveBy(x: 0, y: -10, duration: TimeInterval.random(in: 2.0...3.0))
        floatUp.timingMode = .easeInEaseOut
        floatDown.timingMode = .easeInEaseOut
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)

        // 少し拡大縮小
        let scaleUp = SKAction.scale(to: 1.05, duration: TimeInterval.random(in: 2.5...3.5))
        let scaleDown = SKAction.scale(to: 0.95, duration: TimeInterval.random(in: 2.5...3.5))
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let scaleForever = SKAction.repeatForever(scaleSequence)

        container.run(floatForever)
        cloudSprite.run(scaleForever)

        return container
    }

    /// 雲の種類に応じた絵文字
    private static func cloudTypeEmoji(_ type: CloudType) -> String {
        switch type {
        case .matsu:  return "⚡"  // 松：雷
        case .take:   return "💨"  // 竹：風
        case .ume:    return "🚫"  // 梅：禁止
        }
    }

    /// 単一レーン用の雲データを生成して配置
    /// - Parameters:
    ///   - sceneSize: シーンのサイズ
    ///   - cloudCount: 配置する雲の数
    ///   - lane: プレイヤーレーン
    ///   - physicsCoordinator: 物理エンジンコーディネーター
    ///   - scene: 雲を追加するシーン
    /// - Returns: 生成された雲ノードの辞書 [cloudId: SKNode]
    @MainActor
    static func loadCloudsForLane(
        sceneSize: CGSize,
        cloudCount: Int = 5,
        lane: PlayerSlot,
        physicsCoordinator: GamePhysicsCoordinator?,
        scene: SKScene
    ) -> [Int: SKNode] {
        let cloudTypes: [CloudType] = [.matsu, .take, .ume]
        var allCloudData: [CloudData] = []
        var cloudNodes: [Int: SKNode] = [:]

        // レーンごとのIDオフセット
        let idOffset = lane == .playerA ? 1 : 101

        // レーン用の雲を配置
        for i in 0..<cloudCount {
            let randomType = cloudTypes.randomElement() ?? .matsu
            var cloudData: CloudData?
            var attempts = 0
            let maxAttempts = 50

            while cloudData == nil && attempts < maxAttempts {
                // レーンの中央付近にランダムに配置
                let randomX = CGFloat.random(in: (sceneSize.width * 0.2)...(sceneSize.width * 0.8))
                // 高さを調整（150〜画面の高さの50%まで）
                let randomY = CGFloat.random(in: 150...(sceneSize.height * 0.5))
                let randomWidth = CGFloat.random(in: 100...160)
                let randomHeight = CGFloat.random(in: 50...80)

                let candidateData = CloudData(
                    id: i + idOffset,
                    type: randomType,
                    position: CGPoint(x: randomX, y: randomY),
                    size: CGSize(width: randomWidth, height: randomHeight),
                    lightningInterval: randomType == .matsu ? Double.random(in: 2.5...4.0) : nil,
                    speedThreshold: randomType == .take ? CGFloat.random(in: 40...60) : nil
                )

                if !isOverlapping(candidateData, with: allCloudData) {
                    cloudData = candidateData
                }
                attempts += 1
            }

            if let validCloudData = cloudData {
                allCloudData.append(validCloudData)

                let cloudNode = createCloudNode(cloudData: validCloudData)
                cloudNode.position = validCloudData.position
                cloudNode.zPosition = 5
                scene.addChild(cloudNode)
                cloudNodes[validCloudData.id] = cloudNode
            }
        }

        // 雲データを物理エンジンに送信
        sendCloudDataToPhysicsEngine(cloudData: allCloudData, physicsCoordinator: physicsCoordinator)

        print("✅ Loaded \(cloudNodes.count) clouds for \(lane) lane")
        return cloudNodes
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
