//
//  TitleScreen.swift
//  OnlyLonely
//
//  01. タイトル画面 - 風船が宇宙へ飛んでいく
//  iPhone と iPad で共通
//

import SwiftUI

struct TitleScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var backgroundPhase: CGFloat = 0
    @State private var balloonOffsets: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var showStars = false
    @State private var twinkleStars: [Bool] = Array(repeating: false, count: 50)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景（原宿カラー→宇宙）
                AnimatedBackground(phase: backgroundPhase)
                    .ignoresSafeArea()

                // 星（宇宙に近づくと表示）
                if showStars {
                    TwinklingStarsView(twinkleStates: $twinkleStars)
                        .ignoresSafeArea()
                        .opacity(Double(backgroundPhase))
                }

                // 飛んでいく風船たち
                ForEach(0..<5, id: \.self) { index in
                    FloatingBalloon(
                        index: index,
                        screenHeight: geometry.size.height,
                        offset: balloonOffsets[index]
                    )
                }

                // UIオーバーレイ
                VStack(spacing: 40) {
                    Spacer()

                    // タイトルセクション
                    VStack(spacing: 24) {
                        // タイトル
                        VStack(spacing: 8) {
                            Text("ふわふわたいむ")
                                .font(.system(size: 58, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF6B9D"),
                                            Color(hex: "#C44569"),
                                            Color(hex: "#A29BFE"),
                                            Color(hex: "#6C5CE7")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(hex: "#FF6B9D").opacity(0.5), radius: 10)
                                .shadow(color: Color(hex: "#A29BFE").opacity(0.5), radius: 20)
                                .overlay(
                                    // 白いアウトライン
                                    Text("ふわふわたいむ")
                                        .font(.system(size: 58, weight: .black, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .offset(x: 0, y: -2)
                                )

                            // アンダーライン装飾
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#FF6B9D"), Color(hex: "#A29BFE")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 8, height: 8)

                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#FF6B9D"), Color(hex: "#A29BFE")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 60, height: 3)
                                    .cornerRadius(1.5)

                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#A29BFE"), Color(hex: "#FF6B9D")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 8, height: 8)
                            }
                        }

                        // サブタイトル
                        Text("息で飛ばす、ふたりの風船")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FFFFFF"),
                                        Color(hex: "#E0E0FF")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(hex: "#A29BFE").opacity(0.4), radius: 8)
                            .shadow(color: .white.opacity(0.3), radius: 4)
                            .overlay(
                                // 白いアウトライン
                                Text("息で飛ばす、ふたりの風船")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.2))
                                    .offset(x: 0, y: -1)
                            )
                            .tracking(2)
                    }

                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()

                    // タップしてはじめる（キラキラ）
                    TapToStartView()
                        .onTapGesture {
                            handleStart()
                        }

                    Spacer()
                        .frame(height: 80)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // 背景が原宿→宇宙に変化（1回だけ）
        withAnimation(Animation.easeInOut(duration: 6.0)) {
            backgroundPhase = 1.0
        }

        // 風船が順番に飛んでいく（1回だけ）
        for i in 0..<5 {
            let delay = Double(i) * 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeOut(duration: 6.0)) {
                    balloonOffsets[i] = -UIScreen.main.bounds.height * 1.8
                }
            }
        }

        // 星を表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeIn(duration: 1.5)) {
                showStars = true
            }
            startTwinkling()
        }

        // 6秒後、風船を下に戻してふわふわさせる
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            resetBalloonsToFloat()
        }
    }

    private func resetBalloonsToFloat() {
        // 風船を元の位置に戻す（アニメーションなし）
        balloonOffsets = [0, 0, 0, 0, 0]
        // 風船は onAppear で自動的にふわふわし続ける
    }

    private func startTwinkling() {
        for i in 0..<50 {
            let delay = Double.random(in: 0...2.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true)
                ) {
                    twinkleStars[i].toggle()
                }
            }
        }
    }


    private func handleStart() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        let deviceType = DeviceType.current

        switch deviceType {
        case .iPad:
            coordinator.navigate(to: .connectionWaiting)
        case .iPhone:
            coordinator.navigate(to: .connection)
        }
    }
}

// MARK: - アニメーション背景

struct AnimatedBackground: View {
    let phase: CGFloat

    var body: some View {
        let skyBlue = Color(hex: "#87CEEB")
        let lightBlue = Color(hex: "#B3D9FF")
        let darkBlue = Color(hex: "#0F0C29")
        let purple = Color(hex: "#302B63")
        let darkPurple = Color(hex: "#24243E")
        let pink = Color(hex: "#FF6B9D")
        let orange = Color(hex: "#FEA47F")
        let brightOrange = Color(hex: "#F97F51")

        let phaseValue = Double(phase)

        return LinearGradient(
            colors: [
                // 上部: スカイブルー → 宇宙の濃紺
                Color(
                    red: skyBlue.components.red * (1 - phaseValue) + darkBlue.components.red * phaseValue,
                    green: skyBlue.components.green * (1 - phaseValue) + darkBlue.components.green * phaseValue,
                    blue: skyBlue.components.blue * (1 - phaseValue) + darkBlue.components.blue * phaseValue
                ),
                Color(
                    red: lightBlue.components.red * (1 - phaseValue * 0.7) + purple.components.red * phaseValue,
                    green: lightBlue.components.green * (1 - phaseValue * 0.7) + purple.components.green * phaseValue,
                    blue: lightBlue.components.blue * (1 - phaseValue * 0.7) + purple.components.blue * phaseValue
                ),
                Color(
                    red: pink.components.red * (1 - phaseValue * 0.5) + darkPurple.components.red * phaseValue * 0.7,
                    green: pink.components.green * (1 - phaseValue * 0.5) + darkPurple.components.green * phaseValue * 0.7,
                    blue: pink.components.blue * (1 - phaseValue * 0.5) + darkPurple.components.blue * phaseValue * 0.7
                ),
                orange,
                Color(
                    red: brightOrange.components.red * (1 - phaseValue * 0.3),
                    green: brightOrange.components.green * (1 - phaseValue * 0.3),
                    blue: brightOrange.components.blue * (1 - phaseValue * 0.3)
                )
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue))
    }
}

// MARK: - ふわふわ動く風船（UI + Assets画像）

struct FloatingBalloon: View {
    let index: Int
    let screenHeight: CGFloat
    let offset: CGFloat

    @State private var swayX: CGFloat = 0
    @State private var swayY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    // 風船データ（画像名、色、サイズ）
    private let balloonData: [(imageName: String, color: String, size: CGFloat, xPosition: CGFloat)] = [
        ("red", "#FF1493", 80, 0.15),
        ("blue", "#1E90FF", 95, 0.35),
        ("yellow", "#FFD700", 110, 0.5),
        ("orange", "#FF6347", 85, 0.65),
        ("green", "#32CD32", 90, 0.85)
    ]

    var body: some View {
        let data = balloonData[index]
        let screenWidth = UIScreen.main.bounds.width

        VStack(spacing: 0) {
            ZStack {
                // グロー効果（より強く）
                Circle()
                    .fill(Color(hex: data.color).opacity(0.5))
                    .frame(width: data.size + 30, height: data.size + 30)
                    .blur(radius: 20)

                // 風船本体（円形グラデーション）
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: data.color).opacity(0.9),
                                Color(hex: data.color)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: data.size
                        )
                    )
                    .frame(width: data.size, height: data.size)
                    .overlay(
                        // ハイライト
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: data.size * 0.4, height: data.size * 0.4)
                            .offset(x: -data.size * 0.2, y: -data.size * 0.2)
                    )

                // Assets画像を上に重ねる（フルサイズ）
                Image(data.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: data.size, height: data.size)
            }

            // 紐（風船の下から画像の上まで）
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: data.size * 0.5),
                    control: CGPoint(x: sin(rotation * .pi / 180) * 12, y: data.size * 0.25)
                )
            }
            .stroke(Color(hex: data.color).opacity(0.7), lineWidth: 3)
            .frame(width: 30, height: data.size * 0.5)

            // Assets画像（風船を持っている）
            Image(data.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: data.size * 1.2, height: data.size * 1.2)
                .offset(y: -10)
        }
        .position(
            x: screenWidth * data.xPosition + swayX,
            y: screenHeight * 0.6 + offset + swayY
        )
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .onAppear {
            // 横揺れ（大きく）
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 2.5...3.5))
                    .repeatForever(autoreverses: true)
            ) {
                swayX = CGFloat.random(in: -40...40)
            }

            // 縦揺れ（追加）
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 2.0...3.0))
                    .repeatForever(autoreverses: true)
            ) {
                swayY = CGFloat.random(in: -20...20)
            }

            // 回転（大きく）
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 3.0...4.0))
                    .repeatForever(autoreverses: true)
            ) {
                rotation = Double.random(in: -25...25)
            }

            // 拡大縮小
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 1.8...2.5))
                    .repeatForever(autoreverses: true)
            ) {
                scale = CGFloat.random(in: 0.9...1.1)
            }
        }
    }
}

// MARK: - タップしてはじめる（キラキラ）

struct TapToStartView: View {
    @State private var opacity: Double = 0.5

    var body: some View {
        HStack(spacing: 8) {
            Text("タップしてはじめる")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .opacity(opacity)
        .onAppear {
            // キラキラ光る
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - キラキラ星

struct TwinklingStarsView: View {
    @Binding var twinkleStates: [Bool]

    let stars = (0..<50).map { _ in
        (
            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            y: CGFloat.random(in: 0...UIScreen.main.bounds.height * 0.6),
            size: CGFloat.random(in: 2...6)
        )
    }

    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .fill(.white)
                    .frame(width: stars[index].size, height: stars[index].size)
                    .position(x: stars[index].x, y: stars[index].y)
                    .opacity(twinkleStates[index] ? 0.3 : 1.0)
                    .shadow(color: .white, radius: twinkleStates[index] ? 0 : 4)
            }
        }
    }
}

#Preview {
    TitleScreen()
        .environmentObject(AppCoordinator())
}
