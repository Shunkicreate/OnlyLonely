//
//  PermittionRequest.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import MultipeerConnectivity

struct PermissionRequest: Identifiable {
    let id = UUID()
    let peerId: MCPeerID
    let onRequest: (Bool) -> Void
}
