//
//  SkyBlueComponents.swift
//  OnlyLonely
//
//  空と海をイメージした青系パステルコンポーネント
//

import SwiftUI

// MARK: - 背景コンポーネント

/// 空のグラデーション背景
struct SkyBackground: View {
    var body: some View {
        Rectangle()
            .fill(SkyBlueColors.skyGradient)
    }
}

/// 雲の背景
struct CloudBackground: View {
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0

    var body: some View {
        ZStack {
            // 雲レイヤー1
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SkyBlueColors.cloudWhite.opacity(0.4),
                            SkyBlueColors.paleBlue.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: offset1, y: -200)
                .blur(radius: 40)

            // 雲レイヤー2
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SkyBlueColors.cloudWhite.opacity(0.3),
                            SkyBlueColors.powderBlue.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: offset2, y: 200)
                .blur(radius: 50)

            // 雲レイヤー3
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SkyBlueColors.cloudWhite.opacity(0.35),
                            SkyBlueColors.aqua.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 60,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: -offset1 * 0.5, y: 0)
                .blur(radius: 35)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                offset1 = 100
            }
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: true)) {
                offset2 = -80
            }
        }
    }
}

/// 水面のキラキラ背景
struct WaterShimmerBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        LinearGradient(
            colors: [
                SkyBlueColors.aqua.opacity(0.3),
                SkyBlueColors.skyBlue.opacity(0.2),
                SkyBlueColors.turquoise.opacity(0.3),
                SkyBlueColors.mintBlue.opacity(0.2),
                SkyBlueColors.aqua.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .hueRotation(.degrees(phase))
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

// MARK: - ボタンコンポーネント

/// 空のようなボタン
struct SkyButton: View {
    let title: String
    let emoji: String
    let gradient: LinearGradient
    let action: () -> Void

    init(
        title: String,
        emoji: String = "☁️",
        gradient: LinearGradient = SkyBlueColors.freshGradient,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.emoji = emoji
        self.gradient = gradient
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 24))

                Text(title)
                    .font(SkyBlueTypography.body(size: 18))
                    .fontWeight(.semibold)
            }
            .foregroundColor(SkyBlueColors.textPrimary)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(gradient.opacity(0.3))
            )
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            .cloudBorder(color: SkyBlueColors.skyBlue, width: 2)
            .skyShadow(color: SkyBlueColors.skyBlue, radius: 12)
        }
        .buttonStyle(SkyButtonStyle())
    }
}

/// 空ボタンのスタイル
struct SkyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(SkyBlueAnimation.droplet(), value: configuration.isPressed)
    }
}

/// アウトラインボタン（控えめなアクション用）
struct SkyOutlineButton: View {
    let title: String
    let emoji: String
    let color: Color
    let action: () -> Void

    init(
        title: String,
        emoji: String = "☁️",
        color: Color = SkyBlueColors.skyBlue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.emoji = emoji
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 20))

                Text(title)
                    .font(SkyBlueTypography.body(size: 16))
                    .fontWeight(.medium)
            }
            .foregroundColor(color)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.4), lineWidth: 2)
            )
        }
        .buttonStyle(SkyButtonStyle())
    }
}

// MARK: - テキスト入力コンポーネント

/// 空のようなテキストフィールド
struct SkyTextField: View {
    let placeholder: String
    @Binding var text: String
    let emoji: String
    let gradient: LinearGradient
    let keyboardType: UIKeyboardType
    let isDisabled: Bool

    init(
        placeholder: String,
        text: Binding<String>,
        emoji: String = "💭",
        gradient: LinearGradient = SkyBlueColors.freshGradient,
        keyboardType: UIKeyboardType = .default,
        isDisabled: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.emoji = emoji
        self.gradient = gradient
        self.keyboardType = keyboardType
        self.isDisabled = isDisabled
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))

            TextField(placeholder, text: $text)
                .font(SkyBlueTypography.body(size: 18))
                .foregroundColor(SkyBlueColors.textPrimary)
                .keyboardType(keyboardType)
                .disabled(isDisabled)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(gradient.opacity(0.15))
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .opacity(isDisabled ? 0.5 : 1.0)
        .cloudBorder(color: SkyBlueColors.skyBlue, width: 1.5)
    }
}

// MARK: - テキストコンポーネント

/// 空のグラデーションテキスト
struct SkyGradientText: View {
    let text: String
    let size: CGFloat

    var body: some View {
        Text(text)
            .font(SkyBlueTypography.title(size: size))
            .foregroundStyle(SkyBlueColors.waterGradient)
            .skyShadow(color: SkyBlueColors.skyBlue, radius: 10)
    }
}

// MARK: - 風船コンポーネント

/// 空の風船
struct SkyBalloon: View {
    let color: Color
    let size: CGFloat
    let emoji: String?

    init(
        color: Color = SkyBlueColors.skyBlue,
        size: CGFloat = 100,
        emoji: String? = nil
    ) {
        self.color = color
        self.size = size
        self.emoji = emoji
    }

    var body: some View {
        ZStack {
            // 外側のグロウ
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 10)

            // 風船本体
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.9),
                            color,
                            color.opacity(0.8)
                        ],
                        center: .topLeading,
                        startRadius: size * 0.1,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.clear
                                ],
                                center: UnitPoint(x: 0.3, y: 0.3),
                                startRadius: 5,
                                endRadius: size * 0.3
                            )
                        )
                )
                .skyShadow(color: color, radius: 15)

            // 絵文字
            if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: size * 0.4))
            }

            // キラキラ装飾
            ForEach(0..<3, id: \.self) { index in
                sparkle(at: index, size: size)
            }
        }
    }

    private func sparkle(at index: Int, size: CGFloat) -> some View {
        let angle = Double(index) * 120
        let radius = size * 0.6

        return Text("✨")
            .font(.system(size: 12))
            .opacity(0.6)
            .offset(
                x: cos(angle * .pi / 180) * radius,
                y: sin(angle * .pi / 180) * radius
            )
    }
}

// MARK: - カードコンポーネント

/// 空のようなカード
struct SkyCard<Content: View>: View {
    let gradient: LinearGradient
    let content: () -> Content

    init(
        gradient: LinearGradient = SkyBlueColors.freshGradient,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.gradient = gradient
        self.content = content
    }

    var body: some View {
        VStack {
            content()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(gradient.opacity(0.15))
        )
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .cloudBorder(color: SkyBlueColors.skyBlue, width: 1.5)
        .skyShadow(color: SkyBlueColors.skyBlue, radius: 12)
    }
}

// MARK: - プログレスコンポーネント

/// 空のようなプログレスバー
struct SkyProgressBar: View {
    let progress: Double
    let gradient: LinearGradient

    init(
        progress: Double,
        gradient: LinearGradient = SkyBlueColors.waterGradient
    ) {
        self.progress = progress
        self.gradient = gradient
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(SkyBlueColors.paleBlue.opacity(0.3))
                    .frame(height: 24)

                // プログレス
                RoundedRectangle(cornerRadius: 12)
                    .fill(gradient)
                    .frame(width: geometry.size.width * CGFloat(progress), height: 24)
                    .waterShine()
            }
        }
        .frame(height: 24)
        .skyShadow(color: SkyBlueColors.skyBlue, radius: 8)
    }
}

// MARK: - インジケーターコンポーネント

/// 接続状態インジケーター（空テーマ）
struct SkyConnectionIndicator: View {
    let isConnecting: Bool
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // 外側のリング
            Circle()
                .stroke(
                    SkyBlueColors.skyGradient.opacity(0.3),
                    lineWidth: 3
                )
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .animation(SkyBlueAnimation.wave(duration: 2), value: scale)

            // 接続中の回転リング
            if isConnecting {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        SkyBlueColors.waterGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                    .skyShadow(color: SkyBlueColors.aqua, radius: 10)
            }

            // 中央のアイコン
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                SkyBlueColors.aqua.opacity(0.6),
                                SkyBlueColors.skyBlue.opacity(0.3)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)

                Text(isConnecting ? "☁️" : "✨")
                    .font(.system(size: 32))
            }
        }
        .onAppear {
            scale = 1.2
            if isConnecting {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}
