//
//  GamePhysicsCoordinator.swift
//  OnlyLonely
//
//  ゲーム全体の物理演算を統括するコーディネーター
//

import Foundation
import CoreGraphics

/// ゲーム物理演算の統括クラス
@MainActor
class GamePhysicsCoordinator: ObservableObject {
    // MARK: - Published Properties

    @Published var playerAState = BalloonPhysicsState()
    @Published var playerBState = BalloonPhysicsState()

    // MARK: - Dependencies (簡単に差し替え可能)

    private var balloonPhysics: BalloonPhysicsEngine
    private var cloudSystem: CloudSystem

    // MARK: - Internal State

    private var lastUpdateTime: TimeInterval = 0
    private var inputBuffer: [(player: PlayerSlot, force: Float, timestamp: TimeInterval)] = []
    private var playerAssignments: [String: PlayerSlot] = [:]

    // MARK: - Initialization

    init(
        balloonPhysics: BalloonPhysicsEngine = SimpleBalloonPhysics(),
        cloudSystem: CloudSystem = SimpleCloudSystem()
    ) {
        self.balloonPhysics = balloonPhysics
        self.cloudSystem = cloudSystem
    }

    // MARK: - Public Methods

    /// 物理演算を更新（60fpsで呼ばれる）
    func update(currentTime: TimeInterval) {
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // 入力を補間して適用
        applyInterpolatedInput()

        // 風船の物理更新
        balloonPhysics.update(state: &playerAState, deltaTime: deltaTime)
        balloonPhysics.update(state: &playerBState, deltaTime: deltaTime)

        // 雲との衝突チェック
        handleCloudCollisions()
    }

    /// iPhoneからの風力入力を受信（30Hzで呼ばれる）
    func receiveWindInput(playerId: String, force: Float, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        guard let player = resolveSlot(for: playerId) else { return }

        let scaledForce = force * PhysicsConstants.windForceSensitivity
        let clampedForce = max(0, min(PhysicsConstants.maxWindForce, scaledForce))
        inputBuffer.append((player, clampedForce, timestamp))

        // バッファサイズ制限
        if inputBuffer.count > 10 {
            inputBuffer.removeFirst()
        }
    }

    /// 雲データを読み込み
    func loadCloudData(json: String) throws {
        try cloudSystem.loadClouds(from: json)
    }

    /// 特定の位置での雲との衝突をチェック（GameScene から呼び出し用）
    func checkCollision(balloonPosition: CGPoint, balloonVelocity: CGVector) -> CollisionResult {
        return cloudSystem.checkCollision(balloonPosition: balloonPosition, balloonVelocity: balloonVelocity)
    }

    // MARK: - Private Methods

    private func applyInterpolatedInput() {
        // 30Hz入力を60fps描画に補間
        // TODO: より高度な補間アルゴリズム実装

        guard let latest = inputBuffer.last else { return }

        switch latest.player {
        case .playerA:
            balloonPhysics.applyWindForce(latest.force, to: &playerAState)
        case .playerB:
            balloonPhysics.applyWindForce(latest.force, to: &playerBState)
        }
    }

    private func handleCloudCollisions() {
        // Player A の衝突チェック
        let collisionA = cloudSystem.checkCollision(
            balloonPosition: playerAState.position,
            balloonVelocity: playerAState.velocity
        )
        handleCollisionResult(collisionA, forPlayer: .playerA)

        // Player B の衝突チェック
        let collisionB = cloudSystem.checkCollision(
            balloonPosition: playerBState.position,
            balloonVelocity: playerBState.velocity
        )
        handleCollisionResult(collisionB, forPlayer: .playerB)
    }

    func playerId(for slot: PlayerSlot) -> String? {
        return playerAssignments.first { $0.value == slot }?.key
    }

    private func resolveSlot(for playerId: String) -> PlayerSlot? {
        if let predefined = predefinedSlot(for: playerId) {
            return predefined
        }

        if let existing = playerAssignments[playerId] {
            return existing
        }

        if !playerAssignments.values.contains(.playerA) {
            playerAssignments[playerId] = .playerA
            return .playerA
        }

        if !playerAssignments.values.contains(.playerB) {
            playerAssignments[playerId] = .playerB
            return .playerB
        }

        return nil
    }

    private func predefinedSlot(for playerId: String) -> PlayerSlot? {
        switch playerId {
        case "A":
            playerAssignments[playerId] = .playerA
            return .playerA
        case "B":
            playerAssignments[playerId] = .playerB
            return .playerB
        default:
            return nil
        }
    }

    private func handleCollisionResult(_ result: CollisionResult, forPlayer player: PlayerSlot) {
        switch result {
        case .none, .passThrough:
            break

        case .blocked:
            // 跳ね返る
            switch player {
            case .playerA:
                playerAState.velocity.dy = -abs(playerAState.velocity.dy) * 0.5
            case .playerB:
                playerBState.velocity.dy = -abs(playerBState.velocity.dy) * 0.5
            }

        case .lightning:
            // 風船破裂
            switch player {
            case .playerA:
                balloonPhysics.popBalloon(state: &playerAState)
            case .playerB:
                balloonPhysics.popBalloon(state: &playerBState)
            }

            // 復活タイマー
            Task {
                try? await Task.sleep(nanoseconds: UInt64(PhysicsConstants.balloonRespawnTime * 1_000_000_000))
                await MainActor.run {
                    switch player {
                    case .playerA:
                        self.balloonPhysics.respawnBalloon(state: &self.playerAState)
                    case .playerB:
                        self.balloonPhysics.respawnBalloon(state: &self.playerBState)
                    }
                }
            }
        }
    }
}
