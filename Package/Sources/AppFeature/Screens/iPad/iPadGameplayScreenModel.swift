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

    func configure(sessionManager: P2PSessionManager, physicsCoordinator: GamePhysicsCoordinator) {
        let sessionChanged = sessionManager !== self.sessionManager
        self.sessionManager = sessionManager
        self.physicsCoordinator = physicsCoordinator

        if sessionChanged {
            subscribe(to: sessionManager)
        }
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
    }

    private func handleWindForce(_ message: PlayerWindForceMessage) {
        print("📥 Wind update <- \(message.playerId): force=\(message.force), roll=\(message.roll) at \(message.timestamp)")
        physicsCoordinator?.receiveWindInput(
            playerId: message.playerId,
            force: message.force,
            timestamp: message.timestamp.timeIntervalSince1970
        )
    }
}
