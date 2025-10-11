//
//  HarajukuCountdownScreen.swift
//  OnlyLonely
//
//  カウントダウン画面 - 原宿系ふわふわバージョン
//

import SwiftUI

struct HarajukuCountdownScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var countdown: Int = 3
    @State private var showStart: Bool = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var rainbowPhase: Double = 0
    @State private var balloonOffsets: [CGFloat] = [0, 0, 0, 0, 0]

    var body: some View {
        ZStack {
            // 超カラフル背景
            RainbowBackground()
                .ignoresSafeArea()
                .hueRotation(.degrees(rainbowPhase))

            // きらきらエフェクト
            ForEach(0..<30, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 20...40)))
                    .foregroundColor(randomPastelColor())
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(Double.random(in: 0.3...0.8))
                    .blur(radius: 2)
                    .scaleEffect(scale * 0.5)
            }

            if showStart {
                // Start! 表示
                VStack(spacing: HarajukuSpacing.xxxl) {
                    // "Start!" 文字
                    VStack(spacing: HarajukuSpacing.lg) {
                        HStack(spacing: 20) {
                            ForEach(["🎉", "✨", "🎊"], id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 48))
                                    .rotationEffect(.degrees(rotation))
                            }
                        }

                        RainbowText(text: "Start!", size: 80)
                            .scaleEffect(scale)
                            .rotationEffect(.degrees(rotation * 0.3))

                        HStack(spacing: 20) {
                            ForEach(["💖", "💙", "💚"], id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 48))
                                    .rotationEffect(.degrees(-rotation))
                            }
                        }
                    }

                    // 風船が飛び立つ
                    HStack(spacing: 20) {
                        ForEach(0..<5, id: \.self) { index in
                            FluffyBalloon(
                                color: pastelColors[index],
                                size: 60,
                                emoji: ["💗", "💙", "💚", "💛", "💜"][index]
                            )
                            .offset(y: balloonOffsets[index])
                        }
                    }
                    .scaleEffect(scale * 0.6)
                }
            } else {
                // カウントダウン数字
                VStack(spacing: HarajukuSpacing.xl) {
                    // きらきらリング
                    ZStack {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            pastelColors[index % pastelColors.count],
                                            pastelColors[(index + 1) % pastelColors.count]
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                                .frame(
                                    width: 300 + CGFloat(index) * 40,
                                    height: 300 + CGFloat(index) * 40
                                )
                                .rotationEffect(.degrees(rotation + Double(index * 60)))
                                .opacity(0.4)
                        }
                    }
                    .scaleEffect(scale * 0.7)
                    .blur(radius: 2)

                    // 数字
                    ZStack {
                        // グロウレイヤー
                        Text("\(countdown)")
                            .font(HarajukuTypography.hugeTitle(size: 160))
                            .foregroundStyle(HarajukuColors.rainbowGradient)
                            .blur(radius: 20)
                            .opacity(0.8)

                        // メイン数字
                        Text("\(countdown)")
                            .font(HarajukuTypography.hugeTitle(size: 160))
                            .foregroundStyle(HarajukuColors.rainbowGradient)
                            .sparkleGlow(color: HarajukuColors.pastelPink)
                    }
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation * 0.5))

                    // メッセージ
                    VStack(spacing: HarajukuSpacing.sm) {
                        HStack(spacing: 8) {
                            Text("💨")
                            Text("いきを じゅんびして")
                                .font(HarajukuTypography.subtitle(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(HarajukuColors.textPrimary)
                            Text("💨")
                        }

                        Text("もうすぐ はじまるよ！")
                            .font(HarajukuTypography.body(size: 16))
                            .foregroundColor(HarajukuColors.textSecondary)
                    }
                    .offset(y: 120)
                    .opacity(scale > 0.9 ? 1 : 0)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
        .navigationBarBackButtonHidden()
    }

    private let pastelColors = [
        HarajukuColors.pastelPink,
        HarajukuColors.pastelBlue,
        HarajukuColors.pastelMint,
        HarajukuColors.pastelYellow,
        HarajukuColors.pastelLavender,
        HarajukuColors.pastelPeach
    ]

    private func randomPastelColor() -> Color {
        pastelColors.randomElement() ?? HarajukuColors.pastelPink
    }

    private func startCountdown() {
        // 虹色アニメーション
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rainbowPhase = 360
        }

        // 回転アニメーション
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // スケールアップ
        withAnimation(HarajukuAnimation.jump) {
            scale = 1.4
        }

        // カウントダウンタイマー
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // 触覚フィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()

            // バウンスアニメーション
            withAnimation(HarajukuAnimation.jump) {
                scale = 0.8
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(HarajukuAnimation.jump) {
                    scale = 1.4
                }
            }

            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                showStartAnimation()
            }
        }
    }

    private func showStartAnimation() {
        // Start! 表示
        withAnimation(HarajukuAnimation.jump) {
            showStart = true
            scale = 0.5
        }

        // 爆発的にスケールアップ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                scale = 1.8
            }

            // 成功フィードバック
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }

        // 風船が飛び立つ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for index in 0..<5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                    withAnimation(.easeOut(duration: 1.5)) {
                        balloonOffsets[index] = -500
                    }
                }
            }
        }

        // ゲームプレイ画面へ遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            coordinator.navigate(to: .iPhoneGameplay)
        }
    }
}

#Preview {
    HarajukuCountdownScreen()
        .environmentObject(AppCoordinator())
}
