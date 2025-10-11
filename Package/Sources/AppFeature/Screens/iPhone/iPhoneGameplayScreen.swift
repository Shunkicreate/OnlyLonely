//
//  GameplayScreen.swift
//  OnlyLonely
//
//  11. ゲームプレイ画面（iPhone）
//  iPhone のみ
//

import SwiftUI
import AVFoundation
import UIKit

struct iPhoneGameplayScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var sessionManager: P2PSessionManager
    @EnvironmentObject private var connectionModel: ConnectionScreenModel
    @StateObject private var micLevelManager = MicrophoneLevelManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var screenModel: iPhoneGameplayScreenModel

    @State private var timeRemaining: Int = 60
    @State private var currentAltitude: Double = 0
    @State private var gameTimer: Timer?
    @State private var altitudeTimer: Timer?

    private let playerId: String

    init(playerId: String = "A") {
        _screenModel = StateObject(wrappedValue: iPhoneGameplayScreenModel())
        self.playerId = playerId
    }

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
                    .nikumaruBody(size: 20)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.top, 20)

                Spacer()

                // プレイヤー情報
                Text(playerDisplayName)
                    .nikumaruHeadline(size: 24)
                    .foregroundColor(.white)

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
                        .nikumaruCaption(size: 14)
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
                        .nikumaruBody(size: 20)
                        .foregroundColor(.white)

                    Text("風船を飛ばそう!")
                        .nikumaruBody(size: 20)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            screenModel.configure(sessionManager: sessionManager, playerId: playerId)
            screenModel.bindInputs(microphone: micLevelManager, motionManager: motionManager)
            startGame()
        }
        .onDisappear {
            micLevelManager.stopMonitoring()
            motionManager.stopDeviceMotionUpdates()
            stopTimers()
            screenModel.cancelBindings()
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
            screenModel.sendWindForce()
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

    private var playerDisplayName: String {
        let trimmed = connectionModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? UIDevice.current.name : trimmed
    }
}
