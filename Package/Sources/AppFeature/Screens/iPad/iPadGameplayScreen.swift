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
    @EnvironmentObject private var characterManager: CharacterAssignmentManager
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

    @State private var sparkleRotation: Double = 0
    @State private var cloudOffsets: [CGFloat] = Array(repeating: 0, count: 8)

    var body: some View {
        GeometryReader { geometry in
            let laneSize = CGSize(width: geometry.size.width / 2, height: geometry.size.height)
            ZStack {
                // スカイブルー→宇宙グラデーション背景
                LinearGradient(
                    colors: [
                        Color(hex: "#87CEEB"),
                        Color(hex: "#B4D4FF"),
                        Color(hex: "#FFE5B3"),
                        Color(hex: "#FFD4E5")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // ふわふわ雲（背景装飾として8個配置）
                ForEach(0..<8, id: \.self) { index in
                    FloatingCloud(
                        index: index,
                        screenWidth: geometry.size.width,
                        screenHeight: geometry.size.height,
                        offset: cloudOffsets[index]
                    )
                }

                // 各プレイヤー用レーン
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
                ZStack {
                    // メインUI
                    VStack {
                        // 残り時間（3D効果）
                        HStack {
                            Spacer()

                            ZStack {
                                // グロー効果
                                Text("のこり \(gameManager.timeRemaining)びょう")
                                    .nikumaruHeadline(size: 28)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#FFD700"),
                                                Color(hex: "#FFA500")
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .blur(radius: 8)
                                    .offset(y: 2)

                                // メインテキスト
                                Text("のこり \(gameManager.timeRemaining)びょう")
                                    .nikumaruHeadline(size: 28)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#FFFFFF"),
                                                Color(hex: "#FFF9E5")
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#FFD700").opacity(0.6),
                                                        Color(hex: "#FFA500").opacity(0.6)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                            )
                            .shadow(color: Color(hex: "#FFD700").opacity(0.4), radius: 12, x: 0, y: 4)

                            Spacer()
                        }
                        .padding(.top, 20)

                        Spacer()
                    }

                    // プレイヤーごとの高度表示（左端に配置）
                    HStack(spacing: 0) {
                        // Player A の高度（左端）
                        VStack {
                            Spacer()
                            AltitudeLabel(
                                altitude: playerAAltitude,
                                character: characterManager.character(for: "A")
                            )
                            .padding(.leading, 20)
                            .padding(.bottom, 40)
                        }
                        .frame(width: geometry.size.width / 2, alignment: .leading)

                        // Player B の高度（左端）
                        VStack {
                            Spacer()
                            AltitudeLabel(
                                altitude: playerBAltitude,
                                character: characterManager.character(for: "B")
                            )
                            .padding(.leading, 20)
                            .padding(.bottom, 40)
                        }
                        .frame(width: geometry.size.width / 2, alignment: .leading)
                    }
                }
            }
        }
        .onAppear {
            startDecorationAnimations()
        }
        .onAppear {
            screenModel.configure(sessionManager: sessionManager, physicsCoordinator: physicsCoordinator)
            hasBroadcastGameFinished = false
            resultStore.reset()
            gameManager.startGame()
            // TODO: 雲データ読み込み
            // try? physicsCoordinator.loadCloudData(json: "...")
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

    private func startDecorationAnimations() {
        // 雲のふわふわアニメーション
        for i in 0..<8 {
            let delay = Double(i) * 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 4.0...6.0))
                        .repeatForever(autoreverses: true)
                ) {
                    cloudOffsets[i] = CGFloat.random(in: -20...20)
                }
            }
        }

        // キラキラ回転
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
    }
}

// MARK: - Harajuku Style Components

struct FluffyPlayerPanel: View {
    let playerName: String
    let altitude: Double
    let balloonImage: String
    let gradient: LinearGradient
    let glowColor: Color

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 12) {
            // 風船アイコン（Assets画像 + グロー）
            ZStack {
                // グロー効果
                Circle()
                    .fill(glowColor.opacity(0.5))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)

                // Assets画像
                Image(balloonImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            .scaleEffect(pulseScale)

            // プレイヤー名（3D効果）
            ZStack {
                // 影
                Text(playerName)
                    .nikumaruHeadline(size: 20)
                    .foregroundColor(.black.opacity(0.3))
                    .offset(y: 2)

                // メインテキスト
                Text(playerName)
                    .nikumaruHeadline(size: 20)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            // 高度表示（3D効果）
            VStack(spacing: 4) {
                ZStack {
                    // グロー
                    Text("\(Int(altitude))")
                        .nikumaruTitle(size: 36)
                        .foregroundStyle(gradient)
                        .blur(radius: 4)

                    // メインテキスト
                    Text("\(Int(altitude))")
                        .nikumaruTitle(size: 36)
                        .foregroundStyle(gradient)
                }

                Text("メートル")
                    .nikumaruCaption(size: 14)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(gradient, lineWidth: 2)
                )
        )
        .shadow(color: glowColor.opacity(0.3), radius: 12, x: 0, y: 4)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.15
            }
        }
    }
}

struct FloatingCloud: View {
    let index: Int
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let offset: CGFloat

    @State private var swayX: CGFloat = 0
    @State private var swayY: CGFloat = 0
    @State private var scale: CGFloat = 1.0

    // 雲の配置データ（8個を画面全体に分散）
    private let cloudPositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.15, 0.15, 80),   // 左上
        (0.75, 0.2, 100),   // 右上
        (0.25, 0.35, 70),   // 左上中央
        (0.85, 0.45, 90),   // 右中央
        (0.1, 0.6, 85),     // 左下中央
        (0.6, 0.65, 75),    // 右下中央
        (0.3, 0.8, 95),     // 左下
        (0.8, 0.85, 80)     // 右下
    ]

    var body: some View {
        let position = cloudPositions[index]

        Image("kumo")
            .resizable()
            .scaledToFit()
            .frame(width: position.size, height: position.size)
            .opacity(0.6)
            .scaleEffect(scale)
            .position(
                x: screenWidth * position.x + swayX,
                y: screenHeight * position.y + swayY + offset
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: Double.random(in: 3.0...5.0))
                        .repeatForever(autoreverses: true)
                ) {
                    swayX = CGFloat.random(in: -30...30)
                    swayY = CGFloat.random(in: -20...20)
                    scale = CGFloat.random(in: 0.9...1.1)
                }
            }
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
        addClouds()
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
        let balloonNode = createBalloon(for: lane)
        balloonNode.position = CGPoint(x: size.width / 2, y: PhysicsConstants.groundBaseline + 50)
        balloonNode.zPosition = 10
        // 物理ボディは風船部分のサイズに合わせる（コンテナ全体ではなく）
        let body = SKPhysicsBody(circleOfRadius: 40)
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

    private func addClouds() {
        // レーン用の雲を追加
        clouds = CloudLoader.loadCloudsForLane(
            sceneSize: size,
            cloudCount: 8,  // 各レーンに8個の雲を配置
            lane: lane,
            physicsCoordinator: physicsCoordinator,
            scene: self
        )
    }

    private func updateCameraPosition() {
        guard let balloon else { return }
        let targetY = max(balloon.position.y, PhysicsConstants.groundBaseline + size.height * 0.2)
        cameraNode.position = CGPoint(x: size.width / 2, y: targetY)
    }

    private func createBalloon(for lane: PlayerSlot) -> SKSpriteNode {
        let imageName: String
        let glowColor: UIColor
        let balloonColor: UIColor

        switch lane {
        case .playerA:
            imageName = "red"
            glowColor = UIColor(red: 1.0, green: 0.42, blue: 0.62, alpha: 1.0)
            balloonColor = UIColor(red: 1.0, green: 0.42, blue: 0.62, alpha: 1.0)
        case .playerB:
            imageName = "blue"
            glowColor = UIColor(red: 0.29, green: 0.56, blue: 0.87, alpha: 1.0)
            balloonColor = UIColor(red: 0.29, green: 0.56, blue: 0.87, alpha: 1.0)
        }

        // コンテナノード（全体を1つのノードとして扱う）
        let container = SKSpriteNode(color: .clear, size: CGSize(width: 100, height: 180))
        container.name = "balloon"

        // 風船本体（円形グラデーション風）
        let balloonCircle = SKShapeNode(circleOfRadius: 30)
        balloonCircle.fillColor = balloonColor.withAlphaComponent(0.8)
        balloonCircle.strokeColor = .clear
        balloonCircle.position = CGPoint(x: 0, y: 60)
        balloonCircle.zPosition = 0
        container.addChild(balloonCircle)

        // ハイライト
        let highlight = SKShapeNode(circleOfRadius: 12)
        highlight.fillColor = .white.withAlphaComponent(0.6)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -8, y: 68)
        highlight.zPosition = 1
        container.addChild(highlight)

        // 紐（曲線）
        let stringPath = CGMutablePath()
        stringPath.move(to: CGPoint(x: 0, y: 30))
        stringPath.addQuadCurve(
            to: CGPoint(x: 0, y: -10),
            control: CGPoint(x: 5, y: 10)
        )
        let stringNode = SKShapeNode(path: stringPath)
        stringNode.strokeColor = balloonColor.withAlphaComponent(0.7)
        stringNode.lineWidth = 3
        stringNode.zPosition = 0
        container.addChild(stringNode)

        // キャラクター画像（下部）
        let characterTexture = SKTexture(imageNamed: imageName)
        let characterImage = SKSpriteNode(texture: characterTexture, size: CGSize(width: 72, height: 72))
        characterImage.position = CGPoint(x: 0, y: -25)
        characterImage.zPosition = 3
        container.addChild(characterImage)

        return container
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

}

// MARK: - UI Components

/// 高度ラベル（画面左端に配置）
struct AltitudeLabel: View {
    let altitude: Double
    let character: CharacterInfo

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: character.color),
                Color(hex: character.color).opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // 表示用の高度（0mから始まるように4を引く）
    private var displayAltitude: Int {
        max(0, Int(altitude) - 4)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            // 数値
            ZStack {
                // 4方向黒枠
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 56)
                    .foregroundColor(.black)
                    .offset(x: -2, y: -2)
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 56)
                    .foregroundColor(.black)
                    .offset(x: 2, y: -2)
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 56)
                    .foregroundColor(.black)
                    .offset(x: -2, y: 2)
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 56)
                    .foregroundColor(.black)
                    .offset(x: 2, y: 2)

                // グロー
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 56)
                    .foregroundStyle(gradient)
                    .blur(radius: 5)

                // メインテキスト
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 56)
                    .foregroundStyle(gradient)
            }

            // 「m」を数値の右側に配置
            ZStack {
                // 黒枠
                Text("m")
                    .nikumaruBody(size: 24)
                    .foregroundColor(.black)
                    .offset(x: -1, y: -1)
                Text("m")
                    .nikumaruBody(size: 24)
                    .foregroundColor(.black)
                    .offset(x: 1, y: 1)

                // メインテキスト
                Text("m")
                    .nikumaruBody(size: 24)
                    .foregroundColor(.white)
            }
            .offset(x: 0, y: -6)
        }
    }
}

#Preview {
    iPadGameplayScreen()
        .environmentObject(AppCoordinator())
        .environmentObject(P2PSessionManager())
        .environmentObject(GameResultStore())
}
