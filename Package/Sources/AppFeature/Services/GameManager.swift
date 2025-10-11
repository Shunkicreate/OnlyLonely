//
//  GameManager.swift
//  OnlyLonely
//

import Foundation
import Combine

@MainActor
class GameManager: ObservableObject {
    @Published var gamePhase: GamePhase = .idle
    @Published var playerA: PlayerInfo?
    @Published var playerB: PlayerInfo?
    @Published var timeRemaining: Int = 60
    @Published var gameResult: GameResult?

    private var gameTimer: Timer?
    private let gameDuration: Int = 60 // seconds

    func startGame() {
        gamePhase = .playing
        timeRemaining = gameDuration
        startTimer()
    }

    func endGame() {
        gamePhase = .finished
        stopTimer()
        calculateResult()
    }

    func resetGame() {
        gamePhase = .idle
        playerA?.altitude = 0
        playerB?.altitude = 0
        timeRemaining = gameDuration
        gameResult = nil
        stopTimer()
    }

    func updatePlayerAltitude(playerId: String, altitude: Double) {
        if playerA?.id == playerId {
            playerA?.altitude = altitude
        } else if playerB?.id == playerId {
            playerB?.altitude = altitude
        }
    }

    private func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
        }
    }

    private func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    private func calculateResult() {
        guard let playerA = playerA, let playerB = playerB else { return }

        let winner: PlayerSlot?
        if playerA.altitude > playerB.altitude {
            winner = .playerA
        } else if playerB.altitude > playerA.altitude {
            winner = .playerB
        } else {
            winner = nil // Draw
        }

        gameResult = GameResult(
            winner: winner,
            playerAltitude: playerA.altitude,
            opponentAltitude: playerB.altitude
        )
    }
}
