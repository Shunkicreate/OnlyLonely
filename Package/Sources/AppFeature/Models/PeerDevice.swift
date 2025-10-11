//
//  PeerDevice.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import MultipeerKit

struct PeerDevice: Identifiable, Hashable {
    let peer: Peer

    var id: String { peer.id }
    var name: String { peer.name }
}
