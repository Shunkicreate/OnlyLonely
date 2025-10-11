//
//  ConnectionScreen.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/16.
//

import Combine
import SwiftUI

struct ConnectionScreen: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var connectionModel: ConnectionScreenModel
    @EnvironmentObject private var sessionManager: P2PSessionManager
    @State private var showInvitationAlert = false

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

            Spacer()
        }
        .padding()
        .navigationTitle("接続")
        .onChange(of: connectionModel.invitationPeerName) { name in
            showInvitationAlert = (name != nil)
        }
        .alert(
            "接続リクエスト",
            isPresented: $showInvitationAlert,
            presenting: connectionModel.invitationPeerName
        ) { _ in
            Button("許可する") {
                connectionModel.approveInvitation()
            }
            Button("拒否する", role: .cancel) {
                connectionModel.declineInvitation()
            }
        } message: { peerName in
            Text("\(peerName) からの接続依頼です。許可しますか？")
        }
        .onReceive(sessionManager.navigationCommandPublisher) { command in
            guard command.action == .showCountdown else { return }
            if coordinator.currentRoute != .countdown {
                coordinator.navigate(to: .countdown)
            }
        }
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
