//
//  CommonComponents.swift
//  OnlyLonely
//
//  共通UIコンポーネント
//

import SwiftUI

// MARK: - Buttons

/// プライマリボタン - グロウ付き
struct PrimaryButton: View {
    let title: String
    let gradient: LinearGradient
    let glowColor: Color
    let action: () -> Void
    @State private var isPressed = false

    init(
        title: String,
        gradient: LinearGradient = OnlyLonelyColors.playerAButtonGradient,
        glowColor: Color = OnlyLonelyColors.playerAPrimary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.gradient = gradient
        self.glowColor = glowColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .tracking(3)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(gradient)
                )
                .shadow(color: glowColor, radius: isPressed ? 10 : 20)
                .shadow(color: glowColor.opacity(0.3), radius: isPressed ? 20 : 40)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(OnlyLonelyAnimation.fast) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(OnlyLonelyAnimation.fast) {
                        isPressed = false
                    }
                }
        )
    }
}

/// ゴーストボタン - 透明感
struct GhostButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .light, design: .rounded))
                .tracking(2)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Cards

/// ガラスカード
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(24)
            .background(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 24)
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
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 30, y: 15)
    }
}

// MARK: - Text Effects

/// グロウテキスト
struct GlowText: View {
    let text: String
    let size: CGFloat
    let glowColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .ultraLight, design: .rounded))
            .tracking(6)
            .foregroundColor(.white)
            .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0, y: 0)
            .shadow(color: glowColor.opacity(0.5), radius: 20, x: 0, y: 0)
            .shadow(color: glowColor.opacity(0.3), radius: 30, x: 0, y: 0)
    }
}

/// タイプライター風テキスト
struct TypewriterText: View {
    let fullText: String
    let speed: Double
    @State private var displayedText = ""

    init(fullText: String, speed: Double = 0.05) {
        self.fullText = fullText
        self.speed = speed
    }

    var body: some View {
        Text(displayedText)
            .font(.system(size: 20, weight: .light, design: .rounded))
            .tracking(2)
            .foregroundColor(.white.opacity(0.9))
            .onAppear {
                animateText()
            }
    }

    private func animateText() {
        for (index, character) in fullText.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * speed) {
                displayedText.append(character)
            }
        }
    }
}

// MARK: - Progress & Meters

/// 息の強さメーター（円形）
struct BreathMeter: View {
    let level: Double // 0.0 ~ 1.0

    var body: some View {
        ZStack {
            // 背景円
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 8)

            // プログレス円
            Circle()
                .trim(from: 0, to: level)
                .stroke(
                    LinearGradient(
                        colors: [
                            OnlyLonelyColors.playerBPrimary,
                            OnlyLonelyColors.neonGlow
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: OnlyLonelyColors.neonGlow, radius: 10)

            // 中央のテキスト
            Text("\(Int(level * 100))%")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 200)
        .animation(OnlyLonelyAnimation.fast, value: level)
    }
}

/// タイムバー（水平）
struct TimeBar: View {
    let timeRemaining: Double // 0.0 ~ 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                Capsule()
                    .fill(Color.white.opacity(0.1))

                // プログレス
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: timeRemaining > 0.3 ? [
                                OnlyLonelyColors.lightningGold,
                                Color(hex: "#FFA500")
                            ] : [
                                Color(hex: "#FF4444"),
                                Color(hex: "#CC0000")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * timeRemaining)
                    .shadow(
                        color: (timeRemaining > 0.3 ? OnlyLonelyColors.lightningGold : Color(hex: "#FF4444")).opacity(0.6),
                        radius: 10
                    )
            }
        }
        .frame(height: 8)
        .animation(.linear(duration: 0.1), value: timeRemaining)
    }
}

// MARK: - Backgrounds

/// アニメーションするグラデーション背景
struct AnimatedGradientBackground: View {
    let colors: [Color]
    @State private var animationOffset: CGFloat = 0

    init(colors: [Color]) {
        self.colors = colors
    }

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
        .hueRotation(.degrees(animationOffset))
        .onAppear {
            withAnimation(OnlyLonelyAnimation.ultraSlow.repeatForever(autoreverses: true)) {
                animationOffset = 10
            }
        }
    }
}

// MARK: - Particle Effects

/// シンプルなパーティクルビュー（星やほこり）
struct ParticleView: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var scale: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
                startAnimating()
            }
        }
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<50).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                opacity: Double.random(in: 0.2...0.8),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
    }

    private func startAnimating() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for index in particles.indices {
                withAnimation(.linear(duration: 0.05)) {
                    particles[index].opacity = Double.random(in: 0.1...0.8)
                }
            }
        }
    }
}

// MARK: - Modifiers

/// グラスモーフィズム
struct GlassMorphism: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
    }
}

extension View {
    func glassMorphism() -> some View {
        modifier(GlassMorphism())
    }
}
