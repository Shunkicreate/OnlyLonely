//
//  P2PMessage.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import Foundation
import MultipeerConnectivity

struct PeerDevice: Identifiable, Hashable {
    let id = UUID()
    let peerId: MCPeerID
}
