//
//  ConnectionScreenModel.swift
//  Package
//
//  Created by shunsuke tamura on 2025/10/11.
//

import Combine
import Foundation
import MultipeerConnectivity

@MainActor
final class ConnectionScreenModel: NSObject, ObservableObject {
    enum ConnectionPhase: Equatable {
        case idle
        case connecting
        case connected
        case failed
    }

    @Published private(set) var phase: ConnectionPhase = .idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var hostDisplayName: String?
    @Published private(set) var invitationReceived: Bool = false
    @Published private(set) var isReadyToProceed: Bool = false
    @Published private(set) var isAdvertising: Bool = false

    private let serviceType = "onlylonelyp2p"
    private let peerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let sessionManager: P2PSessionManager

    private var wantsConnection = false

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        peerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: ["role": "guest"],
            serviceType: serviceType
        )

        super.init()

        session.delegate = self
        advertiser.delegate = self
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        session.disconnect()
    }

    func connect() {
        guard phase != .connecting else { return }

        wantsConnection = true
        errorMessage = nil
        phase = .connecting
        isReadyToProceed = false
        sessionManager.configure(role: .guest, peerID: peerID, session: session)
        sessionManager.updateConnectedPeers([])
        startAdvertising()
    }

    func stop() {
        wantsConnection = false
        stopAdvertising()
        session.disconnect()
        phase = .idle
        errorMessage = nil
        hostDisplayName = nil
        invitationReceived = false
        isReadyToProceed = false
        sessionManager.reset()
    }

    private func startAdvertising() {
        guard !isAdvertising else { return }
        advertiser.startAdvertisingPeer()
        isAdvertising = true
    }

    private func stopAdvertising() {
        guard isAdvertising else { return }
        advertiser.stopAdvertisingPeer()
        isAdvertising = false
    }

    private func handleFailure(message: String?) {
        errorMessage = message
        phase = .failed
        isReadyToProceed = false
        hostDisplayName = nil
        invitationReceived = false
        wantsConnection = false
        sessionManager.reset()
    }
}

extension ConnectionScreenModel: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        Task { @MainActor in
            guard wantsConnection else {
                invitationHandler(false, nil)
                return
            }

            hostDisplayName = peerID.displayName
            invitationReceived = true
            invitationHandler(true, session)
        }
    }

    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Task { @MainActor in
            handleFailure(message: error.localizedDescription)
        }
    }
}

extension ConnectionScreenModel: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .notConnected:
                stopAdvertising()
                if phase == .connected {
                    handleFailure(message: "接続が切断されました")
                } else if wantsConnection {
                    handleFailure(message: "iPadと接続できませんでした")
                } else {
                    handleFailure(message: nil)
                }
            case .connecting:
                phase = .connecting
            case .connected:
                stopAdvertising()
                errorMessage = nil
                phase = .connected
                isReadyToProceed = true
                wantsConnection = false
                sessionManager.updateConnectedPeers(session.connectedPeers)
            @unknown default:
                break
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) { }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }

    nonisolated func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
