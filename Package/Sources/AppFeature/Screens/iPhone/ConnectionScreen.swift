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
            // カラフル虹色背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.4)

            ScrollView {
                VStack(spacing: HarajukuSpacing.xl) {
                    Spacer()
                        .frame(height: 40)

                    // タイトルセクション
                    VStack(spacing: HarajukuSpacing.md) {
                        // きらきら装飾
                        HStack(spacing: 12) {
                            Image("yellow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(sparkleRotation))

                            RainbowText(text: "iPadにつなぐよ", size: 32)

                            Image("yellow")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(-sparkleRotation))
                        }
                        .animation(HarajukuAnimation.sparkle(duration: 3), value: sparkleRotation)

                        Text("おなじWi-Fiでつながろう！")
                            .nikumaruBody(size: 14)
                            .foregroundColor(HarajukuColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // 接続状態インジケーター
                    ConnectionStatusIndicator(phase: connectionModel.phase, isPulsing: $isPulsing, rotationAngle: $rotationAngle)
                        .frame(height: 140)
                        .padding(.vertical, HarajukuSpacing.lg)

                    // 名前入力フィールド
                    VStack(spacing: 8) {
                        Text("なまえをいれてね")
                            .nikumaruCaption(size: 12)
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

                        Text("10文字まで")
                            .nikumaruCaption(size: 10)
                            .foregroundColor(HarajukuColors.textSecondary.opacity(0.6))
                    }
                    .padding(.vertical, HarajukuSpacing.md)

                    // 接続先表示
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

                    // ボタンエリア
                    VStack(spacing: HarajukuSpacing.lg) {
                        // 接続開始ボタン
                        FluffyButton(
                            title: "せつぞくする",
                            emoji: "🎈",
                            gradient: HarajukuColors.pinkPurpleGradient,
                            shadowColor: HarajukuColors.pastelPink
                        ) {
                            connectionModel.connect()
                        }
                        .disabled(connectionModel.phase == .connecting || connectionModel.phase == .connected || connectionModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity((connectionModel.phase == .connecting || connectionModel.phase == .connected || connectionModel.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0)

                        // キャンセルボタン
                        FluffyOutlineButton(
                            title: "キャンセル",
                            emoji: "✨",
                            color: HarajukuColors.pastelPurple
                        ) {
                            connectionModel.cancel()
                        }
                    }
                    .padding(.horizontal, HarajukuSpacing.xl)

                    Spacer()
                        .frame(height: 60)
                }
            }
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
                .frame(width: 140, height: 140)
                .blur(radius: 20)
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
                .frame(width: 100, height: 100)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: statusColor.opacity(0.6), radius: 15)

            // アイコン
            VStack(spacing: 8) {
                Image(systemName: statusIcon)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationAngle))

                Text(statusText)
                    .nikumaruCaption(size: 12)
                    .foregroundColor(.white)
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
