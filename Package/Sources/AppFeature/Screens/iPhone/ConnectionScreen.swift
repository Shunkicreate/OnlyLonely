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

    enum ConnectionState {
        case idle
        case connecting
        case connected
        case failed
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
                Spacer()

                Text("iPad に接続")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 20) {
                    // IP アドレス入力
                    VStack(alignment: .leading, spacing: 8) {
                        Text("IP アドレス")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        TextField("192.168.1.100", text: $ipAddress)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .disabled(connectionState == .connecting)
                    }

                    // ポート番号入力
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ポート番号")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        TextField("8080", text: $port)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .disabled(connectionState == .connecting)
                    }
                }
                .padding(.horizontal, 40)

                // 接続ボタン
                Button {
                    connect()
                } label: {
                    HStack {
                        if connectionState == .connecting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(connectionState == .connecting ? "接続中..." : "接続する")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(connectionState == .connecting ? Color.gray.opacity(0.6) : Color.blue.opacity(0.6))
                    )
                }
                .disabled(connectionState == .connecting)
                .padding(.top, 20)

                // 状態表示
                Text(statusMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(connectionState == .failed ? .red : .white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.horizontal, 40)
                }

                Spacer()
            }
        }
    }

    private var statusMessage: String {
        switch connectionState {
        case .idle:
            return "待機中"
        case .connecting:
            return "接続中..."
        case .connected:
            return "接続成功!"
        case .failed:
            return "接続失敗"
        }
    }

    private func connect() {
        guard !ipAddress.isEmpty, let portNumber = Int(port) else {
            errorMessage = "正しいIPアドレスとポート番号を入力してください"
            return
        }

        connectionState = .connecting
        errorMessage = ""

        Task {
            do {
                try await webSocketService.connectToServer(host: ipAddress, port: portNumber)
                await MainActor.run {
                    connectionState = .connected
                    // 接続成功後、プレイヤー名入力画面へ遷移
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        coordinator.navigate(to: .playerNameInput)
                    }
                }
            } catch {
                await MainActor.run {
                    connectionState = .failed
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ConnectionScreen()
        .environmentObject(AppCoordinator())
}
