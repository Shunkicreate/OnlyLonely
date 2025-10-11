//
//  HarajukuPlayerNameInputScreen.swift
//  OnlyLonely
//
//  プレイヤー名入力画面 - 原宿系ふわふわバージョン
//

import SwiftUI

struct HarajukuPlayerNameInputScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerName: String = ""
    @State private var isBouncing = false
    @State private var showContent = false
    @State private var sparkleScale: CGFloat = 1.0
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            // カラフル背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.4)

            VStack(spacing: HarajukuSpacing.xl) {
                Spacer()

                // タイトル
                VStack(spacing: HarajukuSpacing.md) {
                    // デコレーション（上）
                    HStack(spacing: 12) {
                        ForEach(["🌟", "✨", "💫", "✨", "🌟"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 24))
                                .scaleEffect(sparkleScale)
                        }
                    }
                    .animation(HarajukuAnimation.sparkle(), value: sparkleScale)
                    .opacity(showContent ? 1 : 0)

                    SparkleText(
                        text: "あなたのなまえは？",
                        size: 36,
                        color: HarajukuColors.pastelPink
                    )
                    .opacity(showContent ? 1 : 0)

                    Text("💗 なまえを おしえてね 💗")
                        .font(HarajukuTypography.body(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(HarajukuColors.textSecondary)
                        .opacity(showContent ? 1 : 0)
                }

                // 大きなふわふわ風船
                FluffyCard(gradient: HarajukuColors.candyGradient) {
                    VStack(spacing: HarajukuSpacing.lg) {
                        FluffyBalloon(
                            color: HarajukuColors.pastelPink,
                            size: 120,
                            emoji: playerName.isEmpty ? "❓" : "💖"
                        )

                        Text(playerName.isEmpty ? "あなたの風船" : "\(playerName)の風船")
                            .font(HarajukuTypography.subtitle(size: 18))
                            .foregroundColor(HarajukuColors.textPrimary)
                    }
                    .padding(.vertical, HarajukuSpacing.lg)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)
                .padding(.horizontal, HarajukuSpacing.xl)

                // 名前入力
                VStack(spacing: HarajukuSpacing.md) {
                    FluffyTextField(
                        placeholder: "なまえを いれてね",
                        text: $playerName,
                        emoji: "✏️",
                        gradient: HarajukuColors.pinkPurpleGradient
                    )
                    .focused($isTextFieldFocused)

                    // ヒント
                    HStack(spacing: 8) {
                        Text("💡")
                        Text("れい: たろう、Player 1")
                            .font(HarajukuTypography.caption(size: 12))
                            .foregroundColor(HarajukuColors.textSecondary)
                    }
                }
                .padding(.horizontal, HarajukuSpacing.xl)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // ボタンエリア
                VStack(spacing: HarajukuSpacing.md) {
                    FluffyButton(
                        title: "そらへ とびたつ！",
                        emoji: "🎈",
                        gradient: HarajukuColors.rainbowGradient
                    ) {
                        joinGame()
                    }
                    .disabled(!isValidInput)
                    .opacity(showContent ? (isValidInput ? 1.0 : 0.5) : 0)

                    // メッセージ
                    VStack(spacing: 4) {
                        if playerName.isEmpty {
                            Text("💭 なまえを いれてね")
                                .font(HarajukuTypography.caption(size: 12))
                                .foregroundColor(HarajukuColors.textSecondary)
                        } else {
                            HStack(spacing: 6) {
                                Text("✨")
                                Text("'\(playerName)' として さんかするよ")
                                    .font(HarajukuTypography.caption(size: 12))
                                    .foregroundColor(HarajukuColors.textPrimary)
                                    .fontWeight(.semibold)
                                Text("✨")
                            }
                        }
                    }
                    .opacity(showContent ? 0.8 : 0)
                }

                Spacer()
                    .frame(height: HarajukuSpacing.xxxl)
            }
        }
        .onAppear {
            startAnimations()
        }
        .navigationBarBackButtonHidden()
    }

    private var isValidInput: Bool {
        !playerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func startAnimations() {
        isBouncing = true
        sparkleScale = 1.2

        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            showContent = true
        }

        // キーボードを自動表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isTextFieldFocused = true
        }
    }

    private func joinGame() {
        // バリデーションチェック
        guard isValidInput else { return }

        // 触覚フィードバック
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // 先頭・末尾の空白を削除（トリミング）
        let trimmedName = playerName.trimmingCharacters(in: .whitespaces)
        let name = trimmedName.isEmpty ? "たびびと \(Int.random(in: 1...99))" : trimmedName

        print("✅ Player joined: \(name)")

        // WebSocket でプレイヤー参加メッセージを送信（後で実装）
        // webSocketService.send(.playerJoin(playerName: name, playerId: UUID().uuidString))

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            coordinator.navigate(to: .waiting)
        }
    }
}

#Preview {
    HarajukuPlayerNameInputScreen()
        .environmentObject(AppCoordinator())
}
