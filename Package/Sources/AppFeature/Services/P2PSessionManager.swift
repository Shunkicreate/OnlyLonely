//
//  P2PSessionManager.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/12.
//

import Foundation
import MultipeerConnectivity

@MainActor
final class P2PSessionManager: ObservableObject {
    enum Role {
        case host
        case guest
    }

    @Published private(set) var session: MCSession?
    @Published private(set) var role: Role?
    @Published private(set) var localPeerID: MCPeerID?
    @Published private(set) var connectedPeers: [MCPeerID] = []

    func configure(role: Role, peerID: MCPeerID, session: MCSession) {
        self.role = role
        self.localPeerID = peerID
        self.session = session
        self.connectedPeers = session.connectedPeers
    }

    func updateConnectedPeers(_ peers: [MCPeerID]) {
        connectedPeers = peers
    }

    func reset() {
        session?.disconnect()
        session = nil
        role = nil
        localPeerID = nil
        connectedPeers = []
    }
}
