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

    @State private var timeRemaining: Int = 60
    @State private var currentAltitude: Double = 0

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

                    Text("現在の高度: \(Int(currentAltitude))m")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.yellow)
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
        }
        .navigationBarBackButtonHidden()
    }

    private func startGame() {
        // マイク監視開始
        micLevelManager.startMonitoring()

        // タイマー開始
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                // ゲーム終了
                coordinator.navigate(to: .iPhoneResult)
            }
        }

        // 高度更新（30Hz）
        Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            // 高度を更新（簡易シミュレーション）
            currentAltitude += Double(micLevelManager.windForce) * 2.0
        }
    }
}

#Preview {
    iPhoneGameplayScreen()
        .environmentObject(AppCoordinator())
}
