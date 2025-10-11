//
//  CalibrationScreen.swift
//  OnlyLonely
//
//  08. キャリブレーション画面（iPhone）
//  iPhone のみ
//  ※ MVP では省略可能
//

import SwiftUI

struct CalibrationScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var micLevelManager = MicrophoneLevelManager()

    @State private var currentLevel: Float = 0
    @State private var minThreshold: Float = 0.1
    @State private var maxThreshold: Float = 0.9

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

            VStack(spacing: 30) {
                Spacer()

                Text("息の感度調整")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Text("iPhone に息を吹きかけて")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))

                    Text("ください")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }

                // プレビュー風船
                VStack {
                    Text("🎈")
                        .font(.system(size: 60))
                        .offset(y: -CGFloat(currentLevel) * 50)
                        .animation(.easeOut(duration: 0.3), value: currentLevel)

                    Text("✨✨")
                        .font(.system(size: 24))
                }

                // 音圧レベルメーター
                VStack(spacing: 12) {
                    Text("音圧レベル")
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
                                .frame(width: geometry.size.width * CGFloat(currentLevel))
                                .animation(.easeOut(duration: 0.1), value: currentLevel)
                        }
                    }
                    .frame(height: 30)

                    // 目標範囲表示
                    HStack {
                        Text("最小")
                            .font(.caption)
                        Spacer()
                        Text("目標")
                            .font(.caption)
                        Spacer()
                        Text("最大")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 40)

                Text("現在の音圧: \(String(format: "%.2f", currentLevel))")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))

                Spacer()

                // ボタン
                VStack(spacing: 16) {
                    Button {
                        completeCalibration()
                    } label: {
                        Text("完了")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.6))
                            )
                    }

                    Button {
                        skipCalibration()
                    } label: {
                        Text("スキップ")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            micLevelManager.startMonitoring()
            startMonitoring()
        }
        .onDisappear {
            micLevelManager.stopMonitoring()
        }
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let peakLevel = micLevelManager.peakHoldLevel {
                let normalized = (peakLevel + 60) / 60
                currentLevel = max(0, min(1.0, normalized))
            }
        }
    }

    private func completeCalibration() {
        // キャリブレーション設定を保存
        // webSocketService.send(.calibrationComplete(...))

        coordinator.navigate(to: .waiting)
    }

    private func skipCalibration() {
        // デフォルト値を使用
        coordinator.navigate(to: .waiting)
    }
}

#Preview {
    CalibrationScreen()
        .environmentObject(AppCoordinator())
}
