//
//  iPadGameplayScreenModel.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/21.
//

import Combine
import Foundation

@MainActor
final class iPadGameplayScreenModel: ObservableObject {
    private var sessionManager: P2PSessionManager?
    private weak var physicsCoordinator: GamePhysicsCoordinator?
    private var cancellables = Set<AnyCancellable>()
    @Published private(set) var playerNames: [PlayerSlot: String] = [:]

    func configure(sessionManager: P2PSessionManager, physicsCoordinator: GamePhysicsCoordinator) {
        let sessionChanged = sessionManager !== self.sessionManager
        self.sessionManager = sessionManager
        self.physicsCoordinator = physicsCoordinator

        if sessionChanged {
            subscribe(to: sessionManager)
        }

        refreshPlayerNames()
    }

    func cancelSubscriptions() {
        cancellables.removeAll()
    }

    private func subscribe(to sessionManager: P2PSessionManager) {
        cancellables.removeAll()

        sessionManager.windForcePublisher
            .receive(on: RunLoop.main)
            .sink { message in
                self.handleWindForce(message)
            }
            .store(in: &cancellables)

        sessionManager.$connectedPeers
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshPlayerNames()
            }
            .store(in: &cancellables)
    }

    private func handleWindForce(_ message: PlayerWindForceMessage) {
        print("📥 Wind update <- \(message.playerId): force=\(message.force), roll=\(message.roll) at \(message.timestamp)")
        physicsCoordinator?.receiveWindInput(
            playerId: message.playerId,
            force: message.force,
            timestamp: message.timestamp.timeIntervalSince1970
        )
        refreshPlayerNames()
    }

    func displayName(for slot: PlayerSlot) -> String {
        playerNames[slot] ?? defaultName(for: slot)
    }

    private func refreshPlayerNames() {
        guard let sessionManager else { return }

        var updated: [PlayerSlot: String] = [:]

        if let slotId = physicsCoordinator?.playerId(for: .playerA) ?? sessionManager.connectedPeers.first?.id,
           let peer = sessionManager.connectedPeers.first(where: { $0.id == slotId }) {
            updated[.playerA] = peer.name
        }

        if let slotId = physicsCoordinator?.playerId(for: .playerB) ?? sessionManager.connectedPeers.dropFirst().first?.id,
           let peer = sessionManager.connectedPeers.first(where: { $0.id == slotId }) {
            updated[.playerB] = peer.name
        }

        playerNames = updated
    }

    private func defaultName(for slot: PlayerSlot) -> String {
        switch slot {
        case .playerA:
            return "Player A"
        case .playerB:
            return "Player B"
        }
    }
}
