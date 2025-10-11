//
//  GameView.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//


import SwiftUI

struct GameView: View {
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

            // Floating D-pad
            dpad
        }
        .navigationTitle("Host")
    }

    private var dpad: some View {
        VStack {
            Spacer()
            HStack(spacing: 24) {
                // Left
                Button(action: { move(dx: -step, dy: 0) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }

                VStack(spacing: 24) {
                    // Up
                    Button(action: { move(dx: 0, dy: -step) }) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    // Down
                    Button(action: { move(dx: 0, dy: step) }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }

                // Right
                Button(action: { move(dx: step, dy: 0) }) {
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
    }
}
