//
//  GameplayScreen.swift
//  OnlyLonely
//
//  11. ゲームプレイ画面（iPhone）
//  iPhone のみ
//

import SwiftUI
import AVFoundation

struct iPhoneGameplayScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var micLevelManager = MicrophoneLevelManager()
    @StateObject private var motionManager = MotionManager()

    @State private var timeRemaining: Int = 60
    @State private var currentAltitude: Double = 0
    @State private var windForce: Float = 0
    @State private var previousWindForce: Float = 0 // 前回の風力値（サンプル不足時用）
    @State private var gameTimer: Timer?
    @State private var altitudeTimer: Timer?

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.8, green: 0.9, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // 残り時間
                Text("残り時間: \(timeRemaining)秒")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.top, 20)

                Spacer()

                // プレイヤー情報
                VStack(spacing: 12) {
                    Text("Player A")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // 風船
                VStack {
                    Text("🎈")
                        .font(.system(size: 80))
                        .scaleEffect(1.0 + CGFloat(micLevelManager.windForce) * 0.3)
                        .animation(.easeInOut(duration: 0.3), value: micLevelManager.windForce)

                    Text("✨✨")
                        .font(.system(size: 24))
                        .opacity(Double(micLevelManager.windForce))
                }
                .offset(x: balloonHorizontalOffset)
                .animation(.easeInOut(duration: 0.15), value: motionManager.roll)

                // 音圧レベルメーター
                VStack(spacing: 8) {
                    Text("風力レベル")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 背景
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))

                            // レベル表示
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .yellow, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(micLevelManager.windForce))
                                .animation(.easeOut(duration: 0.1), value: micLevelManager.windForce)
                        }
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 20)

                Spacer()

                // 指示テキスト
                VStack(spacing: 8) {
                    Text("息を吹きかけて")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text("風船を飛ばそう!")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            micLevelManager.stopMonitoring()
            motionManager.stopDeviceMotionUpdates()
            stopTimers()
        }
        .navigationBarBackButtonHidden()
    }

    private func startGame() {
        // マイク監視開始
        micLevelManager.startMonitoring()
        motionManager.startDeviceMotionUpdates()
        stopTimers()

        // タイマー開始
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                gameTimer = nil
                // ゲーム終了
                altitudeTimer?.invalidate()
                altitudeTimer = nil
                Task { @MainActor in
                    coordinator.navigate(to: .iPhoneResult)
                }
            }
        }

        // 高度更新（30Hz）
        altitudeTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            // 高度を更新（簡易シミュレーション）
            currentAltitude += Double(micLevelManager.windForce) * 2.0
        }
    }

    // MARK: - バリデーション関数

    /// RMS 値のバリデーション
    private func validateRMSValue(_ value: Float) -> Float? {
        // NaN/Infinite チェック
        guard value.isFinite else {
            print("⚠️ Invalid RMS value (NaN or Infinite): \(value)")
            return nil
        }

        // 負の値チェック
        guard value >= 0 else {
            print("⚠️ Negative RMS value: \(value), using 0.0")
            return 0.0
        }

        return value
    }

    /// 正規化後の風力値のバリデーション
    private func validateNormalizedForce(_ force: Float) -> Float {
        // NaN/Infinite チェック
        guard force.isFinite else {
            print("⚠️ Invalid normalized force (NaN or Infinite), using previous value")
            return previousWindForce
        }

        // 0.0〜1.0 にクランプ
        let clampedForce = max(0.0, min(1.0, force))

        if clampedForce != force {
            print("⚠️ Force value \(force) out of range, clamped to \(clampedForce)")
        }

        return clampedForce
    }

    private func updateWindForce() {
        // マイクレベルから風力を計算
        if let peakLevel = micLevelManager.peakHoldLevel {
            // 最小閾値を設定（小さい音を拾わないようにする）
            let threshold: Float = -20.0 // -20dB以下は無視

            guard peakLevel > threshold else {
                windForce = 0
                return
            }

            // dBを0.0〜1.0に正規化（感度を下げるため範囲を広げた）
            let normalized = (peakLevel + 50) / 50 // -50dB 〜 0dB を 0.0 〜 1.0 に
            // さらに0.7倍して感度を下げる
            let sensitivity = 0.7
            windForce = max(0, min(1.0, normalized * Float(sensitivity)))
        } else {
            // サンプル不足時は前回の値を使用
            windForce = previousWindForce
        }
    }

    /// 傾きに応じて風船の左右位置を調整
    private var balloonHorizontalOffset: CGFloat {
        // 25度の傾きで最大移動（左右）
        let tiltRange: Double = 25
        let normalizedTilt = max(-1, min(1, motionManager.roll / tiltRange))
        let maxOffset: CGFloat = 120
        return CGFloat(normalizedTilt) * maxOffset
    }

    private func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        altitudeTimer?.invalidate()
        altitudeTimer = nil
    }
}

#Preview {
    iPhoneGameplayScreen()
        .environmentObject(AppCoordinator())
}
