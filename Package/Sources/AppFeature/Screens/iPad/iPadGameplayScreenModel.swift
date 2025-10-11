//
//  iPadGameplayScreenModel.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/12.
//

import Combine
import Foundation
import MultipeerConnectivity

@MainActor
final class iPadGameplayScreenModel: NSObject, ObservableObject {
    @Published private(set) var lastReceivedForce: Float = 0.0

    private let sessionManager: P2PSessionManager
    private var cancellables: Set<AnyCancellable> = []
    private weak var currentSession: MCSession?

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        super.init()

        sessionManager.$session
            .sink { [weak self] session in
                Task { @MainActor in
                    self?.configureSession(session)
                }
            }
            .store(in: &cancellables)

        configureSession(sessionManager.session)
    }

    func activate() {
        configureSession(sessionManager.session)
    }

    private func configureSession(_ session: MCSession?) {
        guard currentSession !== session else { return }
        currentSession = session
        currentSession?.delegate = self
    }

    @MainActor
    private func handleWindForce(_ force: Float, from peer: MCPeerID) {
        lastReceivedForce = force
        print("🌬️ Received wind force \(lastReceivedForce)")
    }
}

extension iPadGameplayScreenModel: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) { }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        guard let message = try? decoder.decode(WindForceMessage.self, from: data) else { return }

        guard message.type == .wind else { return }

        Task { @MainActor [weak self] in
            self?.handleWindForce(message.force, from: peerID)
        }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }

    nonisolated func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
