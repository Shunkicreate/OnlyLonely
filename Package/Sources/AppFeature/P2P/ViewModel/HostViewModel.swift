//
//  HostViewModel.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//

import Foundation
import MultipeerConnectivity
import SwiftUI
import Combine

class HostViewModel: NSObject, ObservableObject {
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    private let serviceType = "nearby-devices"
    
    @Published var sessionState: MCSessionState = .notConnected
    @Published var peers: [PeerDevice] = []
    var selectedPeers: [PeerDevice] = []
    var joinedPeers: [PeerDevice] = []
    
    let gameState: GameState
    let messageReceiver = PassthroughSubject<P2PMessage, Never>()
    var subscriptions = Set<AnyCancellable>()
    
    init(gameState: GameState) {
        let peer = MCPeerID(displayName: UIDevice.current.name)
        self.gameState = gameState
        self.gameState.setProperties(_session: MCSession(peer: peer), _ballState: BallState(position: BallPosition(x: 0, y: 0)))
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: peer,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        
        super.init()
        
        browser.delegate = self
        advertiser.delegate = self
        gameState.session!.delegate = self
        
        browser.startBrowsingForPeers()
    }
    
    func finishBrowsing() {
        browser.stopBrowsingForPeers()
    }
    
    // ① 部屋を用意して，相手を招待する
    func invite(_selectedPeer: PeerDevice) {
        selectedPeers.append(_selectedPeer)
        guard gameState.session != nil else {
            print("Failed to invite peer: session is nil")
            return
        }
        browser.invitePeer(_selectedPeer.peerId, to: gameState.session!, withContext: nil, timeout: 60)
    }
    
    // ② 招待した相手が入っていたら，この関数を使って自分も部屋に入ったことにする
    func join() -> Bool {
        print("👹 \(selectedPeers),,, \(isParticipantsJoined())")
        if !isParticipantsJoined() {
            return false
        }
        
        joinedPeers = selectedPeers
        return true
    }
    
    func isParticipantsJoined() -> Bool {
        guard let session = gameState.session else {
            print("Failed to check if participants are joined: session is nil")
            return false
        }
        if selectedPeers.count == 0 || !selectedPeers.allSatisfy({session.connectedPeers.contains($0.peerId)}) {
            return false
        }
        
        return true
    }

    func sendGameStartMessage() {
        let peerIds = Array(joinedPeers.map { $0.peerId }.prefix(3))
        for index in 0..<peerIds.count {
            guard let messageData = P2PMessage(
                type: .gameStartMessage,
                jsonData: "@@\((index + 1).description)"
            ).toSendMessage().data(using: .utf8) else {
                return
            }
            print("👹 \(peerIds[index])")
            print("👹 \(messageData)")
            try? gameState.session?.send(messageData, toPeers: [peerIds[index]], with: .reliable)
        }
        gameState.updatePhase(phase: .started)
    }

    private func applyTap(_ action: TapAction) {
        let step: CGFloat = 24
        let current = gameState.ballState?.position ?? BallPosition(x: 0, y: 0)
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        switch action {
        case .up: dy = -step
        case .down: dy = step
        case .left: dx = -step
        case .right: dx = step
        }
        let newPos = BallPosition(x: Int(CGFloat(current.x) + dx), y: Int(CGFloat(current.y) + dy))
        let newState = BallState(position: newPos)
        gameState.updateBallState(_ballState: newState)
        // Broadcast new position
        let message = UpdateBallStateMessage(ballState: newState)
        guard
            let json = message.toJson(),
            let data = P2PMessage(type: .updateBallStateMessage, jsonData: json).toSendMessage().data(using: .utf8)
        else { return }
        try? gameState.session?.send(data, toPeers: gameState.session?.connectedPeers ?? [], with: .reliable)
    }
}

extension HostViewModel: MCNearbyServiceBrowserDelegate {
    // 接続可能なデバイスをappendする
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        peers.append(PeerDevice(peerId: peerID))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        peers.removeAll(where: { $0.peerId == peerID })
    }
}



extension HostViewModel: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        //
    }
}

extension HostViewModel: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
           self.sessionState = state
       }
    
    // sessionを通して送られてくるmessageをViewLogicのballStateReceiverに流す
    func session(_ session: MCSession, didReceive data: Data, fromPeer fromPeerID: MCPeerID) {
        guard let message = String(data: data, encoding: .utf8) else {
            return
        }

        guard let _message = P2PMessage.fromReceivedMessage(message: message) else {
            return
        }
        switch _message.type {
        case .gameTapActionMessage:
            if let tap = TapActionMessage.fromJson(_message.jsonData) {
                DispatchQueue.main.async { [weak self] in self?.applyTap(tap.action) }
            }
        default:
            messageReceiver.send(_message)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        //
    }
    
}
