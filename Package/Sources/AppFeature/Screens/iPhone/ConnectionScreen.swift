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
    @StateObject private var webSocketService = WebSocketService()

    @State private var ipAddress: String = "192.168.1.100"
    @State private var port: String = "8080"
    @State private var connectionState: ConnectionState = .idle
    @State private var errorMessage: String = ""
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0
    @State private var sparkleRotation: Double = 0

    // バリデーション状態
    @State private var ipAddressError: String? = nil
    @State private var portError: String? = nil

    enum ConnectionState {
        case idle
        case connecting
        case connected
        case failed
    }

    var body: some View {
        ZStack {
            // カラフル虹色背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.4)

            VStack(spacing: HarajukuSpacing.xl) {
                Spacer()

                // タイトルセクション
                VStack(spacing: HarajukuSpacing.md) {
                    // きらきら装飾
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

                    Text("おなじWi-Fiでつながろう！")
                        .font(HarajukuTypography.body(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(HarajukuColors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // 接続状態インジケーター
                ConnectionIndicator(state: connectionState, isPulsing: $isPulsing, rotationAngle: $rotationAngle)
                    .frame(height: 140)
                    .padding(.vertical, HarajukuSpacing.lg)

                // 入力フィールド
                VStack(spacing: HarajukuSpacing.lg) {
                    // IP アドレス入力
                    FluffyTextField(
                        placeholder: "192.168.1.100",
                        text: $ipAddress,
                        emoji: "🌐",
                        gradient: HarajukuColors.skyGradient,
                        borderColor: HarajukuColors.pastelBlue,
                        keyboardType: .decimalPad,
                        isDisabled: connectionState == .connecting
                    )

                    // ポート番号入力
                    FluffyTextField(
                        placeholder: "8080",
                        text: $port,
                        emoji: "🔌",
                        gradient: HarajukuColors.blueMintGradient,
                        borderColor: HarajukuColors.pastelMint,
                        keyboardType: .numberPad,
                        isDisabled: connectionState == .connecting
                    )
                }
                .padding(.horizontal, HarajukuSpacing.xl)

                // QR コードボタン
                FluffyOutlineButton(
                    title: "QRコードでつなぐ",
                    emoji: "📷",
                    color: HarajukuColors.pastelPurple
                ) {
                    // QR コードスキャン機能（後で実装）
                }
                .padding(.top, HarajukuSpacing.sm)

                // バリデーションエラーメッセージ領域（固定高さでレイアウト崩れ防止）
                VStack(spacing: 4) {
                    Text(ipAddressError ?? " ")
                        .font(HarajukuTypography.caption(size: 12))
                        .foregroundColor(Color(hex: "#FF6B9D"))
                        .multilineTextAlignment(.center)
                        .opacity(ipAddressError != nil ? 1 : 0)
                        .frame(minHeight: 16)

                    Text(portError ?? " ")
                        .font(HarajukuTypography.caption(size: 12))
                        .foregroundColor(Color(hex: "#FF6B9D"))
                        .multilineTextAlignment(.center)
                        .opacity(portError != nil ? 1 : 0)
                        .frame(minHeight: 16)
                }
                .padding(.horizontal, HarajukuSpacing.xl)

                // 接続ボタン
                FluffyButton(
                    title: connectionState == .connecting ? "つなぎちゅう..." : "せつぞく！",
                    emoji: connectionState == .connecting ? "🔄" : "🎈",
                    gradient: HarajukuColors.candyGradient,
                    shadowColor: HarajukuColors.pastelPink
                ) {
                    connect()
                }
                .disabled(connectionState == .connecting || !isValidInput)
                .opacity((connectionState == .connecting || !isValidInput) ? 0.5 : 1.0)
                .padding(.top, HarajukuSpacing.lg)

                // 状態メッセージ
                VStack(spacing: HarajukuSpacing.sm) {
                    HStack(spacing: 6) {
                        Text(statusEmoji)
                            .font(.system(size: 16))
                        Text(statusMessage)
                            .font(HarajukuTypography.body(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(statusColor)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(HarajukuTypography.caption(size: 12))
                            .foregroundColor(Color(hex: "#FF6B9D").opacity(0.8))
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
            // 初期バリデーション
            ipAddressError = validateIPAddress(ipAddress)
            portError = validatePort(port)
        }
        .onChange(of: ipAddress) { _, newValue in
            ipAddressError = validateIPAddress(newValue)
        }
        .onChange(of: port) { _, newValue in
            portError = validatePort(newValue)
        }
        .navigationBarBackButtonHidden()
    }

    private var statusMessage: String {
        switch connectionState {
        case .idle:
            return "じょうほうをいれてね"
        case .connecting:
            return "iPadをさがしてるよ..."
        case .connected:
            return "つながったよ！"
        case .failed:
            return "つながらなかった..."
        }
    }

    private var statusEmoji: String {
        switch connectionState {
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
        switch connectionState {
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

    // MARK: - バリデーション関数

    private func validateIPAddress(_ ip: String) -> String? {
        // 空欄チェック
        if ip.isEmpty {
            return nil // デフォルト値を使用
        }

        // IPv4形式チェック
        let components = ip.split(separator: ".")
        guard components.count == 4 else {
            return "IPアドレスは xxx.xxx.xxx.xxx の形式で入力してね"
        }

        // 各オクテットのバリデーション
        for component in components {
            guard let value = Int(component), value >= 0 && value <= 255 else {
                return "各数字は 0〜255 の範囲で入力してね"
            }
        }

        return nil // エラーなし
    }

    private func validatePort(_ portString: String) -> String? {
        // 空欄チェック
        if portString.isEmpty {
            return nil // デフォルト値を使用
        }

        // 数値チェック
        guard let portNumber = Int(portString) else {
            return "ポート番号は数字だけ入力してね"
        }

        // 範囲チェック
        guard portNumber >= 1024 && portNumber <= 65535 else {
            return "ポート番号は 1024〜65535 の範囲で入力してね"
        }

        // 桁数チェック
        guard portString.count <= 5 else {
            return "ポート番号は5桁以内で入力してね"
        }

        return nil // エラーなし
    }

    private var isValidInput: Bool {
        ipAddressError == nil && portError == nil && !ipAddress.isEmpty && !port.isEmpty
    }

    // MARK: - 接続処理

    private func connect() {
        // バリデーション実行
        ipAddressError = validateIPAddress(ipAddress)
        portError = validatePort(port)

        if !isValidInput {
            errorMessage = "ただしいばんごうをいれてね"
            withAnimation(HarajukuAnimation.jump) {
                connectionState = .failed
            }
            return
        }

        guard let portNumber = Int(port) else {
            return
        }

        withAnimation(HarajukuAnimation.bounce(duration: 0.5)) {
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
                    withAnimation(HarajukuAnimation.bounce(duration: 0.6)) {
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
                    withAnimation(HarajukuAnimation.wiggle()) {
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
            // ふわふわ外側のリング
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

            // 虹色リング（接続中のみ回転）
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

            // ふわふわ中央アイコン
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
    ConnectionScreen()
        .environmentObject(AppCoordinator())
}
