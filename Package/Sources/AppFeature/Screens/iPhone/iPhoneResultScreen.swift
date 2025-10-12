//
//  ResultScreen.swift
//  OnlyLonely
//
//  12. リザルト画面（iPhone）- 原宿系ふわふわバージョン
//  iPhone のみ
//

import SwiftUI

struct iPhoneResultScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator

    @State private var playerAltitude: Double = 0
    @State private var opponentAltitude: Double = 0
    @State private var showAnimation = false
    @State private var sparkleRotation: Double = 0
    @State private var balloonFloatOffset: CGFloat = 0
    @State private var confettiOffsets: [CGFloat] = Array(repeating: 0, count: 20)
    @State private var petalOffsets: [(x: CGFloat, y: CGFloat, rotation: Double)] = Array(repeating: (0, 0, 0), count: 30)
    @State private var petalOpacities: [Double] = Array(repeating: 1.0, count: 30)

    var isWinner: Bool {
        playerAltitude > opponentAltitude
    }

    var isDraw: Bool {
        playerAltitude == opponentAltitude
    }

    var body: some View {
        ZStack {
            // 背景（原宿カラー）
            resultBackground
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.3)

            // 花びら（全ての結果で表示、勝利時はより多く）
            petalView

            ScrollView {
                VStack(spacing: HarajukuSpacing.md) {
                    Spacer()
                        .frame(height: 20)

                    // 結果タイトルセクション
                    resultTitleSection

                    // きらきら装飾
                    sparkleDecoration

                    // 風船アニメーション
                    balloonAnimation

                    // ボタンエリア
                    buttonsSection
                        .padding(.horizontal, HarajukuSpacing.xl)

                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Background

    private var resultBackground: some View {
        LinearGradient(
            colors: isWinner ? [
                HarajukuColors.pastelPinkLight,
                HarajukuColors.pastelPink,
                HarajukuColors.pastelPurple
            ] : isDraw ? [
                HarajukuColors.pastelBlueLight,
                HarajukuColors.pastelMint,
                HarajukuColors.pastelBlue
            ] : [
                HarajukuColors.pastelPurpleLight,
                HarajukuColors.pastelBlue,
                HarajukuColors.pastelPurple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Result Title Section

    private var resultTitleSection: some View {
        GeometryReader { geometry in
            VStack(spacing: HarajukuSpacing.md) {
                ZStack {
                    // 影（最下層）
                    Text("げーむしゅうりょう！！")
                        .nikumaruTitle(size: titleSize(for: geometry.size.width))
                        .foregroundStyle(.black.opacity(0.6))
                        .offset(x: 0, y: 8)
                        .blur(radius: 4)

                    // グロウ（中間層）
                    Text("げーむしゅうりょう！！")
                        .nikumaruTitle(size: titleSize(for: geometry.size.width))
                        .foregroundStyle(resultTitleGradient)
                        .offset(x: 0, y: 4)
                        .blur(radius: 8)
                        .opacity(0.7)

                    // ストローク（4方向）
                    ForEach([-2, 2], id: \.self) { x in
                        ForEach([-2, 2], id: \.self) { y in
                            Text("げーむしゅうりょう！！")
                                .nikumaruTitle(size: titleSize(for: geometry.size.width))
                                .foregroundStyle(.white)
                                .offset(x: CGFloat(x), y: CGFloat(y))
                                .opacity(0.8)
                        }
                    }

                    // メインテキスト
                    Text("げーむしゅうりょう！！")
                        .nikumaruTitle(size: titleSize(for: geometry.size.width))
                        .foregroundStyle(resultTitleGradient)

                    // ハイライト
                    Text("げーむしゅうりょう！！")
                        .nikumaruTitle(size: titleSize(for: geometry.size.width))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(x: 0, y: -1)
                }
                .scaleEffect(showAnimation ? 1.0 : 0.8)
                .opacity(showAnimation ? 1.0 : 0.0)
                .shadow(color: resultShadowColor.opacity(0.6), radius: 20, x: 0, y: 8)

                // サブタイトル
                Text("またあそんでね！！！")
                    .nikumaruBody(size: subtitleSize(for: geometry.size.width))
                    .foregroundColor(.white)
                    .opacity(0.9)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: geometry.size.width)
            .padding(.horizontal, HarajukuSpacing.md)
        }
        .frame(height: 150)
    }

    private func titleSize(for width: CGFloat) -> CGFloat {
        // iPhoneSE: 320, iPhone12/13mini: 360, iPhone12/13: 390+
        if width < 340 {
            return 48  // SE
        } else if width < 380 {
            return 56  // mini
        } else {
            return 64  // standard
        }
    }

    private func subtitleSize(for width: CGFloat) -> CGFloat {
        if width < 340 {
            return 16  // SE
        } else if width < 380 {
            return 18  // mini
        } else {
            return 20  // standard
        }
    }

    // MARK: - Sparkle Decoration

    private var sparkleDecoration: some View {
        GeometryReader { geometry in
            ZStack {
                // 左の風船（黄色）
                Image("yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: sparkleSize(for: geometry.size.width),
                           height: sparkleSize(for: geometry.size.width))
                    .rotationEffect(.degrees(sparkleRotation))
                    .offset(x: -sparkleOffset(for: geometry.size.width), y: 0)

                // 中央の風船（青）
                Image("blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: sparkleSize(for: geometry.size.width),
                           height: sparkleSize(for: geometry.size.width))
                    .rotationEffect(.degrees(-sparkleRotation))
                    .offset(x: 0, y: 0)

                // 右の風船（赤）
                Image("red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: sparkleSize(for: geometry.size.width),
                           height: sparkleSize(for: geometry.size.width))
                    .rotationEffect(.degrees(sparkleRotation * 0.8))
                    .offset(x: sparkleOffset(for: geometry.size.width), y: 0)
            }
            .frame(width: geometry.size.width, height: sparkleSize(for: geometry.size.width))
        }
        .frame(height: sparkleSize(for: UIScreen.main.bounds.width))
    }

    private func sparkleSize(for width: CGFloat) -> CGFloat {
        width < 340 ? 72 : 96
    }

    private func sparkleOffset(for width: CGFloat) -> CGFloat {
        // 画像が重ならないように、画像サイズの80%でオフセット
        sparkleSize(for: width) * 0.8
    }

    // MARK: - Balloon Animation

    private var balloonAnimation: some View {
        GeometryReader { geometry in
            HStack(spacing: balloonSpacing(for: geometry.size.width)) {
                Image("blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: balloonSize(for: geometry.size.width),
                           height: balloonSize(for: geometry.size.width))
                    .offset(y: balloonFloatOffset)
                    .shadow(color: HarajukuColors.pastelBlue.opacity(0.6), radius: 10)

                Image("yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: balloonSize(for: geometry.size.width) * 1.15,
                           height: balloonSize(for: geometry.size.width) * 1.15)
                    .offset(y: -balloonFloatOffset)
                    .shadow(color: HarajukuColors.pastelYellow.opacity(0.6), radius: 10)

                Image("red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: balloonSize(for: geometry.size.width),
                           height: balloonSize(for: geometry.size.width))
                    .offset(y: balloonFloatOffset * 0.7)
                    .shadow(color: HarajukuColors.pastelPink.opacity(0.6), radius: 10)
            }
            .frame(width: geometry.size.width)
        }
        .frame(height: 140)
        .padding(.vertical, HarajukuSpacing.md)
    }

    private func balloonSize(for width: CGFloat) -> CGFloat {
        width < 340 ? 70 : 90
    }

    private func balloonSpacing(for width: CGFloat) -> CGFloat {
        width < 340 ? 16 : 24
    }

    // MARK: - Buttons Section

    private var buttonsSection: some View {
        VStack(spacing: HarajukuSpacing.lg) {
            // タイトルに戻る
            FluffyOutlineButton(
                title: "たいとるにもどる",
                emoji: "",
                color: .white
            ) {
                coordinator.navigateToRoot()
            }
        }
    }

    // MARK: - Confetti View

    private var confettiView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(confettiColor(index: index))
                        .frame(width: 8, height: 8)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: confettiOffsets[index]
                        )
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Petal View

    private var petalView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<petalCount, id: \.self) { index in
                    PetalShape()
                        .fill(petalColor(index: index))
                        .frame(width: petalSize(index: index),
                               height: petalSize(index: index) * 1.5)
                        .rotationEffect(.degrees(petalOffsets[index].rotation))
                        .position(
                            x: petalOffsets[index].x,
                            y: petalOffsets[index].y
                        )
                        .opacity(petalOpacities[index])
                        .shadow(color: petalColor(index: index).opacity(0.4), radius: 4)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var petalCount: Int {
       return 30
    }

    private func petalSize(index: Int) -> CGFloat {
        let sizes: [CGFloat] = [12, 15, 18, 20]
        return sizes[index % sizes.count]
    }

    private func petalColor(index: Int) -> Color {
        let colors: [Color] = [
            HarajukuColors.pastelPink,
            HarajukuColors.pastelPinkLight,
            Color(hex: "#FFB3D9"),
            Color(hex: "#FFC0E5"),
            HarajukuColors.pastelPurpleLight,
            Color.white.opacity(0.8)
        ]
        return colors[index % colors.count]
    }

    private var resultTitleGradient: LinearGradient {
        return LinearGradient(
            colors: [
                HarajukuColors.pastelBlueLight,
                HarajukuColors.pastelMint
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var resultShadowColor: Color {
        isWinner ? Color(hex: "#FFD700") : isDraw ? HarajukuColors.pastelMint : HarajukuColors.pastelPurple
    }

    private func confettiColor(index: Int) -> Color {
        let colors: [Color] = [
            HarajukuColors.pastelPink,
            HarajukuColors.pastelYellow,
            HarajukuColors.pastelBlue,
            HarajukuColors.pastelMint,
            HarajukuColors.pastelPurple
        ]
        return colors[index % colors.count]
    }

    // MARK: - Animations

    private func startAnimations() {
        // タイトルアニメーション
        withAnimation(HarajukuAnimation.bounce()) {
            showAnimation = true
        }

        // きらきら回転
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // 風船ふわふわ
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            balloonFloatOffset = 15
        }

        // 勝利時の紙吹雪
        if isWinner {
            startConfettiAnimation()
        }

        // 花びらアニメーション
        startPetalAnimation()
    }

    private func startConfettiAnimation() {
        for index in 0..<20 {
            let delay = Double(index) * 0.1
            let duration = Double.random(in: 2.0...4.0)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    confettiOffsets[index] = UIScreen.main.bounds.height + 100
                }
            }
        }
    }

    private func startPetalAnimation() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        for index in 0..<petalCount {
            animatePetal(index: index, screenWidth: screenWidth, screenHeight: screenHeight)
        }
    }

    private func animatePetal(index: Int, screenWidth: CGFloat, screenHeight: CGFloat) {
        // 初期位置（画面上部のランダムな位置）
        let startX = CGFloat.random(in: 0...screenWidth)
        let startY: CGFloat = -100
        let endY = screenHeight + 100
        let endX = startX + CGFloat.random(in: -150...150)

        let delay = Double(index) * 0.15
        let duration = Double.random(in: 5.0...8.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // 初期位置設定
            petalOffsets[index] = (startX, startY, 0)
            petalOpacities[index] = 1.0

            // 落下アニメーション
            withAnimation(.easeInOut(duration: duration)) {
                petalOffsets[index] = (endX, endY, Double.random(in: 360...720))
            }

            // 徐々に透明に
            withAnimation(.easeIn(duration: duration * 0.7).delay(duration * 0.3)) {
                petalOpacities[index] = 0.0
            }

            // アニメーション完了後、再度開始（無限ループ）
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
                animatePetal(index: index, screenWidth: screenWidth, screenHeight: screenHeight)
            }
        }
    }
}

// MARK: - Result Card Component

struct ResultCard: View {
    let label: String
    let altitude: Double
    let isHighlight: Bool
    let color: Color

    @State private var isPulsing = false

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: cardSpacing(for: geometry.size.width)) {
                // ラベル
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .nikumaruCaption(size: captionSize(for: geometry.size.width))
                        .foregroundColor(.white.opacity(0.8))

                    Text("\(Int(altitude))")
                        .nikumaruTitle(size: altitudeSize(for: geometry.size.width))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)

                    Text("メートル")
                        .nikumaruCaption(size: captionSize(for: geometry.size.width))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // ハイライトインジケーター
                if isHighlight {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "#FFD700"),
                                    Color(hex: "#FFA500")
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: circleRadius(for: geometry.size.width)
                            )
                        )
                        .frame(width: circleSize(for: geometry.size.width),
                               height: circleSize(for: geometry.size.width))
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: circleStroke(for: geometry.size.width))
                        )
                        .scaleEffect(isPulsing ? 1.1 : 1.0)
                        .shadow(color: Color(hex: "#FFD700").opacity(0.8), radius: 15)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                isPulsing = true
                            }
                        }
                }
            }
            .padding(cardPadding(for: geometry.size.width))
            .frame(width: geometry.size.width)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .fluffyBorder(
                        color: isHighlight ? Color(hex: "#FFD700") : color,
                        width: isHighlight ? 3 : 2
                    )
            )
            .shadow(
                color: isHighlight ? Color(hex: "#FFD700").opacity(0.4) : color.opacity(0.3),
                radius: isHighlight ? 15 : 10,
                x: 0,
                y: 5
            )
        }
        .frame(height: cardHeight(for: UIScreen.main.bounds.width))
    }

    private func cardSpacing(for width: CGFloat) -> CGFloat {
        width < 340 ? 8 : HarajukuSpacing.md
    }

    private func cardPadding(for width: CGFloat) -> CGFloat {
        width < 340 ? 12 : HarajukuSpacing.lg
    }

    private func captionSize(for width: CGFloat) -> CGFloat {
        width < 340 ? 12 : 14
    }

    private func altitudeSize(for width: CGFloat) -> CGFloat {
        width < 340 ? 28 : 36
    }

    private func circleSize(for width: CGFloat) -> CGFloat {
        width < 340 ? 55 : 70
    }

    private func circleRadius(for width: CGFloat) -> CGFloat {
        width < 340 ? 27 : 35
    }

    private func circleStroke(for width: CGFloat) -> CGFloat {
        width < 340 ? 2 : 3
    }

    private func cardHeight(for width: CGFloat) -> CGFloat {
        width < 340 ? 90 : 110
    }
}

// MARK: - Petal Shape

struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // 花びらの形（涙型）
        path.move(to: CGPoint(x: width / 2, y: 0))

        // 右側のカーブ
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: height),
            control: CGPoint(x: width, y: height * 0.4)
        )

        // 左側のカーブ
        path.addQuadCurve(
            to: CGPoint(x: width / 2, y: 0),
            control: CGPoint(x: 0, y: height * 0.4)
        )

        return path
    }
}

#Preview {
    iPhoneResultScreen()
        .environmentObject(AppCoordinator())
}
