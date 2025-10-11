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
    @StateObject private var gameManager = GameManager()
    @StateObject private var webSocketService = WebSocketService()

    @State private var playerAAltitude: Double = 0
    @State private var playerBAltitude: Double = 0

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
        }
        .onChange(of: gameManager.gamePhase) { _, newPhase in
            if newPhase == .finished {
                coordinator.navigate(to: .iPadResult)
            }
        }
    }

    private func createGameScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
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
        addChild(balloonA)

        // Player B の風船（右側・青）
        balloonB = createBalloon(color: .blue)
        balloonB.position = CGPoint(x: size.width * 3 / 4, y: 100)
        addChild(balloonB)

        // 地面
        let groundLeft = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width / 2, height: 50))
        groundLeft.position = CGPoint(x: size.width / 4, y: 25)
        addChild(groundLeft)

        let groundRight = SKSpriteNode(color: .green.withAlphaComponent(0.3), size: CGSize(width: size.width / 2, height: 50))
        groundRight.position = CGPoint(x: size.width * 3 / 4, y: 25)
        addChild(groundRight)
    }

    private func createBalloon(color: UIColor) -> SKSpriteNode {
        let balloon = SKSpriteNode(color: color, size: CGSize(width: 60, height: 80))
        balloon.name = "balloon"

        // 物理シミュレーション用（後で実装）
        // balloon.physicsBody = SKPhysicsBody(rectangleOf: balloon.size)
        // balloon.physicsBody?.isDynamic = true

        return balloon
    }

    func updateBalloonPosition(playerA: CGFloat, playerB: CGFloat) {
        balloonA.position.y = 100 + playerA
        balloonB.position.y = 100 + playerB
    }
}

#Preview {
    iPadGameplayScreen()
        .environmentObject(AppCoordinator())
}
