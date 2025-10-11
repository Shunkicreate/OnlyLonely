//
//  iPadResultScreen.swift
//  OnlyLonely
//
//  05. リザルト画面（iPad）
//  iPad のみ - 原宿スタイルデザインシステム準拠
//

import SwiftUI

struct iPadResultScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerAAltitude: Double = 450
    @State private var playerBAltitude: Double = 380
    
    // アニメーション状態
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var balloonOffsets: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var sparkleRotation: Double = 0
    @State private var confettiOpacity: Double = 0
    @State private var showCards = false
    @State private var displayedAltitudeA: Double = 0
    @State private var displayedAltitudeB: Double = 0
    @State private var fireworksOpacity: Double = 0
    
    var winner: PlayerSlot? {
        if playerAAltitude > playerBAltitude {
            return .playerA
        } else if playerBAltitude > playerAAltitude {
            return .playerB
        } else {
            return nil
        }
    }
    
    var isDraw: Bool {
        winner == nil
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景（原宿カラー）
                ResultBackgroundView()
                    .ignoresSafeArea()
                
                // きらきら装飾（背景の一部として最初に配置）
                SparkleDecorationsView(rotation: sparkleRotation)
                    .opacity(0.5)
                
                // 紙吹雪エフェクト
                ConfettiView()
                    .ignoresSafeArea()
                    .opacity(confettiOpacity)
                
                // お祝いの風船（全色）が空に飛んでいく → 戻ってきてふわふわ
                AllColorBalloonsView(
                    screenHeight: geometry.size.height,
                    balloonOffsets: balloonOffsets
                )
                
                // メインコンテンツ
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // タイトルセクション（3D効果）
                    VStack(spacing: 12) {
                        if let winner = winner {
                            // 勝者表示
                            Text(winner == .playerA ? "プレイヤーAのかち！" : "プレイヤーBのかち！")
                                .font(.system(size: 54, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: winner == .playerA ? [
                                            Color(hex: "#FF6B9D"),
                                            Color(hex: "#C44569"),
                                            Color(hex: "#FF8FB3")
                                        ] : [
                                            Color(hex: "#4A90E2"),
                                            Color(hex: "#357ABD"),
                                            Color(hex: "#6BBFFF")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: (winner == .playerA ? Color(hex: "#FF6B9D") : Color(hex: "#4A90E2")).opacity(0.6), radius: 15)
                                .shadow(color: .white.opacity(0.8), radius: 5)
                                .overlay(
                                    Text(winner == .playerA ? "プレイヤーAのかち！" : "プレイヤーBのかち！")
                                        .font(.system(size: 54, weight: .black, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .offset(x: 0, y: -3)
                                )
                                .scaleEffect(titleScale)
                                .opacity(titleOpacity)
                            
                            
                        } else {
                            // 引き分け
                            Text("おなじだね！")
                                .font(.system(size: 54, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF6B9D"),
                                            Color(hex: "#A29BFE"),
                                            Color(hex: "#6BBFFF")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(hex: "#A29BFE").opacity(0.6), radius: 15)
                                .overlay(
                                    Text("おなじだね！")
                                        .font(.system(size: 54, weight: .black, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.3))
                                        .offset(x: 0, y: -3)
                                )
                                .scaleEffect(titleScale)
                                .opacity(titleOpacity)
                        }
                    }
                    
                    // スコアカード
                    VStack(spacing: 20) {
                        FluffyScoreCard(
                            playerSlot: .playerA,
                            altitude: displayedAltitudeA,
                            isWinner: winner == .playerA
                        )
                        
                        FluffyScoreCard(
                            playerSlot: .playerB,
                            altitude: displayedAltitudeB,
                            isWinner: winner == .playerB
                        )
                    }
                    .padding(.horizontal, 80)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 50)
                    
                    Spacer().frame(height: 20)
                    
                    // ボタンエリア
                    HStack(spacing: 40) {
                        // もう一度ボタン
                        FluffyResultButton(
                            title: "もういちど",
                            gradient: LinearGradient(
                                colors: [
                                    Color(hex: "#A29BFE"),
                                    Color(hex: "#6C5CE7")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            shadowColor: Color(hex: "#A29BFE"),
                            icon: "blue"
                        ) {
                            coordinator.replace(with: .connectionWaiting)
                        }
                        
                        // おわるボタン
                        FluffyResultButton(
                            title: "おわる",
                            gradient: LinearGradient(
                                colors: [
                                    Color(hex: "#FDA7DF"),
                                    Color(hex: "#F48FB1")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            shadowColor: Color(hex: "#FDA7DF"),
                            icon: "red"
                        ) {
                            coordinator.navigateToRoot()
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
        .navigationBarBackButtonHidden()
    }
    
    // アニメーション開始
    private func startAnimations() {
        // タイトルの登場アニメーション
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }
        
        // 紙吹雪
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            confettiOpacity = 1.0
        }
        
        // カードの表示
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(1.0)) {
            showCards = true
        }
        
        // 高度のカウントアップ
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            animateAltitudeCounts()
        }
        
        // きらきら装飾の回転
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
        
        // 風船が空に飛んでいく → 戻ってきてふわふわ（勝者・引き分け共通）
        // フェーズ1: 風船が空に飛んでいく
        for i in 0..<5 {
            let delay = Double(i) * 0.3 + 1.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 4.0)) {
                    balloonOffsets[i] = -UIScreen.main.bounds.height * 1.5
                }
            }
        }
        
        // フェーズ2: 6秒後に風船が戻ってきてお祝い
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.6)) {
                // 画面中央付近に戻す（ふわふわする位置）
                for i in 0..<5 {
                    balloonOffsets[i] = 0
                }
            }
        }
    }
    
    // 高度カウントアップアニメーション
    private func animateAltitudeCounts() {
        let duration = 1.5
        let steps = 60
        let interval = duration / Double(steps)
        
        var currentStep = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            currentStep += 1
            let progress = Double(currentStep) / Double(steps)
            
            displayedAltitudeA = playerAAltitude * progress
            displayedAltitudeB = playerBAltitude * progress
            
            if currentStep >= steps {
                timer.invalidate()
                displayedAltitudeA = playerAAltitude
                displayedAltitudeB = playerBAltitude
            }
        }
    }
}

// MARK: - 背景コンポーネント

struct ResultBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#87CEEB"),   // スカイブルー
                Color(hex: "#FFD4E5"),   // パステルピンク
                Color(hex: "#FFE5B3"),   // はちみつイエロー
                Color(hex: "#D4B3FF")    // ゆめみるパープル
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - 紙吹雪エフェクト

struct ConfettiView: View {
    @State private var confettiPositions: [CGPoint] = []
    @State private var confettiRotations: [Double] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<50, id: \.self) { index in
                    ConfettiPiece(
                        color: [
                            Color(hex: "#FF6B9D"),
                            Color(hex: "#A29BFE"),
                            Color(hex: "#6BBFFF"),
                            Color(hex: "#FFD700"),
                            Color(hex: "#FF8FB3")
                        ].randomElement()!,
                        size: CGFloat.random(in: 8...15),
                        position: confettiPositions.indices.contains(index) ? confettiPositions[index] : CGPoint(x: CGFloat.random(in: 0...geometry.size.width), y: -20),
                        rotation: confettiRotations.indices.contains(index) ? confettiRotations[index] : 0
                    )
                }
            }
        }
        .onAppear {
            startConfetti()
        }
    }
    
    private func startConfetti() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        for i in 0..<50 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                    if confettiPositions.count <= i {
                        confettiPositions.append(CGPoint(
                            x: CGFloat.random(in: 0...width),
                            y: height + 50
                        ))
                        confettiRotations.append(Double.random(in: 0...720))
                    }
                }
            }
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let rotation: Double
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .position(position)
            .rotationEffect(.degrees(rotation))
    }
}

// MARK: - お祝いの風船（飛んでいく→戻ってくる→ふわふわ）

struct AllColorBalloonsView: View {
    let screenHeight: CGFloat
    let balloonOffsets: [CGFloat]
    
    // 5色全部の風船を表示
    private let balloonData: [(imageName: String, color: String)] = [
        ("red", "#FF1493"),      // 左端
        ("blue", "#1E90FF"),     // 左
        ("yellow", "#FFD700"),   // 中央（固定）
        ("orange", "#FF6347"),   // 右
        ("green", "#32CD32")     // 右端
    ]
    
    var body: some View {
        ForEach(0..<5, id: \.self) { index in
            CelebrationBalloon(
                index: index,
                imageName: balloonData[index].imageName,
                color: balloonData[index].color,
                screenHeight: screenHeight,
                offset: balloonOffsets[index],
                isCenter: index == 2  // 中央の黄色だけ固定
            )
        }
    }
}

struct CelebrationBalloon: View {
    let index: Int
    let imageName: String
    let color: String
    let screenHeight: CGFloat
    let offset: CGFloat
    let isCenter: Bool  // 中央の黄色かどうか
    
    @State private var swayX: CGFloat = 0
    @State private var swayY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var isFloating = false
    
    private let positions: [CGFloat] = [0.15, 0.35, 0.5, 0.65, 0.85]
    private let sizes: [CGFloat] = [90, 100, 120, 95, 85]  // 中央を大きく
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        
        ZStack {
            // グロー効果
            Circle()
                .fill(Color(hex: color).opacity(0.5))
                .frame(width: sizes[index] + 30, height: sizes[index] + 30)
                .blur(radius: 20)
            
            // 風船画像
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: sizes[index], height: sizes[index])
        }
        .scaleEffect(scale)
        .position(
            x: screenWidth * positions[index] + swayX,
            y: screenHeight * 0.3 + offset + swayY
        )
        .rotationEffect(.degrees(rotation))
        .onAppear {
            startFloatingAnimation()
        }
        .onChange(of: offset) { oldValue, newValue in
            // 風船が戻ってきたら（offset = 0）ふわふわアニメーション開始
            if newValue == 0 && oldValue != 0 {
                startCelebrationAnimation()
            }
        }
    }
    
    // 初期のふわふわアニメーション
    private func startFloatingAnimation() {
        if isCenter {
            // 中央の黄色は上下に大きく動く
            withAnimation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
            ) {
                swayX = 0
                swayY = CGFloat.random(in: -60...60)  // もっと大きく上下に動く！
                rotation = Double.random(in: -10...10)
            }
        } else {
            // 周りの4匹は普通にふわふわ
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 2.5...3.5))
                    .repeatForever(autoreverses: true)
            ) {
                swayX = CGFloat.random(in: -40...40)
                swayY = CGFloat.random(in: -20...20)
                rotation = Double.random(in: -20...20)
            }
        }
    }
    
    // お祝いのアニメーション（戻ってきた後）
    private func startCelebrationAnimation() {
        if isCenter {
            // 中央の黄色は固定位置で上下に大きく動く
            withAnimation(
                Animation.easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
            ) {
                swayX = 0  // X方向は動かない
                swayY = CGFloat.random(in: -60...60)  // もっと大きく上下に動く！
            }
            
            // 小さなパルスエフェクト
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.1
            }
            
            // 小さな回転
            withAnimation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
            ) {
                rotation = Double.random(in: -15...15)
            }
        } else {
            // 周りの4匹は大きく動く！
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 1.8...2.5))
                    .repeatForever(autoreverses: true)
            ) {
                swayX = CGFloat.random(in: -80...80)  // もっと大きく！
                swayY = CGFloat.random(in: -50...50)  // もっと大きく！
            }
            
            // 大きなパルスエフェクト
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 1.2...2.0))
                    .repeatForever(autoreverses: true)
            ) {
                scale = CGFloat.random(in: 1.1...1.4)  // もっと大きく！
            }
            
            // 大きな回転
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 2.0...3.0))
                    .repeatForever(autoreverses: true)
            ) {
                rotation = Double.random(in: -45...45)  // もっと回転！
            }
        }
    }
}

// MARK: - きらきら装飾

struct SparkleDecorationsView: View {
    let rotation: Double
    
    var body: some View {
        ForEach(0..<12, id: \.self) { index in
            SparkleImage(
                index: index,
                rotation: rotation
            )
        }
    }
}

struct SparkleImage: View {
    let index: Int
    let rotation: Double
    
    private let images = ["yellow", "orange", "green", "red", "blue"]
    private let radius: CGFloat = 280
    
    var body: some View {
        let angle = Double(index) * (360.0 / 12.0)
        let x = cos(angle * .pi / 180) * radius
        let y = sin(angle * .pi / 180) * radius
        
        Image(images[index % images.count])
            .resizable()
            .scaledToFit()
            .frame(width: 35, height: 35)
            .opacity(0.6)
            .offset(x: x, y: y)
            .rotationEffect(.degrees(rotation + angle))
    }
}

// MARK: - スコアカード

struct FluffyScoreCard: View {
    let playerSlot: PlayerSlot
    let altitude: Double
    let isWinner: Bool
    
    @State private var pulseScale: CGFloat = 1.0
    
    var playerName: String {
        playerSlot == .playerA ? "プレイヤーA" : "プレイヤーB"
    }
    
    var playerColor: Color {
        playerSlot == .playerA ? Color(hex: "#FF6B9D") : Color(hex: "#4A90E2")
    }
    
    var balloonImage: String {
        playerSlot == .playerA ? "red" : "blue"
    }
    
    var body: some View {
        HStack(spacing: 24) {
            // プレイヤー風船アイコン
            ZStack {
                // グロー効果
                Circle()
                    .fill(playerColor.opacity(0.5))
                    .frame(width: 80, height: 80)
                    .blur(radius: 15)
                
                // 風船画像
                Image(balloonImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            .scaleEffect(isWinner ? pulseScale : 1.0)
            
            // プレイヤー名
            Text(playerName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [playerColor, playerColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Spacer()
            
            // 高度表示
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(altitude))")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [playerColor, playerColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("メートル")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(playerColor.opacity(0.8))
            }
        }
        .padding(24)
        .background(
            ZStack {
                // ベース背景
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                
                // グラデーション背景
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                playerColor.opacity(isWinner ? 0.3 : 0.1),
                                playerColor.opacity(isWinner ? 0.2 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 枠線
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        playerColor.opacity(isWinner ? 0.8 : 0.3),
                        lineWidth: isWinner ? 4 : 2
                    )
            }
        )
        .shadow(color: playerColor.opacity(isWinner ? 0.4 : 0.1), radius: isWinner ? 20 : 10)
        .onAppear {
            if isWinner {
                withAnimation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                ) {
                    pulseScale = 1.1
                }
            }
        }
    }
}

// MARK: - ボタンコンポーネント

struct FluffyResultButton: View {
    let title: String
    let gradient: LinearGradient
    let shadowColor: Color
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: 16) {
                // アイコン画像
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 24)
            .background(
                ZStack {
                    // ベース背景
                    Capsule()
                        .fill(gradient)
                    
                    // 光の反射
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .shadow(color: shadowColor.opacity(0.6), radius: 20, y: 10)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// MARK: - プレビュー

#Preview {
    iPadResultScreen()
        .environmentObject(AppCoordinator())
}
