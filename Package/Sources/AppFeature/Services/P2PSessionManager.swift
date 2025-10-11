//
//  P2PSessionManager.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/12.
//

import Combine
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

    @Published private(set) var transceiver: MultipeerTransceiver?
    @Published private(set) var availablePeers: [Peer] = []
    @Published private(set) var connectedPeers: [Peer] = []

    private let navigationCommandSubject = PassthroughSubject<DeviceNavigationCommand, Never>()

    func configure(role: Role, configuration: MultipeerConfiguration) {
        reset()

        let transceiver = MultipeerTransceiver(configuration: configuration)
        bind(transceiver)
        transceiver.resume()
    }

    func reset() {
        transceiver?.stop()
        transceiver = nil
        availablePeers = []
        connectedPeers = []
    }

    var navigationCommandPublisher: AnyPublisher<DeviceNavigationCommand, Never> {
        navigationCommandSubject.eraseToAnyPublisher()
    }

    private func bind(_ transceiver: MultipeerTransceiver) {
        self.transceiver = transceiver

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

        transceiver.receive(DeviceNavigationCommand.self) { [weak self] command, _ in
            Task { @MainActor [weak self] in
                self?.navigationCommandSubject.send(command)
            }
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

    func sendNavigationCommand(_ command: DeviceNavigationCommand, to peers: [Peer]? = nil) {
        guard let transceiver else { return }
        let targets = peers ?? connectedPeers
        guard !targets.isEmpty else { return }
        transceiver.send(command, to: targets)
    }
}
