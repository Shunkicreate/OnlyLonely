//
//  MotionManager.swift
//  OnlyLonely
//
//  Created by Yoshiki Naruo on 2025/10/11.
//

import CoreMotion
import Foundation

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var pitch: Double = 0.0  // 前後の傾き（X軸）
    @Published var roll: Double = 0.0   // 左右の傾き（Y軸）
    @Published var yaw: Double = 0.0    // 回転（Z軸）

    init() {
        startDeviceMotionUpdates()
    }

    func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("デバイスモーションが利用できません")
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.1 // 0.1秒ごとに更新
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
            guard let motion = motion, error == nil else {
                if let error = error {
                    print("モーションデータ取得エラー: \(error.localizedDescription)")
                }
                return
            }

            // 姿勢データを度数法に変換（ラジアンから度へ）
            self?.pitch = motion.attitude.pitch * 180.0 / .pi
            self?.roll = motion.attitude.roll * 180.0 / .pi
            self?.yaw = motion.attitude.yaw * 180.0 / .pi
        }
    }

    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    deinit {
        stopDeviceMotionUpdates()
    }
}
