//
//  ResultScreen.swift
//  OnlyLonely
//
//  12. リザルト画面（iPhone）
//  iPhone のみ
//

import SwiftUI

struct iPhoneResultScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var playerAltitude: Double = 450
    @State private var opponentAltitude: Double = 380
    @State private var showAnimation = false

    var isWinner: Bool {
        playerAltitude > opponentAltitude
    }

    var isDraw: Bool {
        playerAltitude == opponentAltitude
    }

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: isWinner ? [
                    Color(red: 1.0, green: 0.9, blue: 0.6),
                    Color(red: 1.0, green: 0.8, blue: 0.4)
                ] : [
                    Color(red: 0.6, green: 0.7, blue: 0.9),
                    Color(red: 0.7, green: 0.8, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // 結果表示
                VStack(spacing: 16) {
                    if isDraw {
                        Text("引き分け!")
                            .nikumaruTitle(size: 48)
                            .foregroundColor(.white)
                    } else if isWinner {
                        VStack(spacing: 8) {
                            Text("勝利!")
                                .nikumaruTitle(size: 48)
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
                        VStack(spacing: 8) {
                            Text("敗北...")
                                .nikumaruTitle(size: 48)
                                .foregroundColor(.white)

                            Text("🎈")
                                .font(.system(size: 60))
                        }
                    }
                }

                // スコア表示
                VStack(spacing: 16) {
                    ResultRow(
                        label: "あなた",
                        altitude: playerAltitude,
                        isHighlight: isWinner
                    )

                    ResultRow(
                        label: "相手",
                        altitude: opponentAltitude,
                        isHighlight: !isWinner && !isDraw
                    )

                    if !isDraw {
                        Text("差: \(isWinner ? "+" : "")\(Int(playerAltitude - opponentAltitude))m")
                            .nikumaruBody(size: 18)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // ボタン
                VStack(spacing: 16) {
                    Button {
                        coordinator.replace(with: .connection)
                    } label: {
                        Text("もう一度")
                            .nikumaruBody(size: 20)
                            .foregroundColor(.white)
                            .frame(width: 200)
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
                            .nikumaruBody(size: 20)
                            .foregroundColor(.white)
                            .frame(width: 200)
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

struct ResultRow: View {
    let label: String
    let altitude: Double
    let isHighlight: Bool

    var body: some View {
        HStack {
            Text(label)
                .nikumaruBody(size: 18)
                .foregroundColor(.white)
                .frame(width: 80, alignment: .leading)

            Spacer()

            Text("\(Int(altitude))m")
                .nikumaruHeadline(size: 24)
                .foregroundColor(isHighlight ? .yellow : .white)

            if isHighlight {
                Text("👑")
                    .font(.system(size: 24))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHighlight ? Color.yellow.opacity(0.3) : Color.white.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isHighlight ? Color.yellow : Color.clear, lineWidth: 2)
                )
        )
    }
}

#Preview {
    iPhoneResultScreen()
        .environmentObject(AppCoordinator())
}
