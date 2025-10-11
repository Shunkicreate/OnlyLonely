//
//  PlayerNameInputScreen.swift
//  OnlyLonely
//
//  07. プレイヤー名入力画面（iPhone）
//  iPhone のみ
//

import SwiftUI

struct PlayerNameInputScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerName: String = ""
    @State private var isFloating = false
    @State private var showContent = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            // 背景グラデーション
            AnimatedGradientBackground(colors: [
                OnlyLonelyColors.midnightBlue,
                OnlyLonelyColors.darkBlue,
                OnlyLonelyColors.skyBlue
            ])
            .ignoresSafeArea()

            // パーティクル
            ParticleView()
                .ignoresSafeArea()
                .opacity(0.3)

            VStack(spacing: OnlyLonelySpacing.xl) {
                Spacer()

                // タイトル
                VStack(spacing: OnlyLonelySpacing.lg) {
                    GlowText(
                        text: "あなたは誰？",
                        size: 36,
                        glowColor: OnlyLonelyColors.playerAPrimary
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)

                    Text("空に名前を刻んでください")
                        .font(OnlyLonelyTypography.body(size: 16))
                        .tracking(3)
                        .foregroundColor(OnlyLonelyColors.textSecondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : -10)
                }

                // 風船アニメーション
                PlayerBalloonView()
                    .frame(width: 120, height: 120)
                    .offset(y: isFloating ? -15 : 15)
                    .animation(
                        OnlyLonelyAnimation.floating(duration: 3),
                        value: isFloating
                    )
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)
                    .padding(.vertical, OnlyLonelySpacing.lg)

                // 名前入力フィールド
                VStack(spacing: OnlyLonelySpacing.sm) {
                    GlassNameTextField(
                        text: $playerName,
                        isTextFieldFocused: $isTextFieldFocused
                    )

                    Text("名前が風船に刻まれます")
                        .font(OnlyLonelyTypography.caption(size: 12))
                        .tracking(2)
                        .foregroundColor(OnlyLonelyColors.textInactive)
                }
                .padding(.horizontal, OnlyLonelySpacing.xl)
                .opacity(showContent ? 1 : 0)

                Spacer()

                // 参加ボタン
                VStack(spacing: OnlyLonelySpacing.md) {
                    PrimaryButton(
                        title: "空へ飛び立つ",
                        gradient: LinearGradient(
                            colors: [
                                OnlyLonelyColors.playerAPrimary,
                                OnlyLonelyColors.playerBPrimary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ) {
                        joinGame()
                    }
                    .opacity(showContent ? 1 : 0)

                    Text(playerName.isEmpty ? "名前が空欄の場合、自動で名前が付きます" : "'\(playerName)' として参加します")
                        .font(OnlyLonelyTypography.caption(size: 12))
                        .tracking(1)
                        .foregroundColor(OnlyLonelyColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, OnlyLonelySpacing.xl)
                        .opacity(showContent ? 0.7 : 0)
                }

                Spacer()
                    .frame(height: OnlyLonelySpacing.xxxl)
            }
        }
        .onAppear {
            startAnimations()
        }
        .navigationBarBackButtonHidden()
    }

    private func startAnimations() {
        isFloating = true

        withAnimation(OnlyLonelyAnimation.slow.delay(0.2)) {
            showContent = true
        }

        // キーボードを自動表示（少し遅延）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isTextFieldFocused = true
        }
    }

    private func joinGame() {
        // 触覚フィードバック
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        let name = playerName.isEmpty ? "旅人 \(Int.random(in: 1...99))" : playerName

        // WebSocket でプレイヤー参加メッセージを送信（後で実装）
        // webSocketService.send(.playerJoin(playerName: name, playerId: UUID().uuidString))

        // キャリブレーション画面をスキップして待機画面へ（MVP）
        withAnimation(OnlyLonelyAnimation.slow) {
            coordinator.navigate(to: .waiting)
        }
    }
}

// MARK: - Player Balloon View

private struct PlayerBalloonView: View {
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // 外側のグロウ
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            OnlyLonelyColors.playerAPrimary.opacity(0.4),
                            OnlyLonelyColors.playerAPrimary.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .blur(radius: 10)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(OnlyLonelyAnimation.pulse(duration: 2), value: isPulsing)

            // 風船本体
            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            OnlyLonelyColors.playerAPrimary,
                            OnlyLonelyColors.playerASecondary,
                            OnlyLonelyColors.playerAPrimary
                        ],
                        center: .center
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: OnlyLonelyColors.playerAPrimary.opacity(0.6), radius: 20)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 5,
                                endRadius: 30
                            )
                        )
                        .frame(width: 80, height: 80)
                )

            // 中央の疑問符
            Text("?")
                .font(.system(size: 48, weight: .ultraLight, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .white.opacity(0.5), radius: 10)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

// MARK: - Glass Name TextField

private struct GlassNameTextField: View {
    @Binding var text: String
    var isTextFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        TextField("", text: $text, prompt: Text("あなたの名前").foregroundColor(.white.opacity(0.4)))
            .font(.system(size: 24, weight: .light, design: .rounded))
            .tracking(2)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, OnlyLonelySpacing.lg)
            .padding(.horizontal, OnlyLonelySpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isTextFieldFocused.wrappedValue ? 0.6 : 0.3),
                                Color.white.opacity(isTextFieldFocused.wrappedValue ? 0.3 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isTextFieldFocused.wrappedValue ? 2 : 1
                    )
            )
            .shadow(
                color: OnlyLonelyColors.playerAPrimary.opacity(isTextFieldFocused.wrappedValue ? 0.4 : 0),
                radius: 20
            )
            .focused(isTextFieldFocused)
            .submitLabel(.done)
            .animation(OnlyLonelyAnimation.fast, value: isTextFieldFocused.wrappedValue)
    }
}

#Preview {
    PlayerNameInputScreen()
        .environmentObject(AppCoordinator())
}
