//
//  ConnectionScreenModel.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/16.
//

import Combine
import Foundation
import MultipeerKit
import UIKit

@MainActor
final class ConnectionScreenModel: ObservableObject {
    enum Phase: Equatable {
        case idle
        case connecting
        case connected
        case failed(String)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var hostName: String?
    @Published private(set) var invitationPeerName: String?
    @Published var playerName: String = ""

    private let serviceType = "onlylonelyp2p"
    private let sessionManager: P2PSessionManager
    private var cancellables = Set<AnyCancellable>()
    private var pendingInvitationHandler: ((Bool) -> Void)?

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        observeSessionManager()
    }

    func connect() {
        guard phase != .connecting, phase != .connected else { return }

        // 名前が入力されているか確認
        guard !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            phase = .failed("なまえをいれてね♪")
            return
        }

        hostName = nil
        phase = .connecting

        let configuration = guestConfiguration()
        sessionManager.configure(role: .guest, configuration: configuration)
    }

    func cancel() {
        pendingInvitationHandler?(false)
        pendingInvitationHandler = nil
        invitationPeerName = nil
        hostName = nil
        phase = .idle
        sessionManager.reset()
    }

    func approveInvitation() {
        guard let handler = pendingInvitationHandler else { return }
        handler(true)
        pendingInvitationHandler = nil
        invitationPeerName = nil
    }

    func declineInvitation() {
        guard let handler = pendingInvitationHandler else { return }
        handler(false)
        pendingInvitationHandler = nil
        invitationPeerName = nil
        hostName = nil
        phase = .idle
    }

    private func guestConfiguration() -> MultipeerConfiguration {
        let security = MultipeerConfiguration.Security(
            identity: nil,
            encryptionPreference: .none,
            invitationHandler: { [weak self] peer, _, completion in
                guard let self else {
                    completion(false)
                    return
                }

                Task { @MainActor in
                    self.pendingInvitationHandler = completion
                    self.invitationPeerName = peer.name
                    self.hostName = peer.name
                    self.phase = .connecting
                }
            }
        )

        return MultipeerConfiguration(
            serviceType: serviceType,
            peerName: playerName.trimmingCharacters(in: .whitespacesAndNewlines),
            defaults: .standard,
            security: security,
            invitation: .none
        )
    }

    private func observeSessionManager() {
        sessionManager.$connectedPeers
            .receive(on: RunLoop.main)
            .sink { [weak self] peers in
                self?.handleConnectedPeers(peers)
            }
            .store(in: &cancellables)
    }

    private func handleConnectedPeers(_ peers: [Peer]) {
        if let first = peers.first {
            hostName = first.name
            phase = .connected
            invitationPeerName = nil
            pendingInvitationHandler = nil
        } else if case .connected = phase {
            phase = .failed("接続が切断されました")
            hostName = nil
            invitationPeerName = nil
            pendingInvitationHandler = nil
        }
    }
}
