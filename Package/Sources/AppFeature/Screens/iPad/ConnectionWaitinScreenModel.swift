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
    @Published private(set) var statusMessage: String = "たいきちゅう"
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var invitingPeerID: String?

    private let serviceType = "onlylonelyp2p"
    private let sessionManager: P2PSessionManager
    private var cancellables = Set<AnyCancellable>()
    private var characterManager: CharacterAssignmentManager?

    init(sessionManager: P2PSessionManager) {
        self.sessionManager = sessionManager
        observeSessionManager()
    }

    func configure(characterManager: CharacterAssignmentManager) {
        self.characterManager = characterManager
    }

    var canProceedToNextStep: Bool {
        connectedDevices.count >= 2
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
        statusMessage = "ぷれいやーをさがしているよ..."
        lastErrorMessage = nil
    }

    func stopHosting() {
        guard isHosting else { return }
        sessionManager.reset()
        isHosting = false
        availableDevices = []
        connectedDevices = []
        invitingPeerID = nil
        statusMessage = "たいきちゅう"
        lastErrorMessage = nil
    }

    func invite(_ device: PeerDevice) {
        guard isHosting else { return }
        invitingPeerID = device.id
        statusMessage = "\(device.name) にしょうたいをおくっているよ..."
        lastErrorMessage = nil

        sessionManager.invite(device.peer, timeout: 30) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                if self.invitingPeerID == device.id {
                    self.invitingPeerID = nil
                }

                switch result {
                case .success(let peer):
                    self.statusMessage = "\(peer.name) がせつぞくしたよ"
                case .failure(let error):
                    self.lastErrorMessage = error.localizedDescription
                    self.statusMessage = "しょうたいにしっぱいしちゃった"
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
            statusMessage = isHosting ? "ぷれいやーをさがしているよ..." : "たいきちゅう"
        } else {
            statusMessage = "せつぞくちゅうのぷれいやー: \(count)"
        }
    }

    func advanceConnectedDevicesToCountdown() {
        guard canProceedToNextStep else { return }

        // キャラクターをランダムに割り当て
        characterManager?.assignRandomCharacters()

        // 各プレイヤーにキャラクター割り当てを送信
        if let characterManager = characterManager {
            let peers = connectedDevices.map(\.peer)

            // PlayerAの割り当てを送信
            if let characterA = characterManager.playerACharacter {
                let messageA = CharacterAssignmentMessage(playerId: "A", character: characterA)
                sessionManager.sendCharacterAssignment(messageA, to: peers)
            }

            // PlayerBの割り当てを送信
            if let characterB = characterManager.playerBCharacter {
                let messageB = CharacterAssignmentMessage(playerId: "B", character: characterB)
                sessionManager.sendCharacterAssignment(messageB, to: peers)
            }
        }

        // カウントダウン画面へ遷移
        let peers = connectedDevices.map(\.peer)
        let command = DeviceNavigationCommand(action: .showCountdown)
        sessionManager.sendNavigationCommand(command, to: peers)
    }
}
