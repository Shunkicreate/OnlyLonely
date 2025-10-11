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
    private var playerAssignments: [String: PlayerSlot] = [:]
    private var latestForceInputs: [PlayerSlot: Float] = [:]
    private var latestRollInputs: [PlayerSlot: Double] = [:]
    private var laneCenters: [PlayerSlot: CGFloat] = [:]
    private var laneHalfWidth: CGFloat = 0

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

        // 左右移動を適用
        applyHorizontalMovement(deltaTime: deltaTime)

        // 雲との衝突チェック
        handleCloudCollisions()
    }

    /// iPhoneからの風力入力を受信（30Hzで呼ばれる）
    func receiveWindInput(
        playerId: String,
        force: Float,
        roll: Double,
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        guard let player = resolveSlot(for: playerId) else { return }

        let scaledForce = force * PhysicsConstants.windForceSensitivity
        let clampedForce = max(0, min(PhysicsConstants.maxWindForce, scaledForce))
        latestForceInputs[player] = clampedForce

        let normalizedRoll = normalizeRoll(roll)
        latestRollInputs[player] = normalizedRoll
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
        if let force = latestForceInputs[.playerA] {
            balloonPhysics.applyWindForce(force, to: &playerAState)
        }

        if let force = latestForceInputs[.playerB] {
            balloonPhysics.applyWindForce(force, to: &playerBState)
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

    func laneCenter(for slot: PlayerSlot) -> CGFloat? {
        laneCenters[slot]
    }

    func configureHorizontalBounds(sceneSize: CGSize) {
        let centerA = sceneSize.width / 4
        let centerB = sceneSize.width * 3 / 4
        laneCenters[.playerA] = centerA
        laneCenters[.playerB] = centerB

        let halfLane = max(0, (sceneSize.width / 4) - PhysicsConstants.laneHorizontalPadding)
        laneHalfWidth = halfLane

        playerAState.position.x = centerA
        playerBState.position.x = centerB

        latestRollInputs[.playerA] = 0
        latestRollInputs[.playerB] = 0
    }

    private func applyHorizontalMovement(deltaTime: TimeInterval) {
        guard !laneCenters.isEmpty else { return }
        let dt = CGFloat(deltaTime)

        if let center = laneCenters[.playerA] {
            let normalized = CGFloat(latestRollInputs[.playerA] ?? 0)
            playerAState.velocity.dx = normalized * PhysicsConstants.horizontalSpeed
            playerAState.position.x += playerAState.velocity.dx * dt
            let range = (center - laneHalfWidth)...(center + laneHalfWidth)
            playerAState.position.x = clamp(playerAState.position.x, to: range)
        }

        if let center = laneCenters[.playerB] {
            let normalized = CGFloat(latestRollInputs[.playerB] ?? 0)
            playerBState.velocity.dx = normalized * PhysicsConstants.horizontalSpeed
            playerBState.position.x += playerBState.velocity.dx * dt
            let range = (center - laneHalfWidth)...(center + laneHalfWidth)
            playerBState.position.x = clamp(playerBState.position.x, to: range)
        }
    }

    private func clamp(_ value: CGFloat, to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(value, range.lowerBound), range.upperBound)
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
                playerAState.velocity.dx = 0
            case .playerB:
                playerBState.velocity.dy = -abs(playerBState.velocity.dy) * 0.5
                playerBState.velocity.dx = 0
            }

        case .lightning:
            // 風船破裂
            switch player {
            case .playerA:
                balloonPhysics.popBalloon(state: &playerAState)
                playerAState.velocity.dx = 0
            case .playerB:
                balloonPhysics.popBalloon(state: &playerBState)
                playerBState.velocity.dx = 0
            }

            // 復活タイマー
            Task {
                try? await Task.sleep(nanoseconds: UInt64(PhysicsConstants.balloonRespawnTime * 1_000_000_000))
                await MainActor.run {
                    switch player {
                    case .playerA:
                        self.balloonPhysics.respawnBalloon(state: &self.playerAState)
                        if let center = self.laneCenters[.playerA] {
                            self.playerAState.position.x = center
                        }
                    case .playerB:
                        self.balloonPhysics.respawnBalloon(state: &self.playerBState)
                        if let center = self.laneCenters[.playerB] {
                            self.playerBState.position.x = center
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func normalizeRoll(_ roll: Double) -> Double {
        let maxDegrees = PhysicsConstants.maxTiltDegrees
        guard maxDegrees > 0 else { return 0 }
        let clamped = max(-maxDegrees, min(maxDegrees, roll))
        return clamped / maxDegrees
    }
}
