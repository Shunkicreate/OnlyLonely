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

    /// 左右の傾き（Y軸）
    @Published var roll: Double = 0.0

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
            self?.roll = motion.attitude.roll * 180.0 / .pi
        }
    }

    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    deinit {
        stopDeviceMotionUpdates()
    }
}
