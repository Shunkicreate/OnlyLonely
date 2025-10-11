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

    @State private var playerAAltitude: Double = 0
    @State private var playerBAltitude: Double = 0
    @State private var hasBroadcastGameFinished = false

    init() {
        _screenModel = StateObject(wrappedValue: iPadGameplayScreenModel())
    }

    @State private var sparkleRotation: Double = 0
    @State private var cloudOffsets: [CGFloat] = Array(repeating: 0, count: 8)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // スカイブルー→宇宙グラデーション背景
                LinearGradient(
                    colors: [
                        Color(hex: "#87CEEB"),   // スカイブルー
                        Color(hex: "#B4D4FF"),   // 明るいブルー
                        Color(hex: "#FFE5B3"),   // はちみつイエロー
                        Color(hex: "#FFD4E5")    // パステルピンク
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

                // SpriteKit Scene
                SpriteView(
                    scene: createGameScene(size: geometry.size),
                    options: [.allowsTransparency]
                )
                .ignoresSafeArea()

                // UI Overlay
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

                    // プレイヤー情報（Harajukuスタイル）
                    HStack(spacing: 0) {
                        // Player A
                        FluffyPlayerPanel(
                            playerName: screenModel.displayName(for: .playerA),
                            altitude: playerAAltitude,
                            balloonImage: "red",
                            gradient: LinearGradient(
                                colors: [
                                    Color(hex: "#FF6B9D"),
                                    Color(hex: "#FF8FB3")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            glowColor: Color(hex: "#FF6B9D")
                        )
                        .frame(width: geometry.size.width / 2)

                        // Divider（キラキラ）
                        VStack(spacing: 8) {
                            ForEach(0..<5, id: \.self) { index in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#FFFFFF").opacity(0.8),
                                                Color(hex: "#FFE5B3").opacity(0.6)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 8, height: 8)
                                    .shadow(color: .white.opacity(0.6), radius: 4)
                            }
                        }
                        .frame(width: 2)

                        // Player B
                        FluffyPlayerPanel(
                            playerName: screenModel.displayName(for: .playerB),
                            altitude: playerBAltitude,
                            balloonImage: "blue",
                            gradient: LinearGradient(
                                colors: [
                                    Color(hex: "#4A90E2"),
                                    Color(hex: "#6BBFFF")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            glowColor: Color(hex: "#4A90E2")
                        )
                        .frame(width: geometry.size.width / 2)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            startDecorationAnimations()
        }
        .onAppear {
            screenModel.configure(sessionManager: sessionManager, physicsCoordinator: physicsCoordinator)
            hasBroadcastGameFinished = false
            gameManager.startGame()
            // TODO: 雲データ読み込み
            // try? physicsCoordinator.loadCloudData(json: "...")
        }
        .onDisappear {
            screenModel.cancelSubscriptions()
        }
        .onChange(of: gameManager.gamePhase) { _, newPhase in
            if newPhase == .finished {
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

    private func createGameScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size, physicsCoordinator: physicsCoordinator)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .clear
        return scene
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

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var balloonA: SKSpriteNode!
    private var balloonB: SKSpriteNode!
    private var clouds: [Int: SKNode] = [:]  // cloudId -> SKNode
    private var lightningNodes: [Int: SKNode] = [:]  // cloudId -> 雷エフェクト

    // 物理エンジンへの参照（弱参照で保持）
    private weak var physicsCoordinator: GamePhysicsCoordinator?

    init(size: CGSize, physicsCoordinator: GamePhysicsCoordinator) {
        self.physicsCoordinator = physicsCoordinator
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        setupScene()
        clouds = CloudLoader.loadRandomClouds(
            sceneSize: size,
            cloudsPerPlayer: 10,
            physicsCoordinator: physicsCoordinator,
            scene: self
        )
    }

    private func setupScene() {
        physicsWorld.gravity = CGVector(dx: 0, dy: PhysicsConstants.gravity)
        physicsWorld.contactDelegate = self

        // 背景は透明（SwiftUIのグラデーションを使用）
        physicsCoordinator?.configureHorizontalBounds(sceneSize: size)

        // 中央の分割線
        let divider = SKSpriteNode(color: .white.withAlphaComponent(0.3), size: CGSize(width: 2, height: size.height))
        divider.position = CGPoint(x: size.width / 2, y: size.height / 2)
        divider.zPosition = 1
        addChild(divider)

        // Player A の風船（左側・赤）
        balloonA = createBalloon(color: .red)
        balloonA.position = CGPoint(x: size.width / 4, y: 100)
        balloonA.zPosition = 10 // 前面に表示
        balloonA.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        balloonA.physicsBody?.categoryBitMask = PhysicsCategory.balloonA
        balloonA.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        balloonA.physicsBody?.collisionBitMask = PhysicsCategory.ground
        balloonA.physicsBody?.mass = PhysicsConstants.childMass
        balloonA.physicsBody?.linearDamping = PhysicsConstants.dragCoefficient
        balloonA.physicsBody?.allowsRotation = false
        balloonA.physicsBody?.usesPreciseCollisionDetection = true
        balloonA.physicsBody?.affectedByGravity = true
        balloonA.physicsBody?.velocity = .zero
        addChild(balloonA)

        // Player B の風船（右側・青）
        balloonB = createBalloon(color: .blue)
        balloonB.position = CGPoint(x: size.width * 3 / 4, y: 100)
        balloonB.zPosition = 10 // 前面に表示
        balloonB.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        balloonB.physicsBody?.categoryBitMask = PhysicsCategory.balloonB
        balloonB.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        balloonB.physicsBody?.collisionBitMask = PhysicsCategory.ground
        balloonB.physicsBody?.mass = PhysicsConstants.childMass
        balloonB.physicsBody?.linearDamping = PhysicsConstants.dragCoefficient
        balloonB.physicsBody?.allowsRotation = false
        balloonB.physicsBody?.usesPreciseCollisionDetection = true
        balloonB.physicsBody?.affectedByGravity = true
        balloonB.physicsBody?.velocity = .zero
        addChild(balloonB)

        // 物理エンジンに初期位置を設定
        if let coordinator = physicsCoordinator {
            let centerA = coordinator.laneCenter(for: .playerA) ?? size.width / 4
            let centerB = coordinator.laneCenter(for: .playerB) ?? size.width * 3 / 4
            coordinator.playerAState.position = CGPoint(x: centerA, y: 100)
            coordinator.playerBState.position = CGPoint(x: centerB, y: 100)
            if let bodyA = balloonA.physicsBody {
                coordinator.register(balloonBody: bodyA, for: .playerA)
            }
            if let bodyB = balloonB.physicsBody {
                coordinator.register(balloonBody: bodyB, for: .playerB)
            }
        }

        // 地面
        let groundLeft = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width / 2, height: 50))
        groundLeft.position = CGPoint(x: size.width / 4, y: 25)
        groundLeft.zPosition = 0
        groundLeft.physicsBody = SKPhysicsBody(rectangleOf: groundLeft.size)
        groundLeft.physicsBody?.isDynamic = false
        groundLeft.physicsBody?.categoryBitMask = PhysicsCategory.ground
        groundLeft.physicsBody?.contactTestBitMask = PhysicsCategory.balloonA | PhysicsCategory.balloonB
        groundLeft.physicsBody?.collisionBitMask = PhysicsCategory.balloonA | PhysicsCategory.balloonB
        groundLeft.physicsBody?.restitution = 0
        groundLeft.physicsBody?.friction = 1.0
        addChild(groundLeft)

        let groundRight = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width / 2, height: 50))
        groundRight.position = CGPoint(x: size.width * 3 / 4, y: 25)
        groundRight.zPosition = 0
        groundRight.physicsBody = SKPhysicsBody(rectangleOf: groundRight.size)
        groundRight.physicsBody?.isDynamic = false
        groundRight.physicsBody?.categoryBitMask = PhysicsCategory.ground
        groundRight.physicsBody?.contactTestBitMask = PhysicsCategory.balloonA | PhysicsCategory.balloonB
        groundRight.physicsBody?.collisionBitMask = PhysicsCategory.balloonA | PhysicsCategory.balloonB
        groundRight.physicsBody?.restitution = 0
        groundRight.physicsBody?.friction = 1.0
        addChild(groundRight)
    }

    private func createBalloon(color: UIColor) -> SKSpriteNode {
        // Assets画像を使った風船
        let imageName = (color == .red) ? "red" : "blue"

        let balloonTexture = SKTexture(imageNamed: imageName)
        let balloon = SKSpriteNode(texture: balloonTexture, size: CGSize(width: 60, height: 60))
        balloon.name = "balloon"

        // グロー効果（円形の光）
        let glowCircle = SKShapeNode(circleOfRadius: 35)
        glowCircle.fillColor = color.withAlphaComponent(0.3)
        glowCircle.strokeColor = .clear
        glowCircle.zPosition = -1
        balloon.addChild(glowCircle)

        // パルスアニメーション
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        glowCircle.run(SKAction.repeatForever(pulse))

        return balloon
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        // 物理演算を更新
        physicsCoordinator?.update(currentTime: currentTime)

        if physicsCoordinator?.usesSpriteKitPhysics != true {
            if let stateA = physicsCoordinator?.playerAState {
                balloonA.position = stateA.position
            }
            if let stateB = physicsCoordinator?.playerBState {
                balloonB.position = stateB.position
            }
        }

        // 雲との衝突チェック
        guard let coordinator = physicsCoordinator else { return }

        CloudCollisionDetector.checkBalloonCloudCollision(
            balloon: balloonA,
            playerId: "A",
            balloonPosition: balloonA.position,
            balloonVelocity: coordinator.playerAState.velocity,
            physicsCoordinator: coordinator,
            clouds: clouds,
            lightningNodes: &lightningNodes,
            scene: self
        )

        CloudCollisionDetector.checkBalloonCloudCollision(
            balloon: balloonB,
            playerId: "B",
            balloonPosition: balloonB.position,
            balloonVelocity: coordinator.playerBState.velocity,
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

#Preview {
    iPadGameplayScreen()
        .environmentObject(AppCoordinator())
        .environmentObject(P2PSessionManager())
}
