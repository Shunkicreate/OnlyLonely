//
//  P2PMessage.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import Foundation
import MultipeerConnectivity

enum PeerConnectionStatus: Equatable {
    case available
    case invited
    case awaitingResponse
    case connected
}

struct PeerDevice: Identifiable, Hashable {
    let peerId: MCPeerID
    var status: PeerConnectionStatus = .available

    var id: String { peerId.displayName }
    var displayName: String { peerId.displayName }

    static func == (lhs: PeerDevice, rhs: PeerDevice) -> Bool {
        lhs.peerId == rhs.peerId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(peerId)
    }
}
