//
//  PlayerNameInputScreen.swift
//  OnlyLonely
//
//  07. プレイヤー名入力画面（iPhone）
//  iPhone のみ
//

import SwiftUI

struct PlayerNameInputScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var playerName: String = ""
    @FocusState private var isTextFieldFocused: Bool

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

            VStack(spacing: 30) {
                Spacer()

                Text("プレイヤー名を入力")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("🎈")
                    .font(.system(size: 60))

                // プレイヤー名入力
                VStack(spacing: 12) {
                    TextField("あなたの名前", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 18))
                        .multilineTextAlignment(.center)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            joinGame()
                        }

                    Text("例: たろう、Player 1")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 40)

                // 参加ボタン
                Button {
                    joinGame()
                } label: {
                    Text("参加する")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.6))
                        )
                }
                .padding(.top, 20)

                Spacer()
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
        .navigationBarBackButtonHidden()
    }

    private func joinGame() {
        let name = playerName.isEmpty ? "Player \(Int.random(in: 1...99))" : playerName

        // WebSocket でプレイヤー参加メッセージを送信（後で実装）
        // webSocketService.send(.playerJoin(playerName: name, playerId: UUID().uuidString))

        // キャリブレーション画面をスキップして待機画面へ（MVP）
        coordinator.navigate(to: .waiting)
    }
}

#Preview {
    PlayerNameInputScreen()
        .environmentObject(AppCoordinator())
}
