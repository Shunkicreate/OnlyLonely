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
                ZStack(alignment: .bottom) {
                    // 風船とキャラクター（物理演算で動く - 画面下部から上昇）
                    HStack(spacing: 0) {
                        // Player A の風船+キャラクター（左側）
                        BalloonCharacterView(
                            character: characterManager.character(for: "A"),
                            altitude: playerAAltitude
                        )
                        .frame(width: geometry.size.width / 2)

                        // Player B の風船+キャラクター（右側）
                        BalloonCharacterView(
                            character: characterManager.character(for: "B"),
                            altitude: playerBAltitude
                        )
                        .frame(width: geometry.size.width / 2)
                    }
                    .padding(.bottom, 20) // 下部から20pxの位置（緑のスタート地点付近）

                    // UI要素（固定配置）
                    VStack {
                        // 上部エリア：残り時間 + プレイヤー名
                        HStack(alignment: .top, spacing: 0) {
                            // Player A名（左上）
                            PlayerNameLabel(
                                playerName: screenModel.displayName(for: .playerA),
                                character: characterManager.character(for: "A")
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)

                            // 残り時間（中央上）
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

                            // Player B名（右上）
                            PlayerNameLabel(
                                playerName: screenModel.displayName(for: .playerB),
                                character: characterManager.character(for: "B")
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 30)
                        }
                        .padding(.top, 20)

                        Spacer()

                        // 高度表示（下部）
                        HStack(spacing: 0) {
                            AltitudeLabel(
                                altitude: playerAAltitude,
                                character: characterManager.character(for: "A")
                            )
                            .frame(width: geometry.size.width / 2)

                            AltitudeLabel(
                                altitude: playerBAltitude,
                                character: characterManager.character(for: "B")
                            )
                            .frame(width: geometry.size.width / 2)
                        }
                        .padding(.bottom, 20)
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

/// 風船+キャラクター表示（高度に応じて位置が変わる）
struct BalloonCharacterView: View {
    let character: CharacterInfo
    let altitude: Double

    @State private var pulseScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0

    private var glowColor: Color {
        Color(hex: character.color)
    }

    var body: some View {
        VStack(spacing: -10) {
            // 風船（中にキャラクター画像あり）
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                glowColor.opacity(0.9),
                                glowColor
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 28
                        )
                    )
                    .frame(width: 55, height: 55)
                    .overlay(
                        // ハイライト
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.7),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 22, height: 22)
                            .offset(x: -11, y: -11)
                    )
                    .shadow(color: glowColor.opacity(0.4), radius: 10, x: 0, y: 0)

                // 風船の中のキャラクター画像
                Image(character.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
            }
            .scaleEffect(pulseScale)

            // 紐
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 25))
            }
            .stroke(glowColor.opacity(0.7), lineWidth: 2.5)
            .frame(width: 25, height: 25)
        }
        .offset(y: floatOffset)
        // 高度に応じてY位置を調整（画面下部から開始、0mから）
        .offset(y: -CGFloat(max(0, altitude)) * 2) // 高度が上がるほど上に移動
        .onAppear {
            // 風船パルスアニメーション
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.15
            }

            // ふわふわ浮遊アニメーション
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                floatOffset = -25
            }
        }
    }
}

/// Player名ラベル（画面上部固定）
struct PlayerNameLabel: View {
    let playerName: String
    let character: CharacterInfo

    var body: some View {
        ZStack {
            // 4方向黒枠
            Text(playerName)
                .nikumaruHeadline(size: 24)
                .foregroundColor(.black)
                .offset(x: -1, y: -1)
            Text(playerName)
                .nikumaruHeadline(size: 24)
                .foregroundColor(.black)
                .offset(x: 1, y: -1)
            Text(playerName)
                .nikumaruHeadline(size: 24)
                .foregroundColor(.black)
                .offset(x: -1, y: 1)
            Text(playerName)
                .nikumaruHeadline(size: 24)
                .foregroundColor(.black)
                .offset(x: 1, y: 1)

            // メインテキスト
            Text(playerName)
                .nikumaruHeadline(size: 24)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color(hex: character.color).opacity(0.6),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: Color(hex: character.color).opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

/// 高度ラベル（画面下部固定）
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
        HStack(alignment: .bottom, spacing: 0) {
            // 数値
            ZStack {
                // 4方向黒枠
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 42)
                    .foregroundColor(.black)
                    .offset(x: -2, y: -2)
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 42)
                    .foregroundColor(.black)
                    .offset(x: 2, y: -2)
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 42)
                    .foregroundColor(.black)
                    .offset(x: -2, y: 2)
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 42)
                    .foregroundColor(.black)
                    .offset(x: 2, y: 2)

                // グロー
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 42)
                    .foregroundStyle(gradient)
                    .blur(radius: 4)

                // メインテキスト
                Text("\(displayAltitude)")
                    .nikumaruTitle(size: 42)
                    .foregroundStyle(gradient)
            }

            // 「m」を数値の右側に配置
            ZStack {
                // 黒枠
                Text("m")
                    .nikumaruBody(size: 18)
                    .foregroundColor(.black)
                    .offset(x: -1, y: -1)
                Text("m")
                    .nikumaruBody(size: 18)
                    .foregroundColor(.black)
                    .offset(x: 1, y: 1)

                // メインテキスト
                Text("m")
                    .nikumaruBody(size: 18)
                    .foregroundColor(.white)
            }
            .offset(x: 4, y: -4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 30)
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
            cloudsPerPlayer: 20,  // 各プレイヤーエリアに20個ずつ、合計40個
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

        // 物理エンジンに初期位置を設定（groundBaselineから開始して0mからスタート）
        if let coordinator = physicsCoordinator {
            let centerA = coordinator.laneCenter(for: .playerA) ?? size.width / 4
            let centerB = coordinator.laneCenter(for: .playerB) ?? size.width * 3 / 4
            coordinator.playerAState.position = CGPoint(x: centerA, y: PhysicsConstants.groundBaseline)
            coordinator.playerBState.position = CGPoint(x: centerB, y: PhysicsConstants.groundBaseline)
            coordinator.playerAState.altitude = 0
            coordinator.playerBState.altitude = 0
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


    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        // 物理演算を更新
        physicsCoordinator?.update(currentTime: currentTime)

        // 雲との衝突チェック
        guard let coordinator = physicsCoordinator else { return }

        // 雲との衝突チェック（風船ノードはSwiftUIで表示するため、ダミーノードを使用）
        let dummyBalloon = SKSpriteNode()

        CloudCollisionDetector.checkBalloonCloudCollision(
            balloon: dummyBalloon,
            playerId: "A",
            balloonPosition: coordinator.playerAState.position,
            balloonVelocity: coordinator.playerAState.velocity,
            physicsCoordinator: coordinator,
            clouds: clouds,
            lightningNodes: &lightningNodes,
            scene: self
        )

        CloudCollisionDetector.checkBalloonCloudCollision(
            balloon: dummyBalloon,
            playerId: "B",
            balloonPosition: coordinator.playerBState.position,
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
