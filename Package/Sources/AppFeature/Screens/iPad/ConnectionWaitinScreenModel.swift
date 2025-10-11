//
//  ConnectionWaitinScreenModel.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/16.
//

import Combine
import Foundation
import MultipeerKit
import UIKit

@MainActor
final class ConnectionWaitinScreenModel: ObservableObject {
    @Published private(set) var isHosting: Bool = false
    @Published private(set) var availableDevices: [PeerDevice] = []
    @Published private(set) var connectedDevices: [PeerDevice] = []
    @Published private(set) var statusMessage: String = "待機中"
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var invitingPeerID: String?

    private let serviceType = "onlylonelyp2p"
    private let sessionManager: P2PSessionManager
    private var cancellables = Set<AnyCancellable>()

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        observeSessionManager()
    }

    func startHosting() {
        guard !isHosting else { return }

        let configuration = MultipeerConfiguration(
            serviceType: serviceType,
            peerName: UIDevice.current.name,
            defaults: .standard,
            security: MultipeerConfiguration.Security(
                identity: nil,
                encryptionPreference: .none,
                invitationHandler: { _, _, completion in completion(true) }
            ),
            invitation: .none
        )

        sessionManager.configure(role: .host, configuration: configuration)
        isHosting = true
        statusMessage = "プレイヤーを探索中..."
        lastErrorMessage = nil
    }

    func stopHosting() {
        guard isHosting else { return }
        sessionManager.reset()
        isHosting = false
        availableDevices = []
        connectedDevices = []
        invitingPeerID = nil
        statusMessage = "待機中"
        lastErrorMessage = nil
    }

    func invite(_ device: PeerDevice) {
        guard isHosting else { return }
        invitingPeerID = device.id
        statusMessage = "\(device.name) に招待を送信中..."
        lastErrorMessage = nil

        sessionManager.invite(device.peer, timeout: 30) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if self.invitingPeerID == device.id {
                    self.invitingPeerID = nil
                }

                switch result {
                case .success(let peer):
                    self.statusMessage = "\(peer.name) が接続しました"
                case .failure(let error):
                    self.lastErrorMessage = error.localizedDescription
                    self.statusMessage = "招待に失敗しました"
                }
            }
        }
    }

    private func observeSessionManager() {
        sessionManager.$availablePeers
            .receive(on: RunLoop.main)
            .map { $0.filter { !$0.isConnected }.map(PeerDevice.init) }
            .assign(to: &$availableDevices)

        sessionManager.$connectedPeers
            .receive(on: RunLoop.main)
            .map { $0.map(PeerDevice.init) }
            .sink { [weak self] peers in
                guard let self else { return }
                connectedDevices = peers
                updateStatusForConnections(count: peers.count)
            }
            .store(in: &cancellables)
    }

    private func updateStatusForConnections(count: Int) {
        if count == 0 {
            statusMessage = isHosting ? "プレイヤーを探索中..." : "待機中"
        } else {
            statusMessage = "接続中のプレイヤー: \(count)"
        }
    }
}
