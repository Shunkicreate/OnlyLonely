//
//  WaitingScreen.swift
//  OnlyLonely
//
//  09. 待機画面（iPhone）
//  iPhone のみ
//

import SwiftUI

struct WaitingScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var opponentReady = false
    @State private var balloonOffset: CGFloat = 0

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

                Text("準備完了!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // 風船アニメーション
                HStack(spacing: 20) {
                    Text("🎈")
                        .font(.system(size: 60))
                        .offset(y: balloonOffset)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: balloonOffset
                        )

                    Text("✨✨")
                        .font(.system(size: 30))
                }

                // 状態表示
                VStack(spacing: 20) {
                    PlayerStatusRow(
                        label: "あなた",
                        playerName: "Player A",
                        isReady: true
                    )

                    PlayerStatusRow(
                        label: "相手",
                        playerName: "Player B",
                        isReady: opponentReady
                    )
                }
                .padding(.horizontal, 40)

                Text(opponentReady ? "まもなく開始します..." : "相手の準備を待っています...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            balloonOffset = 20

            // デモ: 3秒後に相手が準備完了
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                opponentReady = true

                // 両プレイヤー準備完了後、カウントダウン画面へ遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    coordinator.navigate(to: .countdown)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct PlayerStatusRow: View {
    let label: String
    let playerName: String
    let isReady: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                Text(playerName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 8) {
                if isReady {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("準備完了")
                        .foregroundColor(.green)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
                    Text("準備中...")
                        .foregroundColor(.yellow)
                }
            }
            .font(.system(size: 16, weight: .medium))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
        )
    }
}

#Preview {
    WaitingScreen()
        .environmentObject(AppCoordinator())
}
