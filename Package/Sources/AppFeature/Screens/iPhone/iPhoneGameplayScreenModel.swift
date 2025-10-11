//
//  iPhoneGameplayScreenModel.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/12.
//

import Foundation
import MultipeerConnectivity

@MainActor
final class iPhoneGameplayScreenModel: ObservableObject {
    private let sessionManager: P2PSessionManager
    private let encoder = JSONEncoder()

    private var lastSentForce: Float = 0.0
    private var lastSentDate: Date = .distantPast

    private let forceDeltaThreshold: Float = 0.02
    private let minSendInterval: TimeInterval = 0.05
    private let heartbeatInterval: TimeInterval = 0.5

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
    }

    func prepareSessionIfNeeded() {
        // Currently a placeholder for future session setup requirements.
    }

    func sendWindForce(_ force: Float) {
        guard let session = sessionManager.session, !session.connectedPeers.isEmpty else { return }

        let clampedForce = max(0, min(1.0, force))
        let now = Date()
        let delta = abs(clampedForce - lastSentForce)
        let elapsed = now.timeIntervalSince(lastSentDate)
        let shouldForceSend = clampedForce == 0 && lastSentForce != 0
        let shouldSendHeartbeat = elapsed >= heartbeatInterval

        guard delta >= forceDeltaThreshold || shouldForceSend || shouldSendHeartbeat || elapsed >= minSendInterval else {
            return
        }

        lastSentForce = clampedForce
        lastSentDate = now

        let message = WindForceMessage(force: clampedForce)

        do {
            let data = try encoder.encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("⚠️ Wind force send failed: \(error.localizedDescription)")
        }
    }
}
