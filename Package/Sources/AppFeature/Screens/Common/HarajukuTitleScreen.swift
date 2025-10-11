//
//  HarajukuTitleScreen.swift
//  OnlyLonely
//
//  タイトル画面 - 原宿系ふわふわバージョン
//

import SwiftUI

struct HarajukuTitleScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var isBouncing = false
    @State private var showContent = false
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            // カラフル虹色背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.5)

            VStack(spacing: HarajukuSpacing.xxxl) {
                Spacer()

                // タイトルセクション
                VStack(spacing: HarajukuSpacing.lg) {
                    // きらきらデコレーション（上）
                    HStack(spacing: 20) {
                        ForEach(["✨", "🌟", "💫"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 32))
                                .rotationEffect(.degrees(sparkleRotation))
                                .offset(y: isBouncing ? -5 : 5)
                        }
                    }
                    .animation(HarajukuAnimation.bounce(duration: 1.5), value: isBouncing)
                    .opacity(showContent ? 1 : 0)

                    // メインタイトル
                    RainbowText(text: "OnlyLonely", size: 56)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)

                    // サブタイトル
                    HStack(spacing: 8) {
                        Text("🎈")
                            .font(.system(size: 20))
                        Text("息で飛ばす、ふたりの風船")
                            .font(HarajukuTypography.body(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(HarajukuColors.textPrimary)
                        Text("🎈")
                            .font(.system(size: 20))
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                    // きらきらデコレーション（下）
                    HStack(spacing: 20) {
                        ForEach(["💖", "🌈", "☁️"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 28))
                                .rotationEffect(.degrees(-sparkleRotation))
                                .offset(y: isBouncing ? 5 : -5)
                        }
                    }
                    .animation(HarajukuAnimation.bounce(duration: 1.8).delay(0.3), value: isBouncing)
                    .opacity(showContent ? 1 : 0)
                }

                // ふわふわ風船たち
                HStack(spacing: 40) {
                    FluffyBalloon(
                        color: HarajukuColors.playerAPrimary,
                        size: 100,
                        emoji: "💗"
                    )

                    FluffyBalloon(
                        color: HarajukuColors.playerBPrimary,
                        size: 120,
                        emoji: "💙"
                    )

                    FluffyBalloon(
                        color: HarajukuColors.pastelMint,
                        size: 90,
                        emoji: "💚"
                    )
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.3)
                .padding(.vertical, HarajukuSpacing.xl)

                Spacer()

                // ボタンエリア
                VStack(spacing: HarajukuSpacing.lg) {
                    // スタートボタン
                    FluffyButton(
                        title: "はじめる",
                        emoji: "🎈",
                        gradient: HarajukuColors.rainbowGradient
                    ) {
                        handleStart()
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.8)

                    // サブボタン
                    HStack(spacing: HarajukuSpacing.md) {
                        FluffyOutlineButton(
                            title: "あそびかた",
                            emoji: "📖",
                            color: HarajukuColors.pastelPurple
                        ) {
                            // TODO: 遊び方画面へ
                        }

                        FluffyOutlineButton(
                            title: "せってい",
                            emoji: "⚙️",
                            color: HarajukuColors.pastelBlue
                        ) {
                            // TODO: 設定画面へ
                        }
                    }
                    .opacity(showContent ? 1 : 0)

                    // かわいいメッセージ
                    HStack(spacing: 6) {
                        Text("💭")
                        Text("タップして空の旅へ")
                            .font(HarajukuTypography.caption(size: 14))
                            .foregroundColor(HarajukuColors.textSecondary)
                        Text("💭")
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
    }

    private func startAnimations() {
        // バウンスアニメーション開始
        isBouncing = true

        // きらきら回転
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // コンテンツフェードイン
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            showContent = true
        }
    }

    private func handleStart() {
        // 触覚フィードバック
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        // デバイスを自動判定して遷移
        let deviceType = DeviceType.current

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            switch deviceType {
            case .iPad:
                coordinator.navigate(to: .connectionWaiting)
            case .iPhone:
                coordinator.navigate(to: .connection)
            }
        }
    }
}

#Preview {
    HarajukuTitleScreen()
        .environmentObject(AppCoordinator())
}
