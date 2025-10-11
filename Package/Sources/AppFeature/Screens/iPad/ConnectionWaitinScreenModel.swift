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
    @Published private(set) var statusText: String = "待機中"
    @Published private(set) var connectedDevices: [Peer] = []
    @Published private(set) var isHosting: Bool = false

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
            security: .default,
            invitation: .automatic
        )

        sessionManager.configure(role: .host, configuration: configuration)
        isHosting = true
        statusText = "プレイヤー募集中"
    }

    func stopHosting() {
        guard isHosting else { return }
        sessionManager.reset()
        isHosting = false
        connectedDevices = []
        statusText = "待機中"
    }

    private func observeSessionManager() {
        sessionManager.$connectedPeers
            .receive(on: RunLoop.main)
            .sink { [weak self] peers in
                self?.connectedDevices = peers
                self?.updateStatus(for: peers.count)
            }
            .store(in: &cancellables)
    }

    private func updateStatus(for count: Int) {
        if count == 0 {
            statusText = isHosting ? "プレイヤー募集中" : "待機中"
        } else {
            statusText = "接続中のプレイヤー: \(count)"
        }
    }
}
