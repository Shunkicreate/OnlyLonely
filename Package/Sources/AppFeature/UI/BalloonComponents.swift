//
//  BalloonComponents.swift
//  OnlyLonely
//
//  共通の風船コンポーネント
//

import SwiftUI

/// キャラクター付き風船コンポーネント（タイトル画面とゲーム画面で共通使用）
struct CharacterBalloon: View {
    let imageName: String
    let color: String
    let size: CGFloat
    let showCharacter: Bool // キャラクターを表示するか
    let showString: Bool // 紐を表示するか

    @State private var rotation: Double = 0

    init(
        imageName: String,
        color: String,
        size: CGFloat,
        showCharacter: Bool = true,
        showString: Bool = true
    ) {
        self.imageName = imageName
        self.color = color
        self.size = size
        self.showCharacter = showCharacter
        self.showString = showString
    }

    var body: some View {
        VStack(spacing: 0) {
            // 風船本体
            ZStack {
                // グロー効果
                Circle()
                    .fill(Color(hex: color).opacity(0.5))
                    .frame(width: size + 30, height: size + 30)
                    .blur(radius: 20)

                // 風船本体（円形グラデーション）
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: color).opacity(0.9),
                                Color(hex: color)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: size
                        )
                    )
                    .frame(width: size, height: size)
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
                            .frame(width: size * 0.4, height: size * 0.4)
                            .offset(x: -size * 0.2, y: -size * 0.2)
                    )

                // Assets画像を上に重ねる
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
            .offset(y: showString ? 15 : 0)

            if showString {
                // 紐
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: size * 0.5),
                        control: CGPoint(x: sin(rotation * .pi / 180) * 12, y: size * 0.25)
                    )
                }
                .stroke(Color(hex: color).opacity(0.7), lineWidth: 3)
                .frame(width: 30, height: size * 0.5)
            }

            if showCharacter {
                // キャラクター画像
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 1.2, height: size * 1.2)
                    .offset(y: showString ? -25 : 0)
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2.5)
                    .repeatForever(autoreverses: true)
            ) {
                rotation = Double.random(in: -25...25)
            }
        }
    }
}

/// ゲーム用のシンプルな風船（スケール変化対応）
struct GameBalloon: View {
    let imageName: String
    let color: String
    let size: CGFloat
    let windForce: Float // 0.0 ~ 1.0

    var body: some View {
        CharacterBalloon(
            imageName: imageName,
            color: color,
            size: size,
            showCharacter: false,
            showString: false
        )
        .scaleEffect(1.0 + CGFloat(windForce) * 0.3)
    }
}
