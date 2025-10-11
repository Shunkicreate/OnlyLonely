//
//  HostView.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import SwiftUI
import MultipeerConnectivity

struct HostView: View {
    @StateObject private var gameState = P2PGameState()
    @StateObject private var viewModel: HostViewModel
    @State private var startGameActive = false

    init() {
        let state = P2PGameState()
        _gameState = StateObject(wrappedValue: state)
        _viewModel = StateObject(wrappedValue: HostViewModel(gameState: state))
    }

    var body: some View {
        List {
            Section("Status") {
                Text("Session: \(sessionText(viewModel.sessionState))")
                if !viewModel.joinedPeers.isEmpty {
                    Text("Joined: \(viewModel.joinedPeers.count) peers")
                }
            }

            Section("Nearby Peers") {
                if viewModel.peers.isEmpty {
                    Text("Searching...").foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.peers) { peer in
                        HStack {
                            Text(peer.peerId.displayName)
                            Spacer()
                            Button("Invite") {
                                viewModel.invite(_selectedPeer: peer)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }

            Section {
                Button("Finish Browsing") { viewModel.finishBrowsing() }
                Button("Join Game") {
                    _ = viewModel.join()
                }
                .disabled(!viewModel.isParticipantsJoined())
                Button("Start Game") {
                    guard viewModel.sessionState == .connected else { return }
                    viewModel.sendGameStartMessage()
                    startGameActive = true
                }
                .disabled(viewModel.sessionState != .connected)
            }
        }
        .navigationTitle("Host")
        .background(
            NavigationLink(
                destination: GameView(role: .host).environmentObject(gameState),
                isActive: $startGameActive
            ) { EmptyView() }
        )
    }

    private func sessionText(_ state: MCSessionState) -> String {
        switch state {
        case .notConnected: return "Not Connected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        @unknown default: return "Unknown"
        }
    }
}
