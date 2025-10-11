//
//  ConnectionScreen.swift
//  OnlyLonely
//
//  06. 接続画面（iPhone）- 原宿系ふわふわバージョン
//  iPhone のみ
//

import SwiftUI

struct ConnectionScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var connectionModel: ConnectionScreenModel

    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            RainbowBackground()
                .ignoresSafeArea()

            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.4)

            VStack(spacing: HarajukuSpacing.xl) {
                Spacer()

                VStack(spacing: HarajukuSpacing.md) {
                    HStack(spacing: 12) {
                        Text("✨")
                            .font(.system(size: 24))
                            .rotationEffect(.degrees(sparkleRotation))
                        RainbowText(text: "iPadにつなぐよ", size: 32)
                        Text("✨")
                            .font(.system(size: 24))
                            .rotationEffect(.degrees(-sparkleRotation))
                    }
                    .animation(HarajukuAnimation.sparkle(duration: 3), value: sparkleRotation)

                    Text("近くの iPad とふわっとペアリングしよう！")
                        .font(HarajukuTypography.body(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(HarajukuColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                ConnectionIndicator(
                    state: connectionModel.phase,
                    isPulsing: $isPulsing,
                    rotationAngle: $rotationAngle
                )
                .frame(height: 140)
                .padding(.vertical, HarajukuSpacing.lg)

                VStack(spacing: HarajukuSpacing.md) {
                    if connectionModel.phase == .idle {
                        Text("iPadで「接続待機画面」をひらいてから\nせつぞくボタンをおしてね")
                            .font(HarajukuTypography.body(size: 14))
                            .foregroundColor(HarajukuColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    if connectionModel.phase == .connecting {
                        if let host = connectionModel.hostDisplayName {
                            Label("\(host) とペアリング中…", systemImage: "sparkles")
                                .font(HarajukuTypography.body(size: 14))
                                .foregroundColor(HarajukuColors.pastelPurple)
                        } else {
                            Label("iPadがあなたをみつけるのを待ってるよ", systemImage: "antenna.radiowaves.left.and.right")
                                .font(HarajukuTypography.body(size: 14))
                                .foregroundColor(HarajukuColors.pastelBlue)
                        }
                    }

                    if connectionModel.phase == .connected, let host = connectionModel.hostDisplayName {
                        Label("\(host) とつながったよ！", systemImage: "checkmark.circle.fill")
                            .font(HarajukuTypography.body(size: 14))
                            .foregroundColor(HarajukuColors.pastelMint)
                    }

                    if connectionModel.isAdvertising {
                        Text("いま、あなたの iPhone からシグナルをとばしてるよ")
                            .font(HarajukuTypography.caption(size: 12))
                            .foregroundColor(HarajukuColors.textSecondary)
                    }
                }
                .padding(.horizontal, HarajukuSpacing.xl)

                FluffyButton(
                    title: buttonTitle,
                    emoji: buttonEmoji,
                    gradient: HarajukuColors.candyGradient,
                    shadowColor: HarajukuColors.pastelPink
                ) {
                    connect()
                }
                .disabled(connectionModel.phase == .connecting || connectionModel.phase == .connected)
                .padding(.top, HarajukuSpacing.lg)

                VStack(spacing: HarajukuSpacing.sm) {
                    HStack(spacing: 6) {
                        Text(statusEmoji)
                            .font(.system(size: 16))
                        Text(statusMessage)
                            .font(HarajukuTypography.body(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(statusColor)
                    }

                    if let errorMessage = connectionModel.errorMessage {
                        Text(errorMessage)
                            .font(HarajukuTypography.caption(size: 12))
                            .foregroundColor(Color(hex: "#FF6B9D").opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, HarajukuSpacing.xl)

                Spacer()
            }
        }
        .onAppear {
            isPulsing = true
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
        .onChange(of: connectionModel.phase) { phase in
            switch phase {
            case .connecting:
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
            default:
                rotationAngle = 0
            }

            if phase == .failed {
                let feedback = UINotificationFeedbackGenerator()
                feedback.notificationOccurred(.error)
            }
        }
        .onChange(of: connectionModel.isReadyToProceed) { ready in
            guard ready else { return }

            withAnimation(HarajukuAnimation.bounce(duration: 0.6)) {
                rotationAngle = 0
            }

            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                coordinator.navigate(to: .playerNameInput)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var buttonTitle: String {
        switch connectionModel.phase {
        case .idle, .failed:
            return "せつぞく！"
        case .connecting:
            return "つなぎちゅう..."
        case .connected:
            return "つながった！"
        }
    }

    private var buttonEmoji: String {
        switch connectionModel.phase {
        case .idle, .failed:
            return "🎈"
        case .connecting:
            return "🔄"
        case .connected:
            return "✨"
        }
    }

    private var statusMessage: String {
        switch connectionModel.phase {
        case .idle:
            return "iPadで接続待機画面をひらいてね"
        case .connecting:
            return connectionModel.hostDisplayName != nil ? "iPadとつながり中..." : "iPadをよんでいるよ..."
        case .connected:
            return "つながったよ！"
        case .failed:
            return "つながらなかった..."
        }
    }

    private var statusEmoji: String {
        switch connectionModel.phase {
        case .idle:
            return "💭"
        case .connecting:
            return "🔍"
        case .connected:
            return "🎉"
        case .failed:
            return "😢"
        }
    }

    private var statusColor: Color {
        switch connectionModel.phase {
        case .idle:
            return HarajukuColors.textSecondary
        case .connecting:
            return HarajukuColors.pastelBlue
        case .connected:
            return HarajukuColors.pastelMint
        case .failed:
            return Color(hex: "#FF6B9D")
        }
    }

    private func connect() {
        guard connectionModel.phase != .connecting && connectionModel.phase != .connected else {
            return
        }

        withAnimation(HarajukuAnimation.bounce(duration: 0.5)) {
            connectionModel.connect()
        }

        rotationAngle = 0

        let feedback = UIImpactFeedbackGenerator(style: .medium)
        feedback.impactOccurred()
    }
}

// MARK: - Connection Indicator

private struct ConnectionIndicator: View {
    let state: ConnectionScreenModel.ConnectionPhase
    @Binding var isPulsing: Bool
    @Binding var rotationAngle: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            HarajukuColors.pastelPink.opacity(0.4),
                            HarajukuColors.pastelBlue.opacity(0.4),
                            HarajukuColors.pastelPurple.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 110, height: 110)
                .scaleEffect(isPulsing ? 1.3 : 1.0)
                .opacity(isPulsing ? 0.4 : 0.7)
                .animation(HarajukuAnimation.bounce(duration: 1.5), value: isPulsing)

            if state == .connecting {
                Circle()
                    .trim(from: 0, to: 0.6)
                    .stroke(
                        HarajukuColors.rainbowGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(rotationAngle))
                    .harajukuShadow(color: HarajukuColors.pastelPink)
            }

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.6),
                                iconColor.opacity(0.2)
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .harajukuShadow(color: iconColor)

                Text(iconEmoji)
                    .font(.system(size: 36))
                    .scaleEffect(state == .connected ? 1.2 : 1.0)
            }
            .scaleEffect(state == .connected ? 1.1 : 1.0)
            .animation(HarajukuAnimation.bounce(duration: 0.6), value: state)
        }
    }

    private var iconEmoji: String {
        switch state {
        case .idle:
            return "📡"
        case .connecting:
            return "🔄"
        case .connected:
            return "✨"
        case .failed:
            return "💔"
        }
    }

    private var iconColor: Color {
        switch state {
        case .idle:
            return HarajukuColors.pastelBlue
        case .connecting:
            return HarajukuColors.pastelPurple
        case .connected:
            return HarajukuColors.pastelMint
        case .failed:
            return Color(hex: "#FF6B9D")
        }
    }
}

#Preview {
    let sessionManager = P2PSessionManager()
    let model = ConnectionScreenModel(sessionManager: sessionManager)
    return ConnectionScreen()
        .environmentObject(AppCoordinator())
        .environmentObject(sessionManager)
        .environmentObject(model)
}
