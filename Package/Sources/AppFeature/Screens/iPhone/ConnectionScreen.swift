//
//  ConnectionScreen.swift
//  OnlyLonely
//
//  06. 接続画面（iPhone）
//  iPhone のみ
//

import SwiftUI

struct ConnectionScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var webSocketService = WebSocketService()

    @State private var ipAddress: String = "192.168.1.100"
    @State private var port: String = "8080"
    @State private var connectionState: ConnectionState = .idle
    @State private var errorMessage: String = ""
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0

    enum ConnectionState {
        case idle
        case connecting
        case connected
        case failed
    }

    var body: some View {
        ZStack {
            // 背景グラデーション
            AnimatedGradientBackground(colors: [
                OnlyLonelyColors.spaceBlack,
                OnlyLonelyColors.midnightBlue,
                OnlyLonelyColors.darkBlue
            ])
            .ignoresSafeArea()

            // パーティクル
            ParticleView()
                .ignoresSafeArea()
                .opacity(0.4)

            VStack(spacing: OnlyLonelySpacing.xl) {
                Spacer()

                // タイトル
                VStack(spacing: OnlyLonelySpacing.md) {
                    Text("iPad に接続")
                        .font(OnlyLonelyTypography.title(size: 36))
                        .tracking(4)
                        .foregroundColor(.white)
                        .shadow(color: OnlyLonelyColors.softGlow, radius: 10)

                    Text("同じWi-Fiネットワーク内のiPadを探します")
                        .font(OnlyLonelyTypography.caption(size: 14))
                        .tracking(2)
                        .foregroundColor(OnlyLonelyColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // 接続状態インジケーター
                ConnectionIndicator(state: connectionState, isPulsing: $isPulsing, rotationAngle: $rotationAngle)
                    .frame(height: 120)
                    .padding(.vertical, OnlyLonelySpacing.lg)

                // 入力フィールド
                VStack(spacing: OnlyLonelySpacing.lg) {
                    // IP アドレス入力
                    GlassTextField(
                        title: "IP アドレス",
                        placeholder: "192.168.1.100",
                        text: $ipAddress,
                        keyboardType: .decimalPad,
                        isDisabled: connectionState == .connecting
                    )

                    // ポート番号入力
                    GlassTextField(
                        title: "ポート番号",
                        placeholder: "8080",
                        text: $port,
                        keyboardType: .numberPad,
                        isDisabled: connectionState == .connecting
                    )
                }
                .padding(.horizontal, OnlyLonelySpacing.xl)

                // QR コードボタン
                GhostButton(title: "QR コードで接続") {
                    // QR コードスキャン機能（後で実装）
                }
                .padding(.top, OnlyLonelySpacing.sm)

                // 接続ボタン
                PrimaryButton(
                    title: connectionState == .connecting ? "接続中..." : "接続する",
                    gradient: OnlyLonelyColors.playerBButtonGradient
                ) {
                    connect()
                }
                .disabled(connectionState == .connecting)
                .padding(.top, OnlyLonelySpacing.lg)

                // 状態メッセージ
                VStack(spacing: OnlyLonelySpacing.sm) {
                    Text(statusMessage)
                        .font(OnlyLonelyTypography.body(size: 14))
                        .tracking(2)
                        .foregroundColor(
                            connectionState == .failed ?
                            Color(hex: "#FF4444") :
                            OnlyLonelyColors.textSecondary
                        )

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(OnlyLonelyTypography.caption(size: 12))
                            .foregroundColor(Color(hex: "#FF4444").opacity(0.8))
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, OnlyLonelySpacing.xl)

                Spacer()
            }
        }
        .onAppear {
            isPulsing = true
        }
    }

    private var statusMessage: String {
        switch connectionState {
        case .idle:
            return "接続情報を入力してください"
        case .connecting:
            return "iPad を探しています..."
        case .connected:
            return "接続成功！"
        case .failed:
            return "接続に失敗しました"
        }
    }

    private func connect() {
        guard !ipAddress.isEmpty, let portNumber = Int(port) else {
            errorMessage = "正しいIPアドレスとポート番号を入力してください"
            withAnimation(OnlyLonelyAnimation.fast) {
                connectionState = .failed
            }
            return
        }

        withAnimation(OnlyLonelyAnimation.medium) {
            connectionState = .connecting
            errorMessage = ""
        }

        // 回転アニメーション開始
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }

        Task {
            do {
                try await webSocketService.connectToServer(host: ipAddress, port: portNumber)
                await MainActor.run {
                    withAnimation(OnlyLonelyAnimation.medium) {
                        connectionState = .connected
                        rotationAngle = 0
                    }

                    // 触覚フィードバック
                    let successFeedback = UINotificationFeedbackGenerator()
                    successFeedback.notificationOccurred(.success)

                    // 接続成功後、プレイヤー名入力画面へ遷移
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        coordinator.navigate(to: .playerNameInput)
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(OnlyLonelyAnimation.medium) {
                        connectionState = .failed
                        errorMessage = error.localizedDescription
                        rotationAngle = 0
                    }

                    // 触覚フィードバック
                    let errorFeedback = UINotificationFeedbackGenerator()
                    errorFeedback.notificationOccurred(.error)
                }
            }
        }
    }
}

// MARK: - Connection Indicator

private struct ConnectionIndicator: View {
    let state: ConnectionScreen.ConnectionState
    @Binding var isPulsing: Bool
    @Binding var rotationAngle: Double

    var body: some View {
        ZStack {
            // 外側のリング
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            OnlyLonelyColors.playerBPrimary.opacity(0.3),
                            OnlyLonelyColors.neonGlow.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: 100, height: 100)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.3 : 0.6)
                .animation(OnlyLonelyAnimation.pulse(duration: 2), value: isPulsing)

            // 中間のリング（接続中のみ回転）
            if state == .connecting {
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [
                                OnlyLonelyColors.playerBPrimary,
                                OnlyLonelyColors.neonGlow
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotationAngle))
            }

            // 中央のアイコン
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.4),
                                iconColor.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: iconColor.opacity(0.6), radius: 20)

                Image(systemName: iconName)
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.white)
                    .shadow(color: iconColor, radius: 10)
            }
            .scaleEffect(state == .connected ? 1.1 : 1.0)
            .animation(OnlyLonelyAnimation.medium, value: state)
        }
    }

    private var iconName: String {
        switch state {
        case .idle:
            return "antenna.radiowaves.left.and.right"
        case .connecting:
            return "dot.radiowaves.left.and.right"
        case .connected:
            return "checkmark.circle"
        case .failed:
            return "xmark.circle"
        }
    }

    private var iconColor: Color {
        switch state {
        case .idle:
            return OnlyLonelyColors.playerBPrimary
        case .connecting:
            return OnlyLonelyColors.neonGlow
        case .connected:
            return Color(hex: "#00FF88")
        case .failed:
            return Color(hex: "#FF4444")
        }
    }
}

// MARK: - Glass TextField

private struct GlassTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let isDisabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: OnlyLonelySpacing.sm) {
            Text(title)
                .font(OnlyLonelyTypography.caption(size: 12))
                .tracking(2)
                .foregroundColor(OnlyLonelyColors.textSecondary)
                .textCase(.uppercase)

            TextField(placeholder, text: $text)
                .font(OnlyLonelyTypography.body(size: 18))
                .foregroundColor(.white)
                .padding(OnlyLonelySpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .keyboardType(keyboardType)
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
        }
    }
}

#Preview {
    ConnectionScreen()
        .environmentObject(AppCoordinator())
}
