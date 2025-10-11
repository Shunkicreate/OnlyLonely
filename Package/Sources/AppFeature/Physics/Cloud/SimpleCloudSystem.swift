//
//  SimpleCloudSystem.swift
//  OnlyLonely
//
//  シンプルな雲システムの実装
//

import Foundation
import CoreGraphics

class SimpleCloudSystem: CloudSystem {
    private var clouds: [CloudData] = []
    private var lightningState: [Int: LightningState] = [:]

    // 雷の状態管理
    private struct LightningState {
        var lastTriggerTime: TimeInterval
        var isActive: Bool

        init() {
            self.lastTriggerTime = 0
            self.isActive = false
        }
    }

    // JSON構造
    private struct CloudConfig: Codable {
        let clouds: [CloudData]
    }

    func loadClouds(from json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw NSError(
                domain: "CloudSystem",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string encoding"]
            )
        }

        let decoder = JSONDecoder()
        let config = try decoder.decode(CloudConfig.self, from: data)
        clouds = config.clouds

        // 松の雲の雷状態を初期化
        for cloud in clouds where cloud.type == .matsu {
            lightningState[cloud.id] = LightningState()
        }

        print("✅ Loaded \(clouds.count) clouds")
    }

    func checkCollision(balloonPosition: CGPoint, balloonVelocity: CGVector) -> CollisionResult {
        let currentTime = Date().timeIntervalSince1970

        for cloud in clouds {
            let cloudRect = CGRect(
                x: cloud.position.x - cloud.size.width / 2,
                y: cloud.position.y - cloud.size.height / 2,
                width: cloud.size.width,
                height: cloud.size.height
            )

            if cloudRect.contains(balloonPosition) {
                switch cloud.type {
                case .matsu:
                    // 松：雷判定（雷がアクティブかチェック）
                    if let state = lightningState[cloud.id], state.isActive {
                        return .lightning
                    } else {
                        // 雷がアクティブでない場合は通過可能
                        return .passThrough
                    }

                case .take:
                    // 竹：速度判定
                    let speed = sqrt(balloonVelocity.dx * balloonVelocity.dx + balloonVelocity.dy * balloonVelocity.dy)
                    let threshold = cloud.speedThreshold ?? PhysicsConstants.takeCloudSpeedThreshold

                    if speed >= threshold {
                        return .passThrough
                    } else {
                        return .blocked
                    }

                case .ume:
                    // 梅：完全障害物
                    return .blocked
                }
            }
        }

        // 雷のタイミング更新（松の雲）
        updateLightningStates(currentTime: currentTime)

        return .none
    }

    func triggerLightning(at cloudId: Int) {
        guard var state = lightningState[cloudId] else {
            print("⚠️ Cloud ID \(cloudId) not found for lightning trigger")
            return
        }

        state.isActive = true
        state.lastTriggerTime = Date().timeIntervalSince1970
        lightningState[cloudId] = state

        print("⚡ Lightning triggered at cloud \(cloudId)")
    }

    // MARK: - Private Methods

    /// 雷の状態を更新（松の雲）
    private func updateLightningStates(currentTime: TimeInterval) {
        for cloud in clouds where cloud.type == .matsu {
            guard var state = lightningState[cloud.id] else { continue }

            let interval = cloud.lightningInterval ?? PhysicsConstants.lightningIntervalMin

            // 雷の発生タイミングをチェック
            if currentTime - state.lastTriggerTime >= interval {
                triggerLightning(at: cloud.id)
            }

            // 雷がアクティブな場合、一定時間後に非アクティブにする
            if state.isActive && currentTime - state.lastTriggerTime >= 0.5 {
                state.isActive = false
                lightningState[cloud.id] = state
                print("⚡ Lightning deactivated at cloud \(cloud.id)")
            }
        }
    }
}
