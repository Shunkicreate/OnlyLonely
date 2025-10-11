//
//  TitleScreen.swift
//  OnlyLonely
//
//  01. タイトル画面
//  iPad / iPhone 共通
//

import SwiftUI

struct TitleScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var balloonOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.8, green: 0.9, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // タイトル
                VStack(spacing: 16) {
                    Text("OnlyLonely")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("息で飛ばす、ふたりの風船")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }

                // 風船アニメーション
                HStack(spacing: 30) {
                    Text("🎈")
                        .font(.system(size: 60))
                        .offset(y: balloonOffset)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: balloonOffset
                        )

                    Text("🎈")
                        .font(.system(size: 60))
                        .offset(y: -balloonOffset)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                                .delay(0.5),
                            value: balloonOffset
                        )
                }

                Spacer()

                // タップしてスタート
                Text("タップしてスタート")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .scaleEffect(balloonOffset == 0 ? 1.0 : 1.05)

                Spacer()
                    .frame(height: 60)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            balloonOffset = 20
        }
    }

    private func handleTap() {
        // デバイスを自動判定して遷移
        let deviceType = DeviceType.current

        switch deviceType {
        case .iPad:
            coordinator.navigate(to: .connectionWaiting)
        case .iPhone:
            coordinator.navigate(to: .connection)
        }
    }
}

#Preview {
    TitleScreen()
        .environmentObject(AppCoordinator())
}
