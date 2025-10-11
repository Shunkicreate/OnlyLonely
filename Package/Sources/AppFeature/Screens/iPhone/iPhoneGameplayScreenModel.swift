//
//  iPhoneGameplayScreenModel.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/21.
//

import Combine
import Foundation

@MainActor
final class iPhoneGameplayScreenModel: ObservableObject {
    private var sessionManager: P2PSessionManager?
    private var playerId: String = "A"
    private var cancellables = Set<AnyCancellable>()
    private var currentRoll: Double = 0
    private var currentForce: Float = 0

    func configure(sessionManager: P2PSessionManager, playerId: String) {
        self.sessionManager = sessionManager
        self.playerId = playerId
    }

    func bindInputs(microphone: MicrophoneLevelManager, motionManager: MotionManager) {
        cancellables.removeAll()

        microphone.$windForce
            .receive(on: RunLoop.main)
            .removeDuplicates(by: { previous, current in
                abs(previous - current) < 0.02
            })
            .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] force in
                self?.currentForce = force
            }
            .store(in: &cancellables)

        motionManager.$roll
            .receive(on: RunLoop.main)
            .sink { [weak self] roll in
                self?.currentRoll = roll
            }
            .store(in: &cancellables)
    }

    func cancelBindings() {
        cancellables.removeAll()
    }

    func sendWindForce() {
        guard let sessionManager else { return }
        let normalizedForce = max(0, min(1, self.currentForce))
        let message = PlayerWindForceMessage(
            playerId: playerId,
            force: normalizedForce,
            roll: currentRoll,
            timestamp: Date()
        )
        sessionManager.sendWindForce(message)
    }
}
