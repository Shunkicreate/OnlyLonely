//
//  P2PSessionManager.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/12.
//

import Foundation
import MultipeerKit

@MainActor
final class P2PSessionManager: ObservableObject {
    enum Role {
        case host
        case guest
    }

    enum SessionError: LocalizedError {
        case transceiverUnavailable

        var errorDescription: String? {
            switch self {
            case .transceiverUnavailable:
                return "トランシーバーが利用できません。"
            }
        }
    }

    @Published private(set) var role: Role?
    @Published private(set) var transceiver: MultipeerTransceiver?
    @Published private(set) var availablePeers: [Peer] = []
    @Published private(set) var connectedPeers: [Peer] = []
    @Published private(set) var localPeerID: String?

    private var configuration: MultipeerConfiguration?

    func configure(role: Role, configuration: MultipeerConfiguration) {
        reset()

        self.role = role
        self.configuration = configuration

        let transceiver = MultipeerTransceiver(configuration: configuration)
        bind(transceiver)
        transceiver.resume()
    }

    func resume() {
        transceiver?.resume()
    }

    func stop() {
        transceiver?.stop()
    }

    func reset() {
        transceiver?.stop()
        transceiver = nil
        role = nil
        configuration = nil
        availablePeers = []
        connectedPeers = []
        localPeerID = nil
    }

    private func bind(_ transceiver: MultipeerTransceiver) {
        self.transceiver = transceiver
        localPeerID = transceiver.localPeerId

        transceiver.availablePeersDidChange = { [weak self] peers in
            guard let self else { return }
            availablePeers = peers
            refreshConnectedPeers(using: peers)
        }

        transceiver.peerConnected = { [weak self] _ in
            self?.refreshConnectedPeers()
        }

        transceiver.peerDisconnected = { [weak self] _ in
            guard let self else { return }
            availablePeers = self.transceiver?.availablePeers ?? []
            refreshConnectedPeers()
        }

        transceiver.peerAdded = { [weak self] _ in
            guard let self else { return }
            availablePeers = self.transceiver?.availablePeers ?? []
        }

        transceiver.peerRemoved = { [weak self] _ in
            guard let self else { return }
            availablePeers = self.transceiver?.availablePeers ?? []
            refreshConnectedPeers()
        }
    }

    private func refreshConnectedPeers(using peers: [Peer]? = nil) {
        if let peers {
            connectedPeers = peers.filter { $0.isConnected }
        } else if let transceiver {
            connectedPeers = transceiver.availablePeers.filter { $0.isConnected }
        } else {
            connectedPeers = []
        }
    }

    func invite(_ peer: Peer, timeout: TimeInterval = 30, completion: @escaping (Result<Peer, Error>) -> Void) {
        guard let transceiver else {
            completion(.failure(SessionError.transceiverUnavailable))
            return
        }

        transceiver.invite(peer, with: nil, timeout: timeout, completion: completion)
    }
}
