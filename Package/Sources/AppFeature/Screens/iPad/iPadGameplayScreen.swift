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
    @StateObject private var screenModel: iPadGameplayScreenModel
    @StateObject private var gameManager = GameManager()
    @StateObject private var webSocketService = WebSocketService()
    @StateObject private var physicsCoordinator = GamePhysicsCoordinator()

    @State private var playerAAltitude: Double = 0
    @State private var playerBAltitude: Double = 0

    init(sessionManager: P2PSessionManager) {
        _screenModel = StateObject(wrappedValue: iPadGameplayScreenModel(sessionManager: sessionManager))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit Scene
                SpriteView(
                    scene: createGameScene(size: geometry.size),
                    options: [.allowsTransparency]
                )
                .ignoresSafeArea()

                // UI Overlay
                VStack {
                    // 残り時間
                    HStack {
                        Spacer()
                        Text("残り時間: \(gameManager.timeRemaining)秒")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
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

                    // デバッグ用：風力入力ボタン
                    #if DEBUG
                    HStack(spacing: 40) {
                        // Player A 風力ボタン（長押し対応）
                        VStack(spacing: 8) {
                            Text("Player A")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.red)

                            Text("🌬️ 風を送る")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.red.opacity(0.7))
                                )
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            // 押している間：風力を送り続ける
                                            physicsCoordinator.receiveWindInput(playerId: "A", force: 0.8)
                                        }
                                        .onEnded { _ in
                                            // 離した時：風力を0に
                                            physicsCoordinator.receiveWindInput(playerId: "A", force: 0.0)
                                        }
                                )
                        }

                        // Player B 風力ボタン（長押し対応）
                        VStack(spacing: 8) {
                            Text("Player B")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.blue)

                            Text("🌬️ 風を送る")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.7))
                                )
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            // 押している間：風力を送り続ける
                                            physicsCoordinator.receiveWindInput(playerId: "B", force: 0.8)
                                        }
                                        .onEnded { _ in
                                            // 離した時：風力を0に
                                            physicsCoordinator.receiveWindInput(playerId: "B", force: 0.0)
                                        }
                                )
                        }
                    }
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.horizontal, 40)
                    #endif

                    Spacer()

                    // プレイヤー情報
                    HStack(spacing: 0) {
                        // Player A
                        PlayerInfoPanel(
                            playerName: "Player A",
                            altitude: playerAAltitude,
                            color: .red
                        )
                        .frame(width: geometry.size.width / 2)

                        // Divider
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2)

                        // Player B
                        PlayerInfoPanel(
                            playerName: "Player B",
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
            gameManager.startGame()
            screenModel.activate()
            // TODO: 雲データ読み込み
            // try? physicsCoordinator.loadCloudData(json: "...")
        }
        .onChange(of: gameManager.gamePhase) { _, newPhase in
            if newPhase == .finished {
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
}

struct PlayerInfoPanel: View {
    let playerName: String
    let altitude: Double
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(playerName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("高度: \(Int(altitude))m")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
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

class GameScene: SKScene {
    private var balloonA: SKSpriteNode!
    private var balloonB: SKSpriteNode!

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
    }

    private func setupScene() {
        // 背景グラデーション
        let background = SKSpriteNode(color: UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0), size: self.size)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)

        // 中央の分割線
        let divider = SKSpriteNode(color: .white.withAlphaComponent(0.3), size: CGSize(width: 2, height: size.height))
        divider.position = CGPoint(x: size.width / 2, y: size.height / 2)
        divider.zPosition = 1
        addChild(divider)

        // Player A の風船（左側・赤）
        balloonA = createBalloon(color: .red)
        balloonA.position = CGPoint(x: size.width / 4, y: 100)
        balloonA.zPosition = 10 // 前面に表示
        addChild(balloonA)

        // Player B の風船（右側・青）
        balloonB = createBalloon(color: .blue)
        balloonB.position = CGPoint(x: size.width * 3 / 4, y: 100)
        balloonB.zPosition = 10 // 前面に表示
        addChild(balloonB)

        // 物理エンジンに初期位置を設定
        if let coordinator = physicsCoordinator {
            coordinator.playerAState.position = CGPoint(x: size.width / 4, y: 100)
            coordinator.playerBState.position = CGPoint(x: size.width * 3 / 4, y: 100)
        }

        // 地面
        let groundLeft = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width / 2, height: 50))
        groundLeft.position = CGPoint(x: size.width / 4, y: 25)
        groundLeft.zPosition = 0
        addChild(groundLeft)

        let groundRight = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width / 2, height: 50))
        groundRight.position = CGPoint(x: size.width * 3 / 4, y: 25)
        groundRight.zPosition = 0
        addChild(groundRight)
    }

    private func createBalloon(color: UIColor) -> SKSpriteNode {
        // 絵文字風船を表示するコンテナ
        let container = SKSpriteNode(color: .clear, size: CGSize(width: 60, height: 80))
        container.name = "balloon"

        // 絵文字の風船
        let emojiLabel = SKLabelNode(text: "🎈")
        emojiLabel.fontSize = 60
        emojiLabel.verticalAlignmentMode = .center
        emojiLabel.position = CGPoint(x: 0, y: 0)
        container.addChild(emojiLabel)

        // 色分け用の背景円（オプション）
        let colorCircle = SKShapeNode(circleOfRadius: 10)
        colorCircle.fillColor = color
        colorCircle.strokeColor = .clear
        colorCircle.position = CGPoint(x: 0, y: -30)
        colorCircle.zPosition = -1
        container.addChild(colorCircle)

        return container
    }

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)

        // 物理演算を更新
        physicsCoordinator?.update(currentTime: currentTime)

        // 風船の位置を同期
        if let stateA = physicsCoordinator?.playerAState {
            balloonA.position = stateA.position
        }
        if let stateB = physicsCoordinator?.playerBState {
            balloonB.position = CGPoint(x: size.width * 3 / 4, y: stateB.position.y)
        }
    }

    func updateBalloonPosition(playerA: CGFloat, playerB: CGFloat) {
        balloonA.position.y = 100 + playerA
        balloonB.position.y = 100 + playerB
    }
}

#Preview {
    let sessionManager = P2PSessionManager()
    iPadGameplayScreen(sessionManager: sessionManager)
        .environmentObject(AppCoordinator())
}
