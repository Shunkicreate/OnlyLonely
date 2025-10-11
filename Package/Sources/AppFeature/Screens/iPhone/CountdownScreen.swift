//
//  CountdownScreen.swift
//  OnlyLonely
//
//  10. カウントダウン画面（iPhone）
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

    var body: some View {
        ZStack {
            // 背景グラデーション（高揚感を表現）
            AnimatedGradientBackground(colors: [
                OnlyLonelyColors.darkBlue,
                OnlyLonelyColors.skyBlue,
                OnlyLonelyColors.powderBlue
            ])
            .ignoresSafeArea()

            // パーティクル（激しめ）
            ParticleView()
                .ignoresSafeArea()
                .opacity(0.6)

            // 外側のエネルギーリング
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    OnlyLonelyColors.lightningGold.opacity(0.6),
                                    OnlyLonelyColors.playerAPrimary.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 300 + CGFloat(index) * 50, height: 300 + CGFloat(index) * 50)
                        .scaleEffect(scale * 0.8)
                        .opacity(1.0 - Double(index) * 0.3)
                        .rotationEffect(.degrees(rotation + Double(index * 60)))
                }
            }
            .blur(radius: 4)
            .opacity(showStart ? 0 : 1)

            if showStart {
                // Start! 表示
                VStack(spacing: OnlyLonelySpacing.xl) {
                    // "Start!" テキスト
                    Text("Start!")
                        .font(.system(size: 80, weight: .ultraLight, design: .rounded))
                        .tracking(8)
                        .foregroundColor(.white)
                        .shadow(color: OnlyLonelyColors.lightningGold.opacity(0.8), radius: 20)
                        .shadow(color: OnlyLonelyColors.lightningGold.opacity(0.5), radius: 40)
                        .shadow(color: OnlyLonelyColors.lightningGold.opacity(0.3), radius: 60)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation * 0.2))

                    // 風船が飛び立つ演出
                    HStack(spacing: 40) {
                        BalloonLaunchView(color: OnlyLonelyColors.playerAPrimary, delay: 0)
                        BalloonLaunchView(color: OnlyLonelyColors.playerBPrimary, delay: 0.2)
                    }
                    .scaleEffect(scale * 0.8)
                }
            } else {
                // カウントダウン数字
                ZStack {
                    // 数字のグロウ
                    Text("\(countdown)")
                        .font(.system(size: 180, weight: .ultraLight, design: .rounded))
                        .foregroundColor(OnlyLonelyColors.lightningGold)
                        .blur(radius: 30)
                        .opacity(glowIntensity)

                    // メイン数字
                    Text("\(countdown)")
                        .font(.system(size: 180, weight: .ultraLight, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: OnlyLonelyColors.lightningGold.opacity(0.8), radius: 20)
                        .shadow(color: OnlyLonelyColors.lightningGold.opacity(0.5), radius: 40)
                }
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))

                // サブテキスト
                VStack(spacing: OnlyLonelySpacing.sm) {
                    Text("息を準備して")
                        .font(OnlyLonelyTypography.body(size: 18))
                        .tracking(4)
                        .foregroundColor(OnlyLonelyColors.textSecondary)

                    Text("まもなく開始...")
                        .font(OnlyLonelyTypography.caption(size: 14))
                        .tracking(2)
                        .foregroundColor(OnlyLonelyColors.textInactive)
                }
                .offset(y: 180)
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
        withAnimation(OnlyLonelyAnimation.slow) {
            scale = 1.3
        }

        // グロウアニメーション
        withAnimation(OnlyLonelyAnimation.pulse().delay(0.2)) {
            glowIntensity = 1.0
        }

        // 回転アニメーション
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }

        // 3, 2, 1 のカウントダウン
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // 触覚フィードバック
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()

            // スケールダウンアニメーション
            withAnimation(OnlyLonelyAnimation.fast) {
                scale = 0.8
                glowIntensity = 0.3
            }

            // スケールアップアニメーション
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(OnlyLonelyAnimation.medium) {
                    scale = 1.3
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

        // Start! 表示
        withAnimation(OnlyLonelyAnimation.slow) {
            showStart = true
            scale = 0.5
        }

        // 爆発的なスケールアップ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                scale = 1.5
                rotation = 360
            }

            // 成功フィードバック
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }

        // フェードアウト
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(OnlyLonelyAnimation.fast) {
                scale = 2.0
                glowIntensity = 0
            }
        }

        // ゲームプレイ画面へ遷移
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            coordinator.navigate(to: .iPhoneGameplay)
        }
    }
}

// MARK: - Balloon Launch View

private struct BalloonLaunchView: View {
    let color: Color
    let delay: Double
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.9),
                        color
                    ],
                    center: .topLeading,
                    startRadius: 10,
                    endRadius: 30
                )
            )
            .frame(width: 50, height: 50)
            .shadow(color: color.opacity(0.6), radius: 10)
            .shadow(color: color.opacity(0.3), radius: 20)
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 15, height: 15)
                    .offset(x: -8, y: -8)
            )
            .offset(y: offset)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 1.5)) {
                        offset = -300
                        opacity = 0
                        scale = 0.5
                    }
                }
            }
    }
}

#Preview {
    CountdownScreen()
        .environmentObject(AppCoordinator())
}
