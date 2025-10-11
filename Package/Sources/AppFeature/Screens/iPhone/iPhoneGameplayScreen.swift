//
//  GameplayScreen.swift
//  OnlyLonely
//
//  11. ゲームプレイ画面（iPhone）
//  iPhone のみ
//

import SwiftUI
import AVFoundation
import UIKit
import Combine

struct iPhoneGameplayScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var sessionManager: P2PSessionManager
    @EnvironmentObject private var connectionModel: ConnectionScreenModel
    @EnvironmentObject private var characterManager: CharacterAssignmentManager
    @StateObject private var micLevelManager = MicrophoneLevelManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var screenModel: iPhoneGameplayScreenModel

    @State private var currentAltitude: Double = 0
    @State private var sendWindForceTimer: Timer?
    @State private var gameplayInitialized = false
    @State private var hasHandledGameFinished = false

    init() {
        _screenModel = StateObject(wrappedValue: iPhoneGameplayScreenModel())
    }

    @State private var sparkleRotation: Double = 0
    @State private var cloudOffsets: [CGFloat] = Array(repeating: 0, count: 6)
    @State private var balloonBounce: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundView

                cloudView(geometry: geometry)

                contentView
            }
        }
        .onAppear {
            startDecorationAnimations()
        }
        .onAppear {
            setupGameplayIfNeeded()
        }
        .onDisappear {
            micLevelManager.stopMonitoring()
            motionManager.stopDeviceMotionUpdates()
            stopTimers()
            screenModel.cancelBindings()
            gameplayInitialized = false
        }
        .onReceive(sessionManager.gameEventPublisher) { event in
            guard event.type == .gameFinished else { return }
            handleRemoteGameFinished()
        }
        .onReceive(sessionManager.$localPeerId.compactMap { $0 }.removeDuplicates()) { newId in
            setupGameplayIfNeeded(with: newId)
        }
        .onReceive(sessionManager.characterAssignmentPublisher) { message in
            characterManager.setAssignment(playerId: message.playerId, character: message.character)
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - View Components

    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(hex: "#87CEEB"),   // スカイブルー
                Color(hex: "#B4D4FF"),   // 明るいブルー
                Color(hex: "#E5F3FF"),   // 薄いブルー
                Color(hex: "#FFF9F0")    // クリーム
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private func cloudView(geometry: GeometryProxy) -> some View {
        ForEach(0..<6, id: \.self) { index in
            FloatingCloudPhone(
                index: index,
                screenWidth: geometry.size.width,
                screenHeight: geometry.size.height,
                offset: cloudOffsets[index]
            )
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            // Player名を上部に配置
            playerNameView
                .padding(.top, 60)

            Spacer()

            // 風船とキャラクター（中央）
            balloonView

            Spacer()

            // 風力メーター
            windMeterView

            // 指示テキスト
            instructionView
                .padding(.bottom, 40)
        }
    }

    private var playerNameView: some View {
        ZStack {
            // 4方向黒枠（視認性向上）
            Text(playerDisplayName)
                .nikumaruHeadline(size: 32)
                .foregroundColor(.black)
                .offset(x: -1.5, y: -1.5)
            Text(playerDisplayName)
                .nikumaruHeadline(size: 32)
                .foregroundColor(.black)
                .offset(x: 1.5, y: -1.5)
            Text(playerDisplayName)
                .nikumaruHeadline(size: 32)
                .foregroundColor(.black)
                .offset(x: -1.5, y: 1.5)
            Text(playerDisplayName)
                .nikumaruHeadline(size: 32)
                .foregroundColor(.black)
                .offset(x: 1.5, y: 1.5)

            // メインテキスト
            Text(playerDisplayName)
                .nikumaruHeadline(size: 32)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }

    private var balloonView: some View {
        ZStack {
            // キャラクターが風船を持っているビュー
            VStack(spacing: -8) {
                // 風船本体（上部）
                ZStack {
                    // グロー効果
                    Circle()
                        .fill(Color(hex: balloonColor).opacity(0.5))
                        .frame(width: 100, height: 100)
                        .blur(radius: 18)
                        .scaleEffect(1.0 + CGFloat(micLevelManager.windForce) * 0.4)

                    // 風船（円形グラデーション + Assets画像）
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: balloonColor).opacity(0.9),
                                        Color(hex: balloonColor)
                                    ],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
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
                                    .frame(width: 32, height: 32)
                                    .offset(x: -16, y: -16)
                            )

                        // Assets画像
                        Image(balloonImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                    .scaleEffect(1.0 + CGFloat(micLevelManager.windForce) * 0.3)
                }

                // 紐
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 35))
                }
                .stroke(Color(hex: balloonColor).opacity(0.7), lineWidth: 2.5)
                .frame(width: 25, height: 35)

                // キャラクター（風船を持っている）
                Image(balloonImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .offset(y: -12)
            }

            if micLevelManager.windForce > 0.5 {
                sparkleEffect
                    .offset(y: -55) // キラキラを風船の上に
            }
        }
        .offset(x: balloonHorizontalOffset, y: balloonBounce)
        .animation(.easeInOut(duration: 0.3), value: micLevelManager.windForce)
        .animation(.easeInOut(duration: 0.15), value: motionManager.roll)
    }

    private var balloonImageName: String {
        // CharacterManagerからキャラクターを取得
        let playerId = sessionManager.resolveLocalPeerId() ?? "A"
        return characterManager.character(for: playerId).imageName
    }

    private var balloonColor: String {
        // CharacterManagerからキャラクター色を取得
        let playerId = sessionManager.resolveLocalPeerId() ?? "A"
        return characterManager.character(for: playerId).color
    }

    private var sparkleEffect: some View {
        ForEach(0..<3, id: \.self) { index in
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 8, height: 8)
                .offset(
                    x: CGFloat(index - 1) * 40,
                    y: -50 - CGFloat(index) * 15
                )
                .opacity(Double(micLevelManager.windForce))
        }
    }

    private var windMeterView: some View {
        VStack(spacing: 12) {
            Text("ふうりょく")
                .nikumaruCaption(size: 16)
                .foregroundColor(.white.opacity(0.9))

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    windMeterBackground

                    windMeterFill(width: geo.size.width)
                }
            }
            .frame(height: 40)
            .padding(.horizontal, 32)
        }
        .padding(.top, 20)
    }

    private var windMeterBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FFD700").opacity(0.5),
                                Color(hex: "#FF6B9D").opacity(0.5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
    }

    private func windMeterFill(width: CGFloat) -> some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#FF6B9D"),
                        Color(hex: "#FFD700"),
                        Color(hex: "#6BBFFF"),
                        Color(hex: "#B3FFD9")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width * CGFloat(micLevelManager.windForce))
            .shadow(
                color: Color(hex: "#FF6B9D").opacity(0.6),
                radius: 8,
                x: 0,
                y: 0
            )
            .animation(.easeOut(duration: 0.1), value: micLevelManager.windForce)
    }

    private var instructionView: some View {
        VStack(spacing: 12) {
            instructionText1
            instructionText2
        }
        .padding(.bottom, 60)
    }

    private var instructionText1: some View {
        ZStack {
            // グロー
            Text("いきをふきかけて")
                .nikumaruBody(size: 22)
                .foregroundColor(Color(hex: "#FFD700"))
                .blur(radius: 4)

            // メイン
            Text("いきをふきかけて")
                .nikumaruBody(size: 22)
                .foregroundColor(.white)
        }
    }

    private var instructionText2: some View {
        ZStack {
            // グロー
            Text("ふうせんをとばそう")
                .nikumaruBody(size: 22)
                .foregroundColor(Color(hex: "#FF6B9D"))
                .blur(radius: 4)

            // メイン
            Text("ふうせんをとばそう")
                .nikumaruBody(size: 22)
                .foregroundColor(.white)
        }
    }

    // MARK: - Helper Methods

    private func startGame() {
        hasHandledGameFinished = false
        // マイク監視開始
        micLevelManager.startMonitoring()
        motionManager.startDeviceMotionUpdates()
        stopTimers()

        // 高度更新（30Hz）
        sendWindForceTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            screenModel.sendWindForce()
        }
    }

    /// 傾きに応じて風船の左右位置を調整
    private var balloonHorizontalOffset: CGFloat {
        // 25度の傾きで最大移動（左右）
        let tiltRange: Double = 25
        let normalizedTilt = max(-1, min(1, motionManager.roll / tiltRange))
        let maxOffset: CGFloat = 120
        return CGFloat(normalizedTilt) * maxOffset
    }

    private func stopTimers() {
        sendWindForceTimer?.invalidate()
        sendWindForceTimer = nil
    }

    private var playerDisplayName: String {
        let trimmed = connectionModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? UIDevice.current.name : trimmed
    }

    private func setupGameplayIfNeeded(with candidateId: String? = nil) {
        guard !gameplayInitialized else { return }

        let resolvedId = candidateId ?? sessionManager.resolveLocalPeerId()
        guard let resolvedId else { return }

        screenModel.configure(sessionManager: sessionManager, playerId: resolvedId)
        screenModel.bindInputs(microphone: micLevelManager, motionManager: motionManager)
        startGame()
        gameplayInitialized = true
    }

    private func handleRemoteGameFinished() {
        guard !hasHandledGameFinished else { return }
        hasHandledGameFinished = true
        stopTimers()
        micLevelManager.stopMonitoring()
        motionManager.stopDeviceMotionUpdates()
        screenModel.cancelBindings()
        Task { @MainActor in
            coordinator.navigate(to: .iPhoneResult)
        }
    }

    private func startDecorationAnimations() {
        // 雲のふわふわアニメーション
        for i in 0..<6 {
            let delay = Double(i) * 0.15
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 3.5...5.5))
                        .repeatForever(autoreverses: true)
                ) {
                    cloudOffsets[i] = CGFloat.random(in: -15...15)
                }
            }
        }

        // 風船のふわふわバウンス
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            balloonBounce = -20
        }

        // キラキラ回転
        withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
    }
}

// MARK: - Harajuku Style Components

struct FloatingCloudPhone: View {
    let index: Int
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let offset: CGFloat

    @State private var swayX: CGFloat = 0
    @State private var swayY: CGFloat = 0
    @State private var scale: CGFloat = 1.0

    // 雲の配置データ（6個）
    private let cloudPositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.2, 0.15, 60),    // 左上
        (0.8, 0.2, 70),     // 右上
        (0.15, 0.4, 55),    // 左中央
        (0.75, 0.5, 65),    // 右中央
        (0.25, 0.7, 60),    // 左下
        (0.85, 0.75, 70)    // 右下
    ]

    var body: some View {
        let position = cloudPositions[index]

        Image("kumo")
            .resizable()
            .scaledToFit()
            .frame(width: position.size, height: position.size)
            .opacity(0.5)
            .scaleEffect(scale)
            .position(
                x: screenWidth * position.x + swayX,
                y: screenHeight * position.y + swayY + offset
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 2.5...4.0))
                        .repeatForever(autoreverses: true)
                ) {
                    swayX = CGFloat.random(in: -25...25)
                    swayY = CGFloat.random(in: -15...15)
                    scale = CGFloat.random(in: 0.85...1.15)
                }
            }
    }
}
