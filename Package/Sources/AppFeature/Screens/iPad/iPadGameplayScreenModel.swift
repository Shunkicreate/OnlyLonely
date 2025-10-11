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
    private var cancellables = Set<AnyCancellable>()

    func configure(sessionManager: P2PSessionManager) {
        guard sessionManager !== self.sessionManager else { return }
        self.sessionManager = sessionManager
        subscribe(to: sessionManager)
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
        let formattedForce = String(format: "%.3f", message.force)
        let formattedRoll = String(format: "%.2f", message.roll)
        print("📥 Wind update <- \(message.playerId): force=\(formattedForce), roll=\(formattedRoll) at \(message.timestamp)")
    }
}
