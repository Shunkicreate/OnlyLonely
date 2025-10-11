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

        var statusText: String {
            switch self {
            case .idle:
                return "未接続です"
            case .connecting:
                return "接続中..."
            case .connected:
                return "接続完了"
            case .failed(let message):
                return "接続に失敗しました: \(message)"
            }
        }
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var hostName: String?

    private let serviceType = "onlylonelyp2p"
    private let sessionManager: P2PSessionManager
    private var cancellables = Set<AnyCancellable>()
    private var isAttemptingConnection = false

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        observeSessionManager()
    }

    func connect() {
        guard phase != .connecting, phase != .connected else { return }

        hostName = nil
        isAttemptingConnection = true
        phase = .connecting

        let configuration = guestConfiguration()
        sessionManager.configure(role: .guest, configuration: configuration)
    }

    func cancel() {
        isAttemptingConnection = false
        hostName = nil
        phase = .idle
        sessionManager.reset()
    }

    private func guestConfiguration() -> MultipeerConfiguration {
        let security = MultipeerConfiguration.Security(
            identity: nil,
            encryptionPreference: .required,
            invitationHandler: { [weak self] peer, _, completion in
                guard let self else {
                    completion(false)
                    return
                }

                let shouldAccept = isAttemptingConnection
                if shouldAccept {
                    hostName = peer.name
                }
                completion(shouldAccept)
            }
        )

        return MultipeerConfiguration(
            serviceType: serviceType,
            peerName: UIDevice.current.name,
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
            isAttemptingConnection = false
            phase = .connected
        } else if case .connected = phase {
            phase = .failed("接続が切断されました")
            isAttemptingConnection = false
            hostName = nil
        }
    }
}
