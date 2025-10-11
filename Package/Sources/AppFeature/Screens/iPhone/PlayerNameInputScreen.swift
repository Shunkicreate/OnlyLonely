//
//  PlayerNameInputScreen.swift
//  OnlyLonely
//
//  07. プレイヤー名入力画面（iPhone）- 原宿系ふわふわバージョン
//  iPhone のみ
//

import SwiftUI

struct PlayerNameInputScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerName: String = ""
    @State private var isFloating = false
    @State private var showContent = false
    @State private var sparkleRotation: Double = 0
    @FocusState private var isTextFieldFocused: Bool

    // バリデーション状態
    @State private var nameError: String? = nil

    // 定数
    private let maxNameLength = 10

    var body: some View {
        ZStack {
            // カラフル虹色背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.3)

            VStack(spacing: HarajukuSpacing.xl) {
                Spacer()

                // タイトル
                VStack(spacing: HarajukuSpacing.lg) {
                    // きらきら装飾
                    HStack(spacing: 12) {
                        Text("🌟")
                            .font(.system(size: 20))
                            .rotationEffect(.degrees(sparkleRotation))
                        RainbowText(
                            text: "あなたのなまえは？",
                            size: 32
                        )
                        Text("🌟")
                            .font(.system(size: 20))
                            .rotationEffect(.degrees(-sparkleRotation))
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)

                    Text("🎈 ふうせんにかいてね 🎈")
                        .font(HarajukuTypography.body(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(HarajukuColors.textSecondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -10)
                }

                // ふわふわ風船アニメーション
                PlayerBalloonView()
                    .frame(width: 130, height: 130)
                    .offset(y: isFloating ? -15 : 15)
                    .animation(
                        HarajukuAnimation.bounce(duration: 2.5),
                        value: isFloating
                    )
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .padding(.vertical, HarajukuSpacing.lg)

                // 名前入力フィールド
                VStack(spacing: HarajukuSpacing.md) {
                    FluffyTextField(
                        placeholder: "なまえをかいてね",
                        text: $playerName,
                        emoji: "✏️",
                        gradient: HarajukuColors.pinkPurpleGradient,
                        borderColor: HarajukuColors.pastelPink
                    )

                    Text("ふうせんにかざられるよ！")
                        .font(HarajukuTypography.caption(size: 12))
                        .fontWeight(.semibold)
                        .foregroundColor(HarajukuColors.textSecondary)

                    // 文字数カウンター
                    HStack(spacing: 4) {
                        Text("\(playerName.count)")
                            .foregroundColor(playerName.count > maxNameLength ? Color(hex: "#FF6B9D") : HarajukuColors.pastelPurple)
                        Text("/ \(maxNameLength) もじ")
                            .foregroundColor(HarajukuColors.textSecondary)
                    }
                    .font(HarajukuTypography.caption(size: 11))
                    .fontWeight(.medium)

                    // バリデーションエラーメッセージ領域（固定高さでレイアウト崩れ防止）
                    Text(nameError ?? " ")
                        .font(HarajukuTypography.caption(size: 12))
                        .foregroundColor(Color(hex: "#FF6B9D"))
                        .multilineTextAlignment(.center)
                        .opacity(nameError != nil ? 1 : 0)
                        .frame(minHeight: 16)
                }
                .padding(.horizontal, HarajukuSpacing.xl)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // 参加ボタン
                VStack(spacing: HarajukuSpacing.md) {
                    FluffyButton(
                        title: "そらへとびたつ！",
                        emoji: "🎈",
                        gradient: HarajukuColors.candyGradient,
                        shadowColor: HarajukuColors.pastelPink
                    ) {
                        joinGame()
                    }
                    .disabled(!isValidInput)
                    .opacity(showContent ? (isValidInput ? 1.0 : 0.5) : 0)

                    Text(playerName.isEmpty ? "なまえをいれてね" : "'\(playerName)' でさんかするよ！")
                        .font(HarajukuTypography.caption(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(HarajukuColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, HarajukuSpacing.xl)
                        .opacity(showContent ? 0.8 : 0)
                }

                Spacer()
                    .frame(height: HarajukuSpacing.xxxl)
            }
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: playerName) { _, newValue in
            validatePlayerName(newValue)
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - バリデーション関数

    private func validatePlayerName(_ name: String) {
        // 最大文字数チェック
        if name.count > maxNameLength {
            nameError = "\(maxNameLength)もじいないでいれてね"
            return
        }

        // 空白のみチェック
        if !name.isEmpty && name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "なまえをちゃんといれてね"
            return
        }

        // バリデーション成功
        nameError = nil
    }

    private var isValidInput: Bool {
        nameError == nil &&
        playerName.count <= maxNameLength &&
        !playerName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func startAnimations() {
        isFloating = true

        // きらきら回転
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // コンテンツフェードイン
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            showContent = true
        }

        // キーボードを自動表示（少し遅延）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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

        // 空欄またはトリミング後に空の場合はデフォルト名を使用
        let finalName = trimmedName.isEmpty ? "たびびと \(Int.random(in: 1...99))" : trimmedName

        print("✅ Player joined: \(finalName)")

        // WebSocket でプレイヤー参加メッセージを送信（後で実装）
        // webSocketService.send(.playerJoin(playerName: finalName, playerId: UUID().uuidString))

        // キャリブレーション画面をスキップして待機画面へ（MVP）
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            coordinator.navigate(to: .waiting)
        }
    }
}

// MARK: - Player Balloon View

private struct PlayerBalloonView: View {
    @State private var isPulsing = false

    var body: some View {
        FluffyBalloon(
            color: HarajukuColors.pastelPink,
            size: 100,
            emoji: "❓"
        )
    }
}

#Preview {
    PlayerNameInputScreen()
        .environmentObject(AppCoordinator())
}
