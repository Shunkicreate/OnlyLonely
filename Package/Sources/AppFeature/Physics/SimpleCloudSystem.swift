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

    func loadClouds(from json: String) throws {
        // TODO: JSONデコード実装
        // 現在はプレースホルダー
        clouds = []
    }

    func checkCollision(balloonPosition: CGPoint, balloonVelocity: CGVector) -> CollisionResult {
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
                    // 松：雷判定（簡略版）
                    return .lightning

                case .take:
                    // 竹：速度判定
                    let speed = sqrt(balloonVelocity.dx * balloonVelocity.dx + balloonVelocity.dy * balloonVelocity.dy)
                    if speed >= (cloud.speedThreshold ?? PhysicsConstants.takeCloudSpeedThreshold) {
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

        return .none
    }

    func triggerLightning(at cloudId: Int) {
        // TODO: 雷エフェクト実装
    }
}
