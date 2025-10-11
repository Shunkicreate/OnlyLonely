//
//  GameplayScreen.swift
//  OnlyLonely
//
//  11. ゲームプレイ画面（iPhone）
//  iPhone のみ
//

import Combine
import AVFoundation
import CoreHaptics
import Foundation
import UIKit
import SwiftUI

struct iPhoneGameplayScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var sessionManager: P2PSessionManager
    @EnvironmentObject private var connectionModel: ConnectionScreenModel
    @StateObject private var micLevelManager = MicrophoneLevelManager()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var screenModel: iPhoneGameplayScreenModel

    @State private var currentAltitude: Double = 0
    @State private var sendWindForceTimer: Timer?
    @State private var gameplayInitialized = false
    @State private var hasHandledGameFinished = false
    @State private var localPlayerId: String?
    private let lightningHaptics = LightningHaptics()

    init() {
        _screenModel = StateObject(wrappedValue: iPhoneGameplayScreenModel())
    }

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.8, green: 0.9, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                // プレイヤー情報
                Text(playerDisplayName)
                    .nikumaruHeadline(size: 24)
                    .foregroundColor(.white)

                // 風船
                VStack {
                    Text("🎈")
                        .font(.system(size: 80))
                        .scaleEffect(1.0 + CGFloat(micLevelManager.windForce) * 0.3)
                        .animation(.easeInOut(duration: 0.3), value: micLevelManager.windForce)

                    Text("✨✨")
                        .font(.system(size: 24))
                        .opacity(Double(micLevelManager.windForce))
                }
                .offset(x: balloonHorizontalOffset)
                .animation(.easeInOut(duration: 0.15), value: motionManager.roll)

                // 音圧レベルメーター
                VStack(spacing: 8) {
                    Text("風力レベル")
                        .nikumaruCaption(size: 14)
                        .foregroundColor(.white.opacity(0.8))

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 背景
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))

                            // レベル表示
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .yellow, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(micLevelManager.windForce))
                                .animation(.easeOut(duration: 0.1), value: micLevelManager.windForce)
                        }
                    }
                    .frame(height: 30)
                    .padding(.horizontal, 40)
                }
                .padding(.top, 20)

                Spacer()

                // 指示テキスト
                VStack(spacing: 8) {
                    Text("息を吹きかけて")
                        .nikumaruBody(size: 20)
                        .foregroundColor(.white)

                    Text("風船を飛ばそう!")
                        .nikumaruBody(size: 20)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
            }
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
            switch event.type {
            case .gameFinished:
                handleRemoteGameFinished()
            case .lightningHit:
                handleLightningEvent(event)
            }
        }
        .onReceive(sessionManager.$localPeerId.compactMap { $0 }.removeDuplicates()) { newId in
            setupGameplayIfNeeded(with: newId)
        }
        .navigationBarBackButtonHidden()
    }

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
        localPlayerId = resolvedId
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

    private func handleLightningEvent(_ event: GameEventMessage) {
        guard let targetId = event.playerId else { return }
        let resolvedLocalId = localPlayerId ?? sessionManager.resolveLocalPeerId()
        guard let resolvedLocalId, resolvedLocalId == targetId else { return }
        lightningHaptics.playLightningPattern()
    }
}

private final class LightningHaptics {
    private var engine: CHHapticEngine?
    private var engineIsRunning = false
    private var supportsHaptics: Bool
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)

    init() {
        let capabilities = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = capabilities.supportsHaptics
        notificationGenerator.prepare()
        impactGenerator.prepare()

        guard supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            engine?.isAutoShutdownEnabled = true
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                    self?.engineIsRunning = true
                } catch {
                    self?.supportsHaptics = false
                    self?.engineIsRunning = false
                    print("⚠️ Failed to restart haptics engine: \(error.localizedDescription)")
                }
            }
            engine?.stoppedHandler = { [weak self] _ in
                self?.engineIsRunning = false
            }
            try engine?.start()
            engineIsRunning = true
        } catch {
            supportsHaptics = false
            engineIsRunning = false
            print("⚠️ Failed to start haptics engine: \(error.localizedDescription)")
        }
    }

    func playLightningPattern() {
        guard supportsHaptics else {
            playFallbackPattern()
            return
        }

        do {
            try startEngineIfNeeded()

            let strike = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                ],
                relativeTime: 0
            )

            let rumble = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.65),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
                ],
                relativeTime: 0.02,
                duration: 0.28
            )

            let crackle1 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
                ],
                relativeTime: 0.12
            )

            let crackle2 = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                ],
                relativeTime: 0.22
            )

            let pattern = try CHHapticPattern(
                events: [strike, rumble, crackle1, crackle2],
                parameterCurves: []
            )

            let player = try engine?.makeAdvancedPlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("⚠️ Failed to play lightning haptics: \(error.localizedDescription)")
            engineIsRunning = false
            playFallbackPattern()
        }
    }

    private func startEngineIfNeeded() throws {
        guard let engine else { return }
        if engineIsRunning { return }
        try engine.start()
        engineIsRunning = true
    }

    private func playFallbackPattern() {
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)

        impactGenerator.prepare()
        impactGenerator.impactOccurred(intensity: 1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            self.impactGenerator.prepare()
            self.impactGenerator.impactOccurred(intensity: 0.6)
        }
    }
}
