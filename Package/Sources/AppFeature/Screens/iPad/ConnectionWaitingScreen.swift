//
//  ConnectionWaitingScreen.swift
//  OnlyLonely
//
//  03. 接続待機画面（iPad）
//  iPad のみ
//

import SwiftUI

struct ConnectionWaitingScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var connectionModel: ConnectionWaitinScreenModel

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

#Preview {
    let sessionManager = P2PSessionManager()
    let model = ConnectionWaitinScreenModel(sessionManager: sessionManager)
    return ConnectionWaitingScreen()
        .environmentObject(AppCoordinator())
        .environmentObject(sessionManager)
        .environmentObject(model)
}
