//
//  HarajukuComponents.swift
//  OnlyLonely
//
//  原宿系ふわふわコンポーネント
//

import SwiftUI

// MARK: - Harajuku Buttons

/// ふわふわボタン - カラフルでポップ
struct FluffyButton: View {
    let title: String
    let emoji: String
    let gradient: LinearGradient
    let shadowColor: Color
    let action: () -> Void
    @State private var isPressed = false
    @State private var isWiggling = false

    init(
        title: String,
        emoji: String = "🎈",
        gradient: LinearGradient = HarajukuColors.pinkPurpleGradient,
        shadowColor: Color = HarajukuColors.pastelPink,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.emoji = emoji
        self.gradient = gradient
        self.shadowColor = shadowColor
        self.action = action
    }

    var body: some View {
        Button(action: {
            action()
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 24))
                    .rotationEffect(.degrees(isWiggling ? -15 : 15))
                    .animation(HarajukuAnimation.wiggle(), value: isWiggling)

                Text(title)
                    .font(HarajukuTypography.subtitle(size: 20))
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(gradient)
            )
            .harajukuShadow(color: shadowColor)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .rotationEffect(.degrees(isPressed ? -3 : 0))
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(HarajukuAnimation.jump) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(HarajukuAnimation.jump) {
                        isPressed = false
                    }
                }
        )
        .onAppear {
            isWiggling = true
        }
    }
}

/// ふわふわアウトラインボタン
struct FluffyOutlineButton: View {
    let title: String
    let emoji: String
    let color: Color
    let action: () -> Void

    init(
        title: String,
        emoji: String = "✨",
        color: Color = HarajukuColors.pastelPink,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.emoji = emoji
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 20))

                Text(title)
                    .font(HarajukuTypography.body(size: 16))
                    .fontWeight(.semibold)
            }
            .foregroundColor(color)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
            .fluffyBorder(color: color, width: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Harajuku Cards

/// ふわふわカード
struct FluffyCard<Content: View>: View {
    let gradient: LinearGradient
    let borderColor: Color
    let content: Content

    init(
        gradient: LinearGradient = HarajukuColors.candyGradient,
        borderColor: Color = HarajukuColors.pastelPink,
        @ViewBuilder content: () -> Content
    ) {
        self.gradient = gradient
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(gradient.opacity(0.3))
            )
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .fluffyBorder(color: borderColor)
            .harajukuShadow(color: borderColor)
    }
}

// MARK: - Harajuku Text

/// きらきらテキスト
struct SparkleText: View {
    let text: String
    let size: CGFloat
    let color: Color
    @State private var isSparkle = false

    init(text: String, size: CGFloat = 48, color: Color = HarajukuColors.pastelPink) {
        self.text = text
        self.size = size
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(HarajukuTypography.title(size: size))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        color,
                        color.opacity(0.7),
                        color
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .sparkleGlow(color: color)
            .scaleEffect(isSparkle ? 1.05 : 1.0)
            .animation(HarajukuAnimation.sparkle(), value: isSparkle)
            .onAppear {
                isSparkle = true
            }
    }
}

/// 虹色テキスト（3D効果強化版）
struct RainbowText: View {
    let text: String
    let size: CGFloat

    var body: some View {
        ZStack {
            // 影（最下層・濃い影）
            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(.black.opacity(0.5))
                .offset(x: 0, y: 6)
                .blur(radius: 4)

            // グロウ（中間層）
            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(HarajukuColors.pastelPink)
                .offset(x: 0, y: 3)
                .blur(radius: 8)
                .opacity(0.7)

            // 白い縁取り（4方向）
            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(.white)
                .offset(x: -2, y: -2)
                .opacity(0.9)

            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(.white)
                .offset(x: 2, y: -2)
                .opacity(0.9)

            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(.white)
                .offset(x: -2, y: 2)
                .opacity(0.9)

            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(.white)
                .offset(x: 2, y: 2)
                .opacity(0.9)

            // メインテキスト（虹色グラデーション）
            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(HarajukuColors.rainbowGradient)

            // ハイライト（上部）
            Text(text)
                .font(HarajukuTypography.hugeTitle(size: size))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.7),
                            .white.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .offset(x: 0, y: -1)
        }
        .shadow(color: HarajukuColors.pastelPink.opacity(0.6), radius: 15, x: 0, y: 4)
        .shadow(color: HarajukuColors.pastelPurple.opacity(0.6), radius: 20, x: 0, y: 8)
    }
}

// MARK: - Harajuku Balloons

/// ふわふわ風船
struct FluffyBalloon: View {
    let color: Color
    let size: CGFloat
    let emoji: String?
    @State private var isBouncing = false
    @State private var rotation: Double = 0

    init(color: Color, size: CGFloat = 80, emoji: String? = nil) {
        self.color = color
        self.size = size
        self.emoji = emoji
    }

    var body: some View {
        ZStack {
            // 外側のグロウ
            glowLayer

            // 風船本体
            balloonBody

            // 絵文字
            if let emoji = emoji {
                emojiLayer(emoji: emoji)
            }

            // きらきら
            sparklesLayer
        }
        .offset(y: isBouncing ? -10 : 10)
        .animation(HarajukuAnimation.bounce(duration: 2), value: isBouncing)
        .onAppear {
            isBouncing = true
            withAnimation(HarajukuAnimation.spin(duration: 6)) {
                rotation = 360
            }
        }
    }

    private var glowLayer: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.6),
                        color.opacity(0.2),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: size * 0.3,
                    endRadius: size * 0.8
                )
            )
            .frame(width: size * 1.5, height: size * 1.5)
            .blur(radius: 10)
    }

    private var balloonBody: some View {
        Circle()
            .fill(
                AngularGradient(
                    colors: [
                        color,
                        color.opacity(0.8),
                        color.opacity(0.6),
                        color
                    ],
                    center: .center
                )
            )
            .frame(width: size, height: size)
            .overlay(highlightOverlay)
            .harajukuShadow(color: color)
    }

    private var highlightOverlay: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(0.6),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.3, y: 0.3),
                    startRadius: 5,
                    endRadius: size * 0.4
                )
            )
            .frame(width: size, height: size)
    }

    private func emojiLayer(emoji: String) -> some View {
        Text(emoji)
            .font(.system(size: size * 0.5))
            .rotationEffect(.degrees(rotation))
    }

    private var sparklesLayer: some View {
        ForEach(0..<3, id: \.self) { index in
            sparkle(at: index)
        }
    }

    private func sparkle(at index: Int) -> some View {
        let angle = Double(index) * .pi * 2 / 3 + rotation * .pi / 180
        let xOffset = cos(angle) * size * 0.6
        let yOffset = sin(angle) * size * 0.6

        return Image(systemName: "sparkle")
            .font(.system(size: size * 0.15))
            .foregroundColor(.white)
            .offset(x: xOffset, y: yOffset)
            .opacity(0.8)
    }
}

// MARK: - Harajuku Backgrounds

/// カラフル虹色背景
struct RainbowBackground: View {
    @State private var animationPhase: Double = 0

    var body: some View {
        ZStack {
            // ベースグラデーション
            LinearGradient(
                colors: [
                    HarajukuColors.pastelPinkLight,
                    HarajukuColors.pastelPurpleLight,
                    HarajukuColors.pastelBlueLight,
                    HarajukuColors.pastelMintLight
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(animationPhase))
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    animationPhase = 360
                }
            }

            // きらきら
            ForEach(0..<20, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat.random(in: 10...30)))
                    .foregroundColor(.white.opacity(Double.random(in: 0.3...0.8)))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .blur(radius: 2)
            }
        }
    }
}

/// ふわふわ雲背景
struct FluffyCloudBackground: View {
    var body: some View {
        ZStack {
            // 空色背景
            LinearGradient(
                colors: [
                    HarajukuColors.pastelBlueLight,
                    HarajukuColors.pastelPinkLight,
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // 雲
            ForEach(0..<8, id: \.self) { index in
                FluffyCloud(
                    offset: CGFloat(index) * 100,
                    size: CGFloat.random(in: 80...150)
                )
            }
        }
    }
}

private struct FluffyCloud: View {
    let offset: CGFloat
    let size: CGFloat
    @State private var xOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: -size * 0.3) {
            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.6, height: size * 0.6)

            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: size, height: size)

            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: size * 0.8, height: size * 0.8)
        }
        .blur(radius: 3)
        .offset(x: xOffset, y: offset)
        .onAppear {
            withAnimation(
                .linear(duration: Double.random(in: 20...40))
                .repeatForever(autoreverses: false)
            ) {
                xOffset = UIScreen.main.bounds.width + size * 2
            }
        }
    }
}

// MARK: - Harajuku Progress

/// ふわふわプログレスバー
struct FluffyProgressBar: View {
    let progress: Double // 0.0 ~ 1.0
    let gradient: LinearGradient
    let shadowColor: Color

    init(
        progress: Double,
        gradient: LinearGradient = HarajukuColors.rainbowGradient,
        shadowColor: Color = HarajukuColors.pastelPink
    ) {
        self.progress = progress
        self.gradient = gradient
        self.shadowColor = shadowColor
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                Capsule()
                    .fill(Color.white.opacity(0.3))

                // プログレス
                Capsule()
                    .fill(gradient)
                    .frame(width: geometry.size.width * progress)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            .frame(width: geometry.size.width * progress)
                    )
                    .harajukuShadow(color: shadowColor)

                // きらきら
                Image(systemName: "sparkles")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .offset(x: geometry.size.width * progress - 20)
            }
        }
        .frame(height: 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
    }
}

// MARK: - Harajuku TextField

/// ふわふわテキストフィールド
struct FluffyTextField: View {
    let placeholder: String
    @Binding var text: String
    let emoji: String
    let gradient: LinearGradient
    let borderColor: Color
    let keyboardType: UIKeyboardType
    let isDisabled: Bool

    init(
        placeholder: String,
        text: Binding<String>,
        emoji: String = "💭",
        gradient: LinearGradient = HarajukuColors.pinkPurpleGradient,
        borderColor: Color = HarajukuColors.pastelPink,
        keyboardType: UIKeyboardType = .default,
        isDisabled: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.emoji = emoji
        self.gradient = gradient
        self.borderColor = borderColor
        self.keyboardType = keyboardType
        self.isDisabled = isDisabled
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))

            TextField(placeholder, text: $text)
                .font(HarajukuTypography.body(size: 18))
                .foregroundColor(HarajukuColors.textPrimary)
                .keyboardType(keyboardType)
                .disabled(isDisabled)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(gradient.opacity(0.2))
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .opacity(isDisabled ? 0.5 : 1.0)
        .fluffyBorder(color: borderColor)
    }
}
