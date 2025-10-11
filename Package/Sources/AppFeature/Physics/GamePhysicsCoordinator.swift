//
//  GamePhysicsCoordinator.swift
//  OnlyLonely
//
//  ゲーム全体の物理演算を統括するコーディネーター
//

import Foundation
import CoreGraphics
import SpriteKit

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

    private struct CloudConfigPayload: Codable {
        let clouds: [CloudData]
    }

    private var lastUpdateTime: TimeInterval = 0
    private var playerAssignments: [String: PlayerSlot] = [:]
    private var latestForceInputs: [PlayerSlot: Float] = [:]
    private var latestRollInputs: [PlayerSlot: Double] = [:]
    private var laneCenters: [PlayerSlot: CGFloat] = [:]
    private var laneHalfWidths: [PlayerSlot: CGFloat] = [:]
    private var balloonBodies: [PlayerSlot: SKPhysicsBody] = [:]
    private var cloudDataStore: [CloudData] = []

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

        let usingPhysicsBodies = !balloonBodies.isEmpty

        // 入力を反映
        applyInterpolatedInput(usingPhysicsBodies: usingPhysicsBodies)

        if usingPhysicsBodies {
            applyHorizontalMovement(deltaTime: deltaTime, usingPhysicsBodies: true)
            updateStatesFromPhysics()
        } else {
            // 風船の物理更新（手動計算）
            balloonPhysics.update(state: &playerAState, deltaTime: deltaTime)
            balloonPhysics.update(state: &playerBState, deltaTime: deltaTime)
            applyHorizontalMovement(deltaTime: deltaTime, usingPhysicsBodies: false)
        }

        // 雲との衝突チェック
        handleCloudCollisions()
    }

    /// iPhoneからの風力入力を受信（30Hzで呼ばれる）
    func receiveWindInput(
        playerId: String,
        force: Float,
        roll: Double,
        timestamp _: TimeInterval = Date().timeIntervalSince1970
    ) {
        guard let player = resolveSlot(for: playerId) else { return }

        let clampedForce = max(0, PhysicsConstants.windForce(force: force))
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

    private func applyInterpolatedInput(usingPhysicsBodies: Bool) {
        if usingPhysicsBodies {
            if let force = latestForceInputs[.playerA],
               let body = balloonBodies[.playerA] {
                let lift = CGFloat(force) * PhysicsConstants.liftCoefficient
                body.applyForce(CGVector(dx: 0, dy: lift))
            }

            if let force = latestForceInputs[.playerB],
               let body = balloonBodies[.playerB] {
                let lift = CGFloat(force) * PhysicsConstants.liftCoefficient
                body.applyForce(CGVector(dx: 0, dy: lift))
            }
        } else {
            if let force = latestForceInputs[.playerA] {
                balloonPhysics.applyWindForce(force, to: &playerAState)
            }

            if let force = latestForceInputs[.playerB] {
                balloonPhysics.applyWindForce(force, to: &playerBState)
            }
        }

        playerAState.windForce = latestForceInputs[.playerA] ?? 0
        playerBState.windForce = latestForceInputs[.playerB] ?? 0
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

    var usesSpriteKitPhysics: Bool {
        !balloonBodies.isEmpty
    }

    func configureLaneBounds(for slot: PlayerSlot, sceneSize: CGSize) {
        let center = sceneSize.width / 2
        laneCenters[slot] = center
        let halfLane = max(0, center - PhysicsConstants.laneHorizontalPadding)
        laneHalfWidths[slot] = halfLane

        var updatedPosition = CGPoint(x: center, y: PhysicsConstants.groundBaseline)
        switch slot {
        case .playerA:
            playerAState.position.x = center
            playerAState.position.y = PhysicsConstants.groundBaseline
            latestRollInputs[.playerA] = 0
            balloonBodies[.playerA]?.node?.position = updatedPosition
        case .playerB:
            playerBState.position.x = center
            playerBState.position.y = PhysicsConstants.groundBaseline
            latestRollInputs[.playerB] = 0
            balloonBodies[.playerB]?.node?.position = updatedPosition
        }
    }

    func register(balloonBody: SKPhysicsBody, for slot: PlayerSlot) {
        balloonBodies[slot] = balloonBody
        balloonBody.affectedByGravity = true
        balloonBody.allowsRotation = false
        balloonBody.linearDamping = PhysicsConstants.dragCoefficient
        balloonBody.friction = 0.2
        balloonBody.restitution = 0.2

        if let center = laneCenters[slot] {
            balloonBody.node?.position.x = center
            balloonBody.node?.position.y = PhysicsConstants.groundBaseline
        }
    }

    func registerCloudData(_ data: [CloudData], for lane: PlayerSlot) {
        cloudDataStore.removeAll { cloudLane(for: $0.id) == lane }
        cloudDataStore.append(contentsOf: data)
        refreshCloudSystem()
    }

    func handleGroundContact(for slot: PlayerSlot) {
        guard let body = balloonBodies[slot] else { return }
        var velocity = body.velocity
        velocity.dy = 0
        body.velocity = velocity
        latestForceInputs[slot] = 0
        latestRollInputs[slot] = 0

        switch slot {
        case .playerA:
            playerAState.velocity.dy = 0
            body.node?.position.y = max(body.node?.position.y ?? 0, PhysicsConstants.groundBaseline)
        case .playerB:
            playerBState.velocity.dy = 0
            body.node?.position.y = max(body.node?.position.y ?? 0, PhysicsConstants.groundBaseline)
        }

        updateStatesFromPhysics()
    }

    private func applyHorizontalMovement(deltaTime: TimeInterval, usingPhysicsBodies: Bool) {
        guard !laneCenters.isEmpty else { return }
        let dt = CGFloat(deltaTime)

        if usingPhysicsBodies {
            if let center = laneCenters[.playerA],
               let halfWidth = laneHalfWidths[.playerA],
               let body = balloonBodies[.playerA],
               let node = body.node {
                let normalized = CGFloat(latestRollInputs[.playerA] ?? 0)
                let targetDx = normalized * PhysicsConstants.horizontalSpeed
                var velocity = body.velocity
                velocity.dx = targetDx
                body.velocity = velocity

                let range = (center - halfWidth)...(center + halfWidth)
                node.position.x = clamp(node.position.x, to: range)
            }

            if let center = laneCenters[.playerB],
               let halfWidth = laneHalfWidths[.playerB],
               let body = balloonBodies[.playerB],
               let node = body.node {
                let normalized = CGFloat(latestRollInputs[.playerB] ?? 0)
                let targetDx = normalized * PhysicsConstants.horizontalSpeed
                var velocity = body.velocity
                velocity.dx = targetDx
                body.velocity = velocity

                let range = (center - halfWidth)...(center + halfWidth)
                node.position.x = clamp(node.position.x, to: range)
            }
        } else {
            if let center = laneCenters[.playerA],
               let halfWidth = laneHalfWidths[.playerA] {
                let normalized = CGFloat(latestRollInputs[.playerA] ?? 0)
                playerAState.velocity.dx = normalized * PhysicsConstants.horizontalSpeed
                playerAState.position.x += playerAState.velocity.dx * dt
                let range = (center - halfWidth)...(center + halfWidth)
                playerAState.position.x = clamp(playerAState.position.x, to: range)
            }

            if let center = laneCenters[.playerB],
               let halfWidth = laneHalfWidths[.playerB] {
                let normalized = CGFloat(latestRollInputs[.playerB] ?? 0)
                playerBState.velocity.dx = normalized * PhysicsConstants.horizontalSpeed
                playerBState.position.x += playerBState.velocity.dx * dt
                let range = (center - halfWidth)...(center + halfWidth)
                playerBState.position.x = clamp(playerBState.position.x, to: range)
            }
        }
    }

    private func clamp(_ value: CGFloat, to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func updateStatesFromPhysics() {
        if let body = balloonBodies[.playerA],
           let node = body.node {
            playerAState.position = node.position
            playerAState.velocity = body.velocity
            let relativeY = node.position.y - PhysicsConstants.groundBaseline
            playerAState.altitude = max(0, relativeY / 10.0)
        }

        if let body = balloonBodies[.playerB],
           let node = body.node {
            playerBState.position = node.position
            playerBState.velocity = body.velocity
            let relativeY = node.position.y - PhysicsConstants.groundBaseline
            playerBState.altitude = max(0, relativeY / 10.0)
        }
    }

    private func refreshCloudSystem() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(CloudConfigPayload(clouds: cloudDataStore))
            if let jsonString = String(data: data, encoding: .utf8) {
                try cloudSystem.loadClouds(from: jsonString)
            }
        } catch {
            print("❌ Failed to refresh cloud system: \(error)")
        }
    }

    private func cloudLane(for cloudId: Int) -> PlayerSlot? {
        if cloudId >= 2000 {
            return .playerB
        } else if cloudId >= 1000 {
            return .playerA
        } else if cloudId >= 101 {
            return .playerB
        } else if cloudId >= 1 {
            return .playerA
        } else {
            return nil
        }
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
                if let body = balloonBodies[.playerA] {
                    var velocity = body.velocity
                    velocity.dy = CGFloat(playerAState.velocity.dy)
                    velocity.dx = 0
                    body.velocity = velocity
                }
            case .playerB:
                playerBState.velocity.dy = -abs(playerBState.velocity.dy) * 0.5
                playerBState.velocity.dx = 0
                if let body = balloonBodies[.playerB] {
                    var velocity = body.velocity
                    velocity.dy = CGFloat(playerBState.velocity.dy)
                    velocity.dx = 0
                    body.velocity = velocity
                }
            }

        case .lightning:
            // 風船破裂
            switch player {
            case .playerA:
                balloonPhysics.popBalloon(state: &playerAState)
                playerAState.velocity.dx = 0
                if let body = balloonBodies[.playerA] {
                    var velocity = body.velocity
                    velocity.dy = PhysicsConstants.lightningDamage
                    velocity.dx = 0
                    body.velocity = velocity
                }
            case .playerB:
                balloonPhysics.popBalloon(state: &playerBState)
                playerBState.velocity.dx = 0
                if let body = balloonBodies[.playerB] {
                    var velocity = body.velocity
                    velocity.dy = PhysicsConstants.lightningDamage
                    velocity.dx = 0
                    body.velocity = velocity
                }
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
                            self.balloonBodies[.playerA]?.node?.position.x = center
                            self.balloonBodies[.playerA]?.node?.position.y = 100
                            self.balloonBodies[.playerA]?.velocity = .zero
                        }
                    case .playerB:
                        self.balloonPhysics.respawnBalloon(state: &self.playerBState)
                        if let center = self.laneCenters[.playerB] {
                            self.playerBState.position.x = center
                            self.balloonBodies[.playerB]?.node?.position.x = center
                            self.balloonBodies[.playerB]?.node?.position.y = 100
                            self.balloonBodies[.playerB]?.velocity = .zero
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
