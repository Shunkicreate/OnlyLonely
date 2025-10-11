//
//  ConnectionWaitingScreen.swift
//  OnlyLonely
//
//  03. 接続待機画面（iPad）
//  iPad のみ
//

import SwiftUI

struct ConnectionWaitingScreen: View {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var connectionModel: ConnectionWaitinScreenModel

    init(sessionManager: P2PSessionManager, coordinator appCoordinator: AppCoordinator) {
        _coordinator = StateObject(wrappedValue: appCoordinator)
        _connectionModel = StateObject(wrappedValue: ConnectionWaitinScreenModel(sessionManager: sessionManager))
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

            VStack(spacing: 30) {
                Text("プレイヤーを待っています...")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // 接続情報
                VStack(spacing: 8) {
                    Text("ホスト端末: \(connectionModel.hostDisplayName)")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))

                    if connectionModel.isBrowsing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("近くのプレイヤーを探索中")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    } else {
                        Text("探索を停止中")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    if !connectionModel.connectedPeerNames.isEmpty {
                        Text("接続済み: \(connectionModel.connectedPeerNames.joined(separator: ", "))")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    if let error = connectionModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .padding(.vertical, 20)

                WaitingGuestList(
                    guests: connectionModel.discoveredGuests,
                    inviteAction: { guest in
                        connectionModel.invitePeer(guest)
                    }
                )
                .padding(.horizontal, 40)

                // プレイヤー状態表示
                VStack(spacing: 16) {
                    PlayerStatusCard(
                        playerName: "Player A",
                        state: connectionModel.playerState(for: .playerA)
                    )

                    PlayerStatusCard(
                        playerName: "Player B",
                        state: connectionModel.playerState(for: .playerB)
                    )
                }
                .padding(.horizontal, 40)

                Spacer()

                // デバッグ用ボタン
                #if DEBUG
                VStack(spacing: 16) {
                    Text("🐛 デバッグメニュー")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))

                    Button {
                        coordinator.navigate(to: .iPadGameplay)
                    } label: {
                        Text("ゲーム画面へ直接移動")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.7))
                            )
                    }
                }
                .padding(.bottom, 20)
                #endif

                // キャンセルボタン
                Button {
                    connectionModel.stopHosting()
                    coordinator.navigateToRoot()
                } label: {
                    Text("キャンセル")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                        )
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            connectionModel.startHosting()
        }
        .onChange(of: connectionModel.isSessionReady) { ready in
            handleReadinessChange(isReady: ready)
        }
        .navigationBarBackButtonHidden()
    }

    private func handleReadinessChange(isReady: Bool) {
        guard isReady else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            coordinator.navigate(to: .iPadGameplay)
        }
    }
}

struct PlayerStatusCard: View {
    let playerName: String
    let state: PlayerState

    var body: some View {
        HStack(spacing: 16) {
            Text(playerName)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 120, alignment: .leading)

            HStack(spacing: 8) {
                statusIcon
                statusText
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.2))
        )
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch state {
        case .disconnected:
            Image(systemName: "circle")
                .foregroundColor(.gray)
        case .connected:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
        case .ready:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch state {
        case .disconnected:
            Text("未接続")
                .foregroundColor(.gray)
        case .connected:
            Text("接続中...")
                .foregroundColor(.yellow)
        case .ready:
            Text("準備完了")
                .foregroundColor(.green)
        }
    }
}

private struct WaitingGuestList: View {
    let guests: [PeerDevice]
    let inviteAction: (PeerDevice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("近くのプレイヤー")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            if guests.isEmpty {
                HStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("接続待機中の iPhone を探しています")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(guests) { guest in
                        WaitingGuestRow(guest: guest) {
                            inviteAction(guest)
                        }
                    }
                }
            }
        }
    }
}

private struct WaitingGuestRow: View {
    let guest: PeerDevice
    let inviteAction: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(guest.displayName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text(statusLabel)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            statusIndicator
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.18))
        )
    }

    private var statusIndicator: some View {
        switch guest.status {
        case .available:
            return AnyView(
                Button {
                    inviteAction()
                } label: {
                    Text("接続する")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.6))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
            )
        case .invited, .awaitingResponse:
            return AnyView(
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("承認待ち")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            )
        case .connected:
            return AnyView(
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                    Text("接続済み")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            )
        }
    }

    private var statusLabel: String {
        switch guest.status {
        case .available:
            return "タップして接続"
        case .invited:
            return "招待を送信中"
        case .awaitingResponse:
            return "相手の承認待ち"
        case .connected:
            return "接続完了"
        }
    }
}

#Preview {
    let sessionManager = P2PSessionManager()
    let coordinator = AppCoordinator()
    return ConnectionWaitingScreen(sessionManager: sessionManager, coordinator: coordinator)
        .environmentObject(coordinator)
        .environmentObject(sessionManager)
}
