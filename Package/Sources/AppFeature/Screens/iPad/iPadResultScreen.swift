//
//  ResultScreen.swift
//  OnlyLonely
//
//  05. リザルト画面（iPad）
//  iPad のみ
//

import SwiftUI

struct iPadResultScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerAAltitude: Double = 450
    @State private var playerBAltitude: Double = 380
    @State private var showAnimation = false

    var winner: PlayerSlot? {
        if playerAAltitude > playerBAltitude {
            return .playerA
        } else if playerBAltitude > playerAAltitude {
            return .playerB
        } else {
            return nil
        }
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

            VStack(spacing: 40) {
                Spacer()

                // 勝者表示
                if let winner = winner {
                    VStack(spacing: 16) {
                        Text("Winner: Player \(winner == .playerA ? "A" : "B")!")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("🎉")
                            .font(.system(size: 80))
                            .scaleEffect(showAnimation ? 1.2 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .repeatForever(autoreverses: true),
                                value: showAnimation
                            )
                    }
                } else {
                    Text("引き分け!")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // スコア表示
                VStack(spacing: 20) {
                    ScoreCard(
                        playerName: "Player A",
                        altitude: playerAAltitude,
                        color: .red,
                        isWinner: winner == .playerA
                    )

                    ScoreCard(
                        playerName: "Player B",
                        altitude: playerBAltitude,
                        color: .blue,
                        isWinner: winner == .playerB
                    )
                }
                .padding(.horizontal, 60)

                Spacer()

                // ボタン
                HStack(spacing: 30) {
                    Button {
                        coordinator.replace(with: .connectionWaiting)
                    } label: {
                        Text("もう一度")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 180)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.6))
                            )
                    }

                    Button {
                        coordinator.navigateToRoot()
                    } label: {
                        Text("終了")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 180)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.gray.opacity(0.6))
                            )
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            showAnimation = true
        }
        .navigationBarBackButtonHidden()
    }
}

struct ScoreCard: View {
    let playerName: String
    let altitude: Double
    let color: Color
    let isWinner: Bool

    var body: some View {
        HStack {
            Text(playerName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 150, alignment: .leading)

            Spacer()

            Text("\(Int(altitude))m")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(color)

            if isWinner {
                Text("👑")
                    .font(.system(size: 30))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isWinner ? Color.yellow.opacity(0.3) : Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isWinner ? Color.yellow : Color.clear, lineWidth: 3)
                )
        )
    }
}

#Preview {
    iPadResultScreen()
        .environmentObject(AppCoordinator())
}
