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
}
