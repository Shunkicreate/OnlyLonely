//
//  HostView.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import SwiftUI
import MultipeerConnectivity

struct HostView: View {
    @StateObject private var gameState = GameState()
    @StateObject private var viewModel: HostViewModel

    init() {
        let state = GameState()
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
                Button("Send Start Message") {
                    viewModel.sendGameStartMessage()
                }
                .disabled(viewModel.joinedPeers.isEmpty)
            }
        }
        .navigationTitle("Host")
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
