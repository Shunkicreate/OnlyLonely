//
//  CountdownScreen.swift
//  OnlyLonely
//
//  10. カウントダウン画面（iPhone）
//  iPhone のみ
//

import SwiftUI

struct CountdownScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var countdown: Int = 3
    @State private var showStart: Bool = false
    @State private var scale: CGFloat = 1.0

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

            if showStart {
                // Start 表示
                VStack {
                    Text("Start!")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("🎈")
                        .font(.system(size: 80))
                }
                .scaleEffect(scale)
            } else {
                // カウントダウン数字
                Text("\(countdown)")
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        // 3, 2, 1 のカウントダウン
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(.easeOut(duration: 0.3)) {
                scale = 1.3
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    scale = 0.8
                }
            }

            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                // Start 表示
                showStart = true
                scale = 1.0

                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.2
                }

                // 0.5秒後にゲームプレイ画面へ遷移
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    coordinator.navigate(to: .iPhoneGameplay)
                }
            }
        }
    }
}

#Preview {
    CountdownScreen()
        .environmentObject(AppCoordinator())
}
