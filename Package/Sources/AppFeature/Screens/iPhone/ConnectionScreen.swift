//
//  ConnectionScreen.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/16.
//

import SwiftUI

struct ConnectionScreen: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var connectionModel: ConnectionScreenModel

    var body: some View {
        VStack(spacing: 24) {
            Text("iPad と接続")
                .font(.title)
                .bold()

            Text(connectionModel.phase.statusText)
                .font(.body)

            if let host = connectionModel.hostName {
                Text("接続先: \(host)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Button("接続を開始") {
                    connectionModel.connect()
                }
                .buttonStyle(.borderedProminent)
                .disabled(connectionModel.phase == .connecting || connectionModel.phase == .connected)

                Button("接続をキャンセル") {
                    connectionModel.cancel()
                }
                .buttonStyle(.bordered)
            }

            if connectionModel.phase == .connected {
                Button("次へ進む") {
                    coordinator.navigate(to: .playerNameInput)
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("接続")
    }
}

#Preview {
    let coordinator = AppCoordinator()
    let sessionManager = P2PSessionManager()
    let model = ConnectionScreenModel(sessionManager: sessionManager)
    return NavigationStack {
        ConnectionScreen()
            .environmentObject(coordinator)
            .environmentObject(sessionManager)
            .environmentObject(model)
    }
}
