//
//  TitleScreen.swift
//  OnlyLonely
//
//  01. タイトル画面
//  iPad / iPhone 共通
//

import SwiftUI

struct TitleScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var isFloating = false
    @State private var glowIntensity: Double = 0.5
    @State private var showContent = false

    var body: some View {
        ZStack {
            // 動的グラデーション背景
            AnimatedGradientBackground(colors: [
                OnlyLonelyColors.spaceBlack,
                OnlyLonelyColors.midnightBlue,
                OnlyLonelyColors.darkBlue,
                OnlyLonelyColors.skyBlue
            ])
            .ignoresSafeArea()

            // パーティクル（星のような）
            ParticleView()
                .ignoresSafeArea()
                .opacity(0.6)

            VStack(spacing: OnlyLonelySpacing.xxxl) {
                Spacer()

                // タイトルセクション
                VStack(spacing: OnlyLonelySpacing.md) {
                    // メインタイトル
                    GlowText(
                        text: "OnlyLonely",
                        size: 56,
                        glowColor: OnlyLonelyColors.lightPink
                    )
                    .offset(y: isFloating ? -10 : 10)
                    .animation(
                        OnlyLonelyAnimation.floating(duration: 3),
                        value: isFloating
                    )

                    // サブタイトル
                    Text("息で飛ばす、ふたりの風船")
                        .font(OnlyLonelyTypography.body(size: 18))
                        .tracking(4)
                        .foregroundColor(OnlyLonelyColors.textSecondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }

                // 風船アニメーション
                HStack(spacing: 50) {
                    BalloonView(
                        color: OnlyLonelyColors.playerAPrimary,
                        delay: 0
                    )
                    .offset(y: isFloating ? -15 : 15)
                    .animation(
                        OnlyLonelyAnimation.floating(duration: 2.5),
                        value: isFloating
                    )

                    BalloonView(
                        color: OnlyLonelyColors.playerBPrimary,
                        delay: 0.7
                    )
                    .offset(y: isFloating ? 15 : -15)
                    .animation(
                        OnlyLonelyAnimation.floating(duration: 2.5).delay(0.5),
                        value: isFloating
                    )
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)

                Spacer()

                // タップガイド
                VStack(spacing: OnlyLonelySpacing.sm) {
                    Text("タップしてスタート")
                        .font(OnlyLonelyTypography.body(size: 20))
                        .tracking(3)
                        .foregroundColor(.white)
                        .opacity(glowIntensity)
                        .shadow(color: .white.opacity(glowIntensity * 0.5), radius: 10)

                    // インジケーター
                    Image(systemName: "arrow.down")
                        .font(.system(size: 24, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.6))
                        .offset(y: isFloating ? 5 : -5)
                        .animation(
                            OnlyLonelyAnimation.floating(duration: 1.5),
                            value: isFloating
                        )
                }
                .opacity(showContent ? 1 : 0)

                Spacer()
                    .frame(height: OnlyLonelySpacing.xxxl)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // 浮遊アニメーション開始
        isFloating = true

        // コンテンツフェードイン
        withAnimation(OnlyLonelyAnimation.slow.delay(0.3)) {
            showContent = true
        }

        // グロウアニメーション
        withAnimation(OnlyLonelyAnimation.pulse().delay(0.5)) {
            glowIntensity = glowIntensity == 0.5 ? 1.0 : 0.5
        }
    }

    private func handleTap() {
        // タップ時のフィードバック
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // デバイスを自動判定して遷移
        let deviceType = DeviceType.current

        withAnimation(OnlyLonelyAnimation.slow) {
            switch deviceType {
            case .iPad:
                coordinator.navigate(to: .connectionWaiting)
            case .iPhone:
                coordinator.navigate(to: .connection)
            }
        }
    }
}

// MARK: - Balloon View

private struct BalloonView: View {
    let color: Color
    let delay: Double
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            // グロウエフェクト
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 80, height: 80)
                .blur(radius: 20)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(
                    OnlyLonelyAnimation.pulse(duration: 2).delay(delay),
                    value: isPulsing
                )

            // 風船本体
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.9),
                            color
                        ],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 40
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: color.opacity(0.6), radius: 10)
                .shadow(color: color.opacity(0.3), radius: 20)

            // ハイライト
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 20, height: 20)
                .offset(x: -10, y: -10)
        }
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    TitleScreen()
        .environmentObject(AppCoordinator())
}
