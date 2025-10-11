//
//  ConnectionWaitinScreenModel.swift
//  Package
//
//  Created by shunsuke tamura on 2025/10/11.
//

import Combine
import Foundation
import MultipeerConnectivity

@MainActor
final class ConnectionWaitinScreenModel: NSObject, ObservableObject {
    @Published private(set) var playerAState: PlayerState = .disconnected
    @Published private(set) var playerBState: PlayerState = .disconnected
    @Published private(set) var discoveredGuests: [PeerDevice] = []
    @Published private(set) var connectedPeerNames: [String] = []
    @Published private(set) var isBrowsing: Bool = false
    @Published private(set) var isSessionReady: Bool = false
    @Published private(set) var errorMessage: String?

    private let serviceType = "onlylonelyp2p"
    private let hostPeerID: MCPeerID
    private let session: MCSession
    private let browser: MCNearbyServiceBrowser
    private let sessionManager: P2PSessionManager

    private var invitedPeers: Set<MCPeerID> = []
    private var slotByPeer: [MCPeerID: PlayerSlot] = [:]

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        hostPeerID = MCPeerID(displayName: UIDevice.current.name)
        session = MCSession(peer: hostPeerID, securityIdentity: nil, encryptionPreference: .required)
        browser = MCNearbyServiceBrowser(peer: hostPeerID, serviceType: serviceType)
        super.init()

        session.delegate = self
        browser.delegate = self
    }

    deinit {
        browser.stopBrowsingForPeers()
        session.disconnect()
    }

    var hostDisplayName: String {
        hostPeerID.displayName
    }

    func playerState(for slot: PlayerSlot) -> PlayerState {
        switch slot {
        case .playerA:
            return playerAState
        case .playerB:
            return playerBState
        }
    }

    func startHosting() {
        guard !isBrowsing else { return }
        sessionManager.configure(role: .host, peerID: hostPeerID, session: session)
        sessionManager.updateConnectedPeers(session.connectedPeers)
        browser.startBrowsingForPeers()
        isBrowsing = true
        errorMessage = nil
    }

    func stopHosting() {
        guard isBrowsing else {
            resetSession()
            return
        }

        browser.stopBrowsingForPeers()
        resetSession()
    }

    private func resetSession() {
        session.disconnect()
        sessionManager.reset()
        invitedPeers.removeAll()
        slotByPeer.removeAll()
        discoveredGuests.removeAll()
        connectedPeerNames.removeAll()

        playerAState = .disconnected
        playerBState = .disconnected
        isBrowsing = false
        updateReadiness()
    }

    private func assignSlotIfNeeded(for peerID: MCPeerID) -> PlayerSlot? {
        if let slot = slotByPeer[peerID] {
            return slot
        }

        if !slotByPeer.values.contains(.playerA) {
            slotByPeer[peerID] = .playerA
            return .playerA
        }

        if !slotByPeer.values.contains(.playerB) {
            slotByPeer[peerID] = .playerB
            return .playerB
        }

        return nil
    }

    private func inviteIfPossible(peerID: MCPeerID) {
        guard !invitedPeers.contains(peerID) else { return }
        guard let slot = assignSlotIfNeeded(for: peerID) else { return }

        invitedPeers.insert(peerID)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        setState(.connected, for: slot)
    }

    private func setState(_ state: PlayerState, for slot: PlayerSlot) {
        switch slot {
        case .playerA:
            playerAState = state
        case .playerB:
            playerBState = state
        }
        updateReadiness()
    }

    private func updateReadiness() {
        isSessionReady = playerAState == .ready && playerBState == .ready
    }

    private func handlePeerDisconnected(_ peerID: MCPeerID) {
        guard let slot = slotByPeer.removeValue(forKey: peerID) else { return }
        invitedPeers.remove(peerID)
        setState(.disconnected, for: slot)
        connectedPeerNames = session.connectedPeers.map(\.displayName)
        sessionManager.updateConnectedPeers(session.connectedPeers)
        inviteNextAvailableGuest()
    }

    private func inviteNextAvailableGuest() {
        guard let next = discoveredGuests.first(where: { !invitedPeers.contains($0.peerId) }) else {
            return
        }
        inviteIfPossible(peerID: next.peerId)
    }

    private func updateConnectedPeerNames() {
        connectedPeerNames = session.connectedPeers.map(\.displayName)
        sessionManager.updateConnectedPeers(session.connectedPeers)
    }
}

extension ConnectionWaitinScreenModel: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        Task { @MainActor in
            if !discoveredGuests.contains(where: { $0.peerId == peerID }) {
                let device = PeerDevice(peerId: peerID)
                discoveredGuests.append(device)
            }
            inviteIfPossible(peerID: peerID)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            discoveredGuests.removeAll(where: { $0.peerId == peerID })
            handlePeerDisconnected(peerID)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Task { @MainActor in
            errorMessage = error.localizedDescription
            isBrowsing = false
        }
    }
}

extension ConnectionWaitinScreenModel: MCSessionDelegate {
  nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    Task { @MainActor in
      guard let slot = slotByPeer[peerID] ?? assignSlotIfNeeded(for: peerID) else {
        return
      }
      
      switch state {
      case .notConnected:
        handlePeerDisconnected(peerID)
      case .connecting:
        setState(.connected, for: slot)
        updateConnectedPeerNames()
      case .connected:
        setState(.ready, for: slot)
        updateConnectedPeerNames()
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
