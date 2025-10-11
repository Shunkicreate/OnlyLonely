//
//  CountdownScreen.swift
//  OnlyLonely
//
//  10. カウントダウン画面（iPhone）- 原宿系ふわふわバージョン
//  iPhone のみ
//

import SwiftUI

struct CountdownScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var countdown: Int = 3
    @State private var showStart: Bool = false
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var glowIntensity: Double = 0.3
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            // カラフル虹色背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲（動きを強調）
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.6)

            // 外側のきらきらリング
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            HarajukuColors.rainbowGradient,
                            lineWidth: 3
                        )
                        .frame(width: 300 + CGFloat(index) * 50, height: 300 + CGFloat(index) * 50)
                        .scaleEffect(scale * 0.8)
                        .opacity(1.0 - Double(index) * 0.3)
                        .rotationEffect(.degrees(rotation + Double(index * 60)))
                        .harajukuShadow(color: HarajukuColors.pastelPink)
                }
            }
            .blur(radius: 4)
            .opacity(showStart ? 0 : 1)

            if showStart {
                // スタート表示
                VStack(spacing: HarajukuSpacing.xl) {
                    // きらきら装飾
                    HStack(spacing: 20) {
                        ForEach(["✨", "🌟", "💫", "⭐️"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 32))
                                .rotationEffect(.degrees(sparkleRotation))
                        }
                    }

                    // "スタート！" テキスト
                    RainbowText(text: "スタート！", size: 64)
                        .scaleEffect(scale)

                    // 風船が飛び立つ演出
                    HStack(spacing: 40) {
                        BalloonLaunchView(color: HarajukuColors.pastelPink, emoji: "💗", delay: 0)
                        BalloonLaunchView(color: HarajukuColors.pastelBlue, emoji: "💙", delay: 0.2)
                        BalloonLaunchView(color: HarajukuColors.pastelMint, emoji: "💚", delay: 0.1)
                    }
                    .scaleEffect(scale * 0.8)
                }
            } else {
                // カウントダウン数字
                ZStack {
                    // きらきら装飾（周囲に配置）
                    ForEach(0..<8, id: \.self) { index in
                        Text(["✨", "🌟", "💫", "⭐️", "💖", "🎈", "🌈", "☁️"][index])
                            .font(.system(size: 28))
                            .offset(
                                x: cos(Double(index) * .pi / 4) * 150,
                                y: sin(Double(index) * .pi / 4) * 150
                            )
                            .rotationEffect(.degrees(sparkleRotation + Double(index * 45)))
                            .opacity(glowIntensity)
                    }

                    // 数字のグロウ
                    Text("\(countdown)")
                        .font(.system(size: 200, weight: .heavy, design: .rounded))
                        .foregroundStyle(HarajukuColors.rainbowGradient)
                        .blur(radius: 30)
                        .opacity(glowIntensity * 0.8)

                    // メイン数字
                    Text("\(countdown)")
                        .font(.system(size: 200, weight: .heavy, design: .rounded))
                        .foregroundStyle(HarajukuColors.rainbowGradient)
                        .sparkleGlow()
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation * 0.3))

                // サブテキスト
                VStack(spacing: HarajukuSpacing.sm) {
                    Text("いきをすって〜")
                        .nikumaruBody(size: 18)
                        .foregroundColor(HarajukuColors.textPrimary)

                    Text("もうすぐはじまるよ！")
                        .nikumaruCaption(size: 14)
                        .foregroundColor(HarajukuColors.textSecondary)
                }
                .offset(y: 200)
                .opacity(scale > 0.8 ? 1 : 0)
            }
        }
        .onAppear {
            startCountdown()
        }
        .navigationBarBackButtonHidden()
    }

    private func startCountdown() {
        // 初回アニメーション
        withAnimation(HarajukuAnimation.bounce(duration: 0.8)) {
            scale = 1.3
        }

        // グロウアニメーション
        withAnimation(HarajukuAnimation.sparkle(duration: 2).delay(0.2)) {
            glowIntensity = 1.0
        }

        // 回転アニメーション
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // きらきら回転
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // 3, 2, 1 のカウントダウン
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // 触覚フィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()

            // ジャンプダウンアニメーション
            withAnimation(HarajukuAnimation.jump) {
                scale = 0.7
                glowIntensity = 0.4
            }

            // バウンスアップアニメーション
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(HarajukuAnimation.bounce(duration: 0.6)) {
                    scale = 1.4
                    glowIntensity = 1.0
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
        // 回転を止める
        withAnimation(.none) {
            rotation = 0
        }

        // スタート表示
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showStart = true
            scale = 0.5
        }

        // 爆発的なスケールアップ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.4)) {
                scale = 1.6
            }

            // 成功フィードバック
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }

        // フェードアウト
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(HarajukuAnimation.bounce(duration: 0.4)) {
                scale = 2.2
                glowIntensity = 0
            }
        }

        // ゲームプレイ画面へ遷移（デバイスタイプに応じて）
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let deviceType = DeviceType.current
            switch deviceType {
            case .iPad:
                coordinator.navigate(to: .iPadGameplay)
            case .iPhone:
                coordinator.navigate(to: .iPhoneGameplay)
            }
        }
    }
}

// MARK: - Balloon Launch View

private struct BalloonLaunchView: View {
    let color: Color
    let emoji: String
    let delay: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // ふわふわ風船
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.9),
                            color,
                            color.opacity(0.7)
                        ],
                        center: .topLeading,
                        startRadius: 5,
                        endRadius: 35
                    )
                )
                .frame(width: 60, height: 60)
                .harajukuShadow(color: color)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 18, height: 18)
                        .offset(x: -10, y: -10)
                )

            // 絵文字
            Text(emoji)
                .font(.system(size: 24))
        }
        .offset(y: offset)
        .opacity(opacity)
        .scaleEffect(scale)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.6)) {
                    offset = -350
                    opacity = 0
                    scale = 0.6
                    rotation = Double.random(in: -45...45)
                }
            }
        }
    }
}

#Preview {
    CountdownScreen()
        .environmentObject(AppCoordinator())
}
