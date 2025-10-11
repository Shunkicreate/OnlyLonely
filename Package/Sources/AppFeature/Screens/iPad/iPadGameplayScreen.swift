//
//  GameplayScreen.swift
//  OnlyLonely
//
//  04. ゲームプレイ画面（iPad）
//  iPad のみ（横向き推奨）
//

import SwiftUI
import SpriteKit

struct iPadGameplayScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject private var sessionManager: P2PSessionManager
    @StateObject private var gameManager = GameManager()
    @StateObject private var physicsCoordinator = GamePhysicsCoordinator()
    @StateObject private var screenModel: iPadGameplayScreenModel
    @EnvironmentObject private var resultStore: GameResultStore

    @State private var playerAAltitude: Double = 0
    @State private var playerBAltitude: Double = 0
    @State private var playerAScene = PlayerLaneScene(lane: .playerA)
    @State private var playerBScene = PlayerLaneScene(lane: .playerB)
    @State private var hasBroadcastGameFinished = false

    init() {
        _screenModel = StateObject(wrappedValue: iPadGameplayScreenModel())
    }

    var body: some View {
        GeometryReader { geometry in
            let laneSize = CGSize(width: geometry.size.width / 2, height: geometry.size.height)
            ZStack {
                HStack(spacing: 0) {
                    SpriteView(scene: playerAScene, options: [.allowsTransparency])
                        .frame(width: laneSize.width, height: laneSize.height)
                        .onAppear {
                            playerAScene.configure(
                                size: laneSize,
                                lane: .playerA,
                                physicsCoordinator: physicsCoordinator
                            )
                        }

                    SpriteView(scene: playerBScene, options: [.allowsTransparency])
                        .frame(width: laneSize.width, height: laneSize.height)
                        .onAppear {
                            playerBScene.configure(
                                size: laneSize,
                                lane: .playerB,
                                physicsCoordinator: physicsCoordinator
                            )
                        }
                }
                .ignoresSafeArea()
                .onChange(of: geometry.size) { newSize in
                    let lane = CGSize(width: newSize.width / 2, height: newSize.height)
                    playerAScene.configure(size: lane, lane: .playerA, physicsCoordinator: physicsCoordinator)
                    playerBScene.configure(size: lane, lane: .playerB, physicsCoordinator: physicsCoordinator)
                }

                // UI Overlay
                VStack {
                    // 残り時間
                    HStack {
                        Spacer()
                        Text("残り時間: \(gameManager.timeRemaining)秒")
                            .nikumaruHeadline(size: 24)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.3))
                            )
                        Spacer()
                    }
                    .padding(.top, 20)

                    Spacer()

                    // プレイヤー情報
                    HStack(spacing: 0) {
                        PlayerInfoPanel(
                            playerName: screenModel.displayName(for: .playerA),
                            altitude: playerAAltitude,
                            color: .red
                        )
                        .frame(width: geometry.size.width / 2)

                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2)

                        PlayerInfoPanel(
                            playerName: screenModel.displayName(for: .playerB),
                            altitude: playerBAltitude,
                            color: .blue
                        )
                        .frame(width: geometry.size.width / 2)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            screenModel.configure(sessionManager: sessionManager, physicsCoordinator: physicsCoordinator)
            hasBroadcastGameFinished = false
            resultStore.reset()
            gameManager.startGame()
        }
        .onDisappear {
            screenModel.cancelSubscriptions()
        }
        .onChange(of: gameManager.gamePhase) { _, newPhase in
            if newPhase == .finished {
                let finalAltitudeA = physicsCoordinator.playerAState.altitude
                let finalAltitudeB = physicsCoordinator.playerBState.altitude
                resultStore.updateResults(
                    playerAAltitude: finalAltitudeA,
                    playerBAltitude: finalAltitudeB,
                    timestamp: Date()
                )

                if !hasBroadcastGameFinished {
                    hasBroadcastGameFinished = true
                    let event = GameEventMessage(type: .gameFinished, timestamp: Date())
                    sessionManager.sendGameEvent(event)
                }
                coordinator.navigate(to: .iPadResult)
            }
        }
        .onChange(of: physicsCoordinator.playerAState.altitude) { _, newAltitude in
            playerAAltitude = newAltitude
        }
        .onChange(of: physicsCoordinator.playerBState.altitude) { _, newAltitude in
            playerBAltitude = newAltitude
        }
        .navigationBarBackButtonHidden()
    }

}

struct PlayerInfoPanel: View {
    let playerName: String
    let altitude: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(playerName)
                .nikumaruBody(size: 20)
                .foregroundColor(.white)

            Text("高度: \(Int(altitude))m")
                .nikumaruBody(size: 18)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - SpriteKit Game Scene

private enum PhysicsCategory {
    static let balloonA: UInt32 = 1 << 0
    static let balloonB: UInt32 = 1 << 1
    static let ground: UInt32 = 1 << 2
}

final class PlayerLaneScene: SKScene, SKPhysicsContactDelegate {
    private let lane: PlayerSlot
    private weak var physicsCoordinator: GamePhysicsCoordinator?
    private var balloon: SKSpriteNode?
    private var clouds: [Int: SKNode] = [:]
    private var lightningNodes: [Int: SKNode] = [:]
    private var cameraNode = SKCameraNode()
    private var isSceneConfigured = false
    private var lastConfiguredSize: CGSize = .zero

    init(lane: PlayerSlot) {
        self.lane = lane
        super.init(size: .zero)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(size: CGSize, lane: PlayerSlot, physicsCoordinator: GamePhysicsCoordinator) {
        guard lane == self.lane else { return }

        let expandedHeight = max(size.height * 2.5, size.height + 600)
        let targetSize = CGSize(width: size.width, height: expandedHeight)
        if targetSize != self.size {
            self.size = targetSize
        }
        self.physicsCoordinator = physicsCoordinator

        physicsWorld.gravity = CGVector(dx: 0, dy: PhysicsConstants.gravity)
        physicsWorld.contactDelegate = self

        if !isSceneConfigured || lastConfiguredSize != targetSize {
            lastConfiguredSize = targetSize
            isSceneConfigured = false
        }

        if !isSceneConfigured {
            setupScene()
            isSceneConfigured = true
        }

        physicsCoordinator.configureLaneBounds(for: lane, sceneSize: self.size)
        loadClouds()
        updateCameraPosition()
    }

    private func setupScene() {
        removeAllChildren()
        clouds.removeAll()
        lightningNodes.removeAll()

        cameraNode = SKCameraNode()
        addChild(cameraNode)
        camera = cameraNode

        addBackground()
        addGround()
        addBalloon()
    }

    private func addBackground() {
        let backgroundHeight = size.height
        let background = SKSpriteNode(color: .clear, size: CGSize(width: size.width, height: backgroundHeight))
        background.anchorPoint = CGPoint(x: 0.5, y: 0)
        background.position = CGPoint(x: size.width / 2, y: 0)
        background.zPosition = -5
        addChild(background)

        let skyTop = SKSpriteNode(
            color: UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0),
            size: CGSize(width: size.width, height: backgroundHeight)
        )
        skyTop.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        skyTop.position = CGPoint(x: size.width / 2, y: backgroundHeight)
        skyTop.zPosition = -6
        addChild(skyTop)
    }

    private func addGround() {
        let groundHeight: CGFloat = 60

        let soilHeight = groundHeight + 120
        let soil = SKSpriteNode(color: UIColor(red: 0.55, green: 0.37, blue: 0.2, alpha: 1.0), size: CGSize(width: size.width, height: soilHeight))
        soil.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        soil.position = CGPoint(x: size.width / 2, y: PhysicsConstants.groundBaseline - groundHeight / 2)
        soil.zPosition = -1
        addChild(soil)

        let ground = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width, height: groundHeight))
        ground.position = CGPoint(
            x: size.width / 2,
            y: PhysicsConstants.groundBaseline - groundHeight / 2
        )
        ground.zPosition = 0
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.balloonA | PhysicsCategory.balloonB
        ground.physicsBody?.collisionBitMask = PhysicsCategory.balloonA | PhysicsCategory.balloonB
        ground.physicsBody?.restitution = 0
        ground.physicsBody?.friction = 1.0
        addChild(ground)
    }

    private func addBalloon() {
        let color: UIColor = lane == .playerA ? .red : .blue
        let balloonNode = createBalloon(color: color)
        balloonNode.position = CGPoint(x: size.width / 2, y: PhysicsConstants.groundBaseline)
        balloonNode.zPosition = 10
        let body = SKPhysicsBody(circleOfRadius: 30)
        body.categoryBitMask = lane == .playerA ? PhysicsCategory.balloonA : PhysicsCategory.balloonB
        body.contactTestBitMask = PhysicsCategory.ground
        body.collisionBitMask = PhysicsCategory.ground
        body.mass = PhysicsConstants.childMass
        body.linearDamping = PhysicsConstants.dragCoefficient
        body.allowsRotation = false
        body.affectedByGravity = true
        body.usesPreciseCollisionDetection = true
        body.velocity = .zero
        balloonNode.physicsBody = body
        addChild(balloonNode)
        balloon = balloonNode
        physicsCoordinator?.register(balloonBody: body, for: lane)
    }

    private func loadClouds() {
        guard let physicsCoordinator else { return }
        for node in clouds.values { node.removeFromParent() }
        clouds.removeAll()
        clouds = CloudLoader.loadLaneClouds(
            lane: lane,
            laneSize: size,
            cloudsPerLane: 6,
            physicsCoordinator: physicsCoordinator,
            scene: self
        )
    }

    private func updateCameraPosition() {
        guard let balloon else { return }
        let targetY = max(balloon.position.y, PhysicsConstants.groundBaseline + size.height * 0.2)
        cameraNode.position = CGPoint(x: size.width / 2, y: targetY)
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        if lane == .playerA || physicsCoordinator?.usesSpriteKitPhysics != true {
            physicsCoordinator?.update(currentTime: currentTime)
        }

        updateCameraPosition()

        guard let coordinator = physicsCoordinator, let balloon = balloon else { return }
        let playerId = lane == .playerA ? "A" : "B"
        let state = lane == .playerA ? coordinator.playerAState : coordinator.playerBState

        CloudCollisionDetector.checkBalloonCloudCollision(
            balloon: balloon,
            playerId: playerId,
            balloonPosition: balloon.position,
            balloonVelocity: state.velocity,
            physicsCoordinator: coordinator,
            clouds: clouds,
            lightningNodes: &lightningNodes,
            scene: self
        )
    }

    func didBegin(_ contact: SKPhysicsContact) {
        handleContact(contact.bodyA, contact.bodyB)
    }

    private func handleContact(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        let categories = (bodyA.categoryBitMask, bodyB.categoryBitMask)

        switch categories {
        case (PhysicsCategory.balloonA, PhysicsCategory.ground),
             (PhysicsCategory.ground, PhysicsCategory.balloonA):
            physicsCoordinator?.handleGroundContact(for: .playerA)
        case (PhysicsCategory.balloonB, PhysicsCategory.ground),
             (PhysicsCategory.ground, PhysicsCategory.balloonB):
            physicsCoordinator?.handleGroundContact(for: .playerB)
        default:
            break
        }
    }

    private func createBalloon(color: UIColor) -> SKSpriteNode {
        let container = SKSpriteNode(color: .clear, size: CGSize(width: 60, height: 80))
        container.name = "balloon"

        let emojiLabel = SKLabelNode(text: "🎈")
        emojiLabel.fontSize = 60
        emojiLabel.verticalAlignmentMode = .center
        emojiLabel.position = CGPoint(x: 0, y: 0)
        container.addChild(emojiLabel)

        let colorCircle = SKShapeNode(circleOfRadius: 10)
        colorCircle.fillColor = color
        colorCircle.strokeColor = .clear
        colorCircle.position = CGPoint(x: 0, y: -30)
        colorCircle.zPosition = -1
        container.addChild(colorCircle)

        return container
    }
}

#Preview {
    iPadGameplayScreen()
        .environmentObject(AppCoordinator())
        .environmentObject(P2PSessionManager())
        .environmentObject(GameResultStore())
}
