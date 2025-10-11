//
//  GameResultStore.swift
//  OnlyLonely
//
//  ゲーム結果を共有するストア
//

import Foundation

@MainActor
final class GameResultStore: ObservableObject {
    @Published private(set) var playerAAltitude: Double = 0
    @Published private(set) var playerBAltitude: Double = 0
    @Published private(set) var winner: PlayerSlot?
    @Published private(set) var finishedAt: Date?

    func reset() {
        playerAAltitude = 0
        playerBAltitude = 0
        winner = nil
        finishedAt = nil
    }

    func updateResults(playerAAltitude: Double, playerBAltitude: Double, timestamp: Date = Date()) {
        self.playerAAltitude = playerAAltitude
        self.playerBAltitude = playerBAltitude
        if playerAAltitude > playerBAltitude {
            winner = .playerA
        } else if playerBAltitude > playerAAltitude {
            winner = .playerB
        } else {
            winner = nil
        }
        finishedAt = timestamp
    }
}
