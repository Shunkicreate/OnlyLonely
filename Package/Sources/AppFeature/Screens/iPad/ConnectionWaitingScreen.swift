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
    @StateObject private var webSocketService = WebSocketService()
    @State private var playerAState: PlayerState = .disconnected
    @State private var playerBState: PlayerState = .disconnected
    @State private var serverIP: String = "192.168.1.100"
    @State private var serverPort: Int = 8080

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
                    Text("接続情報: \(serverIP):\(serverPort)")
                        .font(.system(size: 18, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.vertical, 20)

                // プレイヤー状態表示
                VStack(spacing: 16) {
                    PlayerStatusCard(
                        playerName: "Player A",
                        state: playerAState
                    )

                    PlayerStatusCard(
                        playerName: "Player B",
                        state: playerBState
                    )
                }
                .padding(.horizontal, 40)

                Spacer()

                // キャンセルボタン
                Button {
                    webSocketService.stopServer()
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
            startServer()
        }
        .onChange(of: playerAState) { _, _ in
            checkReadyToStart()
        }
        .onChange(of: playerBState) { _, _ in
            checkReadyToStart()
        }
        .navigationBarBackButtonHidden()
    }

    private func startServer() {
        Task {
            do {
                try await webSocketService.startServer(port: serverPort)
                // Get local IP address
                serverIP = getLocalIPAddress() ?? "192.168.1.100"
            } catch {
                print("Failed to start server: \(error)")
            }
        }
    }

    private func checkReadyToStart() {
        if playerAState == .ready && playerBState == .ready {
            // 両プレイヤー準備完了
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                coordinator.navigate(to: .iPadGameplay)
            }
        }
    }

    private func getLocalIPAddress() -> String? {
        // 実装: ローカルIPアドレスを取得
        // Network.framework を使用して実装
        return "192.168.1.100" // プレースホルダー
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
    ConnectionWaitingScreen()
        .environmentObject(AppCoordinator())
}
