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
    @Published private(set) var localPeerId: String?

    private let navigationCommandSubject = PassthroughSubject<DeviceNavigationCommand, Never>()
    private let windForceSubject = PassthroughSubject<PlayerWindForceMessage, Never>()
    private let gameEventSubject = PassthroughSubject<GameEventMessage, Never>()
    private let characterAssignmentSubject = PassthroughSubject<CharacterAssignmentMessage, Never>()
    private var configuration: MultipeerConfiguration?

    func configure(role: Role, configuration: MultipeerConfiguration) {
        reset()

        let transceiver = MultipeerTransceiver(configuration: configuration)
        localPeerId = transceiver.localPeerId
        bind(transceiver)
        transceiver.resume()
    }

    func reset() {
        transceiver?.stop()
        transceiver = nil
        availablePeers = []
        connectedPeers = []
        localPeerId = nil
    }

    var navigationCommandPublisher: AnyPublisher<DeviceNavigationCommand, Never> {
        navigationCommandSubject.eraseToAnyPublisher()
    }

    var windForcePublisher: AnyPublisher<PlayerWindForceMessage, Never> {
        windForceSubject.eraseToAnyPublisher()
    }

    var gameEventPublisher: AnyPublisher<GameEventMessage, Never> {
        gameEventSubject.eraseToAnyPublisher()
    }

    var characterAssignmentPublisher: AnyPublisher<CharacterAssignmentMessage, Never> {
        characterAssignmentSubject.eraseToAnyPublisher()
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

        transceiver.receive(PlayerWindForceMessage.self) { [weak self] message, _ in
            Task { @MainActor [weak self] in
                self?.windForceSubject.send(message)
            }
        }

        transceiver.receive(GameEventMessage.self) { [weak self] message, _ in
            Task { @MainActor [weak self] in
                self?.gameEventSubject.send(message)
            }
        }

        transceiver.receive(CharacterAssignmentMessage.self) { [weak self] message, _ in
            Task { @MainActor [weak self] in
                self?.characterAssignmentSubject.send(message)
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

    func sendWindForce(_ message: PlayerWindForceMessage, to peers: [Peer]? = nil) {
        guard let transceiver else { return }
        let targets = peers ?? connectedPeers
        guard !targets.isEmpty else { return }
        transceiver.send(message, to: targets)
    }

    func sendGameEvent(_ message: GameEventMessage, to peers: [Peer]? = nil) {
        guard let transceiver else { return }
        let targets = peers ?? connectedPeers
        guard !targets.isEmpty else { return }
        transceiver.send(message, to: targets)
    }

    func sendCharacterAssignment(_ message: CharacterAssignmentMessage, to peers: [Peer]? = nil) {
        guard let transceiver else { return }
        let targets = peers ?? connectedPeers
        guard !targets.isEmpty else { return }
        transceiver.send(message, to: targets)
    }

    func resolveLocalPeerId() -> String? {
        if let localPeerId {
            return localPeerId
        }

        if let id = transceiver?.localPeerId {
            localPeerId = id
            return id
        }

        return nil
    }
}
