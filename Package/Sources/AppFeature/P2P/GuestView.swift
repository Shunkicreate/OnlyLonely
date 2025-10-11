//
//  GuestView.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import SwiftUI
import MultipeerConnectivity

struct GuestView: View {
    @StateObject private var gameState = P2PGameState()
    @StateObject private var viewModel: GuestViewModel

    init() {
        let state = P2PGameState()
        _gameState = StateObject(wrappedValue: state)
        _viewModel = StateObject(wrappedValue: GuestViewModel(gameState: state))
    }

    var body: some View {
        List {
            Section("Advertising") {
                Toggle("Visible to Host", isOn: $viewModel.isAdvertised)
                if let req = viewModel.permissionRequest {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Invitation from: \(req.peerId.displayName)")
                        HStack {
                            Button("Decline") { req.onRequest(false) }
                            Button("Accept") { req.onRequest(true) }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }

            Section("Joined Hosts") {
                if viewModel.joinedPeers.isEmpty {
                    Text("Waiting for invitation...").foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.joinedPeers) { peer in
                        Text(peer.peerId.displayName)
                    }
                }
            }
        }
        .background(
            NavigationLink(destination: GameView(role: .guest).environmentObject(gameState), isActive: Binding(
                get: { gameState.phase == .gaming || gameState.phase == .started },
                set: { _ in }
            )) { EmptyView() }
        )
        .navigationTitle("Guest")
    }
}

#Preview {
    NavigationStack { GuestView() }
}
