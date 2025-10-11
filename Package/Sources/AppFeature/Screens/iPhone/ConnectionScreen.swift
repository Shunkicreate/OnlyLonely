//
//  ConnectionScreen.swift
//  OnlyLonely
//
//  06. 接続画面（iPhone）- 原宿系ふわふわバージョン
//  iPhone のみ
//

import Combine
import SwiftUI

struct ConnectionScreen: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var connectionModel: ConnectionScreenModel
    @EnvironmentObject private var sessionManager: P2PSessionManager
    @State private var showInvitationAlert = false

    // アニメーション状態
    @State private var isPulsing = false
    @State private var rotationAngle: Double = 0
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            startAnimations()
        }
        .onChange(of: connectionModel.invitationPeerName) { _, newValue in
            showInvitationAlert = (newValue != nil)
        }
        .alert(
            "招待を受信",
            isPresented: $showInvitationAlert,
            presenting: connectionModel.invitationPeerName
        ) { _ in
            Button("受け入れる") {
                connectionModel.approveInvitation()
            }
            Button("拒否する", role: .cancel) {
                connectionModel.declineInvitation()
            }
        } message: { peerName in
            Text("\(peerName) からの招待を受け入れますか？")
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            RainbowBackground()
                .ignoresSafeArea()

            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.4)
        }
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(spacing: HarajukuSpacing.xl) {
                Spacer()
                    .frame(height: 40)

                titleSection
                nameInputSection
                statusIndicatorSection
                hostNameSection
                errorSection
                buttonsSection

                Spacer()
                    .frame(height: 60)
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: HarajukuSpacing.md) {
            HStack(spacing: 12) {
                Image("yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(sparkleRotation))

                RainbowText(text: "iPadにつなぐよ", size: 32)

                Image("yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-sparkleRotation))
            }
            .animation(HarajukuAnimation.sparkle(duration: 3), value: sparkleRotation)

            Text("おなじWi-Fiでつながろう！")
                .nikumaruBody(size: 14)
                .foregroundColor(HarajukuColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Name Input Section

    private var nameInputSection: some View {
        VStack(spacing: HarajukuSpacing.md) {
            Text("あなたのなまえは？")
                .nikumaruCaption(size: 14)
                .foregroundColor(HarajukuColors.textSecondary)

            FluffyTextField(
                placeholder: "なまえをいれてね♪",
                text: Binding(
                    get: { connectionModel.playerName },
                    set: { newValue in
                        // 10文字制限
                        if newValue.count <= 10 {
                            connectionModel.playerName = newValue
                        }
                    }
                ),
                emoji: "✨",
                gradient: HarajukuColors.skyGradient,
                borderColor: HarajukuColors.pastelPink,
                keyboardType: .default,
                isDisabled: connectionModel.phase == .connecting || connectionModel.phase == .connected
            )
            .padding(.horizontal, HarajukuSpacing.xl)

            Text("\(connectionModel.playerName.count)/10")
                .nikumaruCaption(size: 12)
                .foregroundColor(HarajukuColors.textSecondary.opacity(0.6))
        }
    }

    // MARK: - Status Indicator

    private var statusIndicatorSection: some View {
        ConnectionStatusIndicator(
            phase: connectionModel.phase,
            isPulsing: $isPulsing,
            rotationAngle: $rotationAngle
        )
        .frame(height: 140)
        .padding(.vertical, HarajukuSpacing.lg)
    }

    // MARK: - Host Name Section

    @ViewBuilder
    private var hostNameSection: some View {
        if let host = connectionModel.hostName {
            VStack(spacing: 8) {
                Text("せつぞくさき")
                    .nikumaruCaption(size: 12)
                    .foregroundColor(HarajukuColors.textSecondary)

                Text(host)
                    .nikumaruBody(size: 16)
                    .foregroundColor(HarajukuColors.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .fluffyBorder(color: HarajukuColors.pastelBlue, width: 2)
                    )
            }
        }
    }

    // MARK: - Error Section

    @ViewBuilder
    private var errorSection: some View {
        if case .failed(let message) = connectionModel.phase {
            VStack(spacing: 12) {
                Image("red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .shadow(color: Color(hex: "#FF6B9D").opacity(0.6), radius: 15)

                Text("せつぞくできなかったよ...")
                    .nikumaruBody(size: 18)
                    .foregroundColor(Color(hex: "#FF6B9D"))

                Text(message)
                    .nikumaruCaption(size: 14)
                    .foregroundColor(HarajukuColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .fluffyBorder(color: Color(hex: "#FF6B9D"), width: 2)
            )
            .padding(.horizontal, HarajukuSpacing.xl)
        }
    }

    // MARK: - Buttons Section

    private var buttonsSection: some View {
        VStack(spacing: HarajukuSpacing.lg) {
            connectButton
            cancelButton
        }
        .padding(.horizontal, HarajukuSpacing.xl)
    }

    private var connectButton: some View {
        FluffyButtonWithImage(
            title: "せつぞくする",
            imageName: "blue",
            gradient: HarajukuColors.pinkPurpleGradient,
            shadowColor: HarajukuColors.pastelPink
        ) {
            connectionModel.connect()
        }
        .disabled(connectionModel.phase == .connecting || connectionModel.phase == .connected || connectionModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity((connectionModel.phase == .connecting || connectionModel.phase == .connected || connectionModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0)
    }

    private var cancelButton: some View {
        FluffyButtonWithImage(
            title: "キャンセル",
            imageName: "green",
            gradient: HarajukuColors.blueMintGradient,
            shadowColor: HarajukuColors.pastelMint
        ) {
            connectionModel.cancel()
        }
    }

    private func startAnimations() {
        // きらきら装飾の回転
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // 接続状態に応じたアニメーション
        updateAnimations()
    }

    private func updateAnimations() {
        switch connectionModel.phase {
        case .idle:
            isPulsing = false
            rotationAngle = 0
        case .connecting:
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        case .connected:
            isPulsing = false
            rotationAngle = 0
        case .failed:
            isPulsing = false
            rotationAngle = 0
        }
    }
}

// MARK: - 接続状態インジケーター

struct ConnectionStatusIndicator: View {
    let phase: ConnectionScreenModel.Phase
    @Binding var isPulsing: Bool
    @Binding var rotationAngle: Double

    var body: some View {
        ZStack {
            // 背景グロウ
            Circle()
                .fill(statusColor.opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 25)
                .scaleEffect(isPulsing ? 1.2 : 1.0)

            // メインサークル
            Circle()
                .fill(
                    LinearGradient(
                        colors: [statusColor, statusColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 150, height: 150)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.4), lineWidth: 3)
                )
                .shadow(color: statusColor.opacity(0.6), radius: 20)

            // アイコンとテキスト
            VStack(spacing: 12) {
                Image(systemName: statusIcon)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationAngle))
                    .shadow(color: .black.opacity(0.3), radius: 2)

                // 黒縁取り付きテキスト
                ZStack {
                    // 黒い縁取り（4方向）
                    Text(statusText)
                        .nikumaruBody(size: 16)
                        .foregroundColor(.black)
                        .offset(x: -1, y: -1)

                    Text(statusText)
                        .nikumaruBody(size: 16)
                        .foregroundColor(.black)
                        .offset(x: 1, y: -1)

                    Text(statusText)
                        .nikumaruBody(size: 16)
                        .foregroundColor(.black)
                        .offset(x: -1, y: 1)

                    Text(statusText)
                        .nikumaruBody(size: 16)
                        .foregroundColor(.black)
                        .offset(x: 1, y: 1)

                    // メインテキスト（白）
                    Text(statusText)
                        .nikumaruBody(size: 16)
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var statusColor: Color {
        switch phase {
        case .idle:
            return HarajukuColors.pastelBlue
        case .connecting:
            return HarajukuColors.pastelYellow
        case .connected:
            return HarajukuColors.pastelMint
        case .failed:
            return Color(hex: "#FF6B9D")
        }
    }

    private var statusIcon: String {
        switch phase {
        case .idle:
            return "wifi"
        case .connecting:
            return "arrow.triangle.2.circlepath"
        case .connected:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        }
    }

    private var statusText: String {
        switch phase {
        case .idle:
            return "まちじょうたい"
        case .connecting:
            return "せつぞくちゅう"
        case .connected:
            return "せつぞくかんりょう"
        case .failed:
            return "せつぞくしっぱい"
        }
    }
}
