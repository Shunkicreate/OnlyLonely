//
//  GameView.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//


import SwiftUI

import MultipeerConnectivity

enum GameRole {
    case host
    case guest
}

struct GameView: View {
    @EnvironmentObject var gameState: P2PGameState
    let role: GameRole
    // Circle offset from center in points
    @State private var offset: CGSize = .zero
    // One tap movement size
    private let step: CGFloat = 24
    // Circle visual size
    private let circleSize: CGFloat = 100

    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()

            // Central circle
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 4)
                )
                .shadow(radius: 6)
                .offset(offset)
                .animation(.easeOut(duration: 0.12), value: offset)

            // Floating D-pad (guest only)
            if role == .guest {
                dpad
            }
        }
        .navigationTitle(role == .host ? "Host" : "Guest")
        .onReceive(gameState.$ballState) { state in
            guard let s = state else { return }
            // Update offset when remote position changes
            offset = CGSize(width: CGFloat(s.position.x), height: CGFloat(s.position.y))
        }
    }

    private var dpad: some View {
        VStack {
            Spacer()
            HStack(spacing: 24) {
                // Left
                Button(action: { sendTap(.left) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }

                VStack(spacing: 24) {
                    // Up
                    Button(action: { sendTap(.up) }) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    // Down
                    Button(action: { sendTap(.down) }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }

                // Right
                Button(action: { sendTap(.right) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 32)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func move(dx: CGFloat, dy: CGFloat) {
        offset = CGSize(width: offset.width + dx, height: offset.height + dy)
        publishPosition()
    }

    private func publishPosition() {
        // Convert offset to simple grid ints for demo
        let pos = BallPosition(x: Int(offset.width.rounded()), y: Int(offset.height.rounded()))
        let newState = BallState(position: pos)
        gameState.updateBallState(_ballState: newState)
        let message = UpdateBallStateMessage(ballState: newState)
        guard
            let json = message.toJson(),
            let data = P2PMessage(type: .updateBallStateMessage, jsonData: json).toSendMessage().data(using: .utf8),
            let session = gameState.session
        else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    private func sendTap(_ action: TapAction) {
        guard role == .guest, let session = gameState.session else { return }
        let tap = TapActionMessage(action: action)
        guard
            let json = tap.toJson(),
            let data = P2PMessage(type: .gameTapActionMessage, jsonData: json).toSendMessage().data(using: .utf8)
        else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}
