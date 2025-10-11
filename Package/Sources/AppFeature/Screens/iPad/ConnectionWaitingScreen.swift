//
//  ConnectionWaitingScreen.swift
//  OnlyLonely
//
//  Created by Codex on 2025/10/16.
//

import SwiftUI

struct ConnectionWaitingScreen: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var hostModel: ConnectionWaitinScreenModel

    var body: some View {
        VStack(spacing: 24) {
            Text("iPhone 接続待ち")
                .font(.title)
                .bold()

            Text(hostModel.statusText)
                .font(.body)

            if !hostModel.connectedDevices.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("接続済みデバイス")
                        .font(.headline)
                    ForEach(hostModel.connectedDevices, id: \.id) { peer in
                        Text(peer.name)
                            .font(.callout)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                Button(hostModel.isHosting ? "停止" : "待機を開始") {
                    hostModel.isHosting ? hostModel.stopHosting() : hostModel.startHosting()
                }
                .buttonStyle(.borderedProminent)

                Button("タイトルへ戻る") {
                    hostModel.stopHosting()
                    coordinator.navigateToRoot()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: hostModel.startHosting)
        .navigationTitle("接続待機")
    }
}

#Preview {
    let coordinator = AppCoordinator()
    let sessionManager = P2PSessionManager()
    let hostModel = ConnectionWaitinScreenModel(sessionManager: sessionManager)
    return NavigationStack {
        ConnectionWaitingScreen()
            .environmentObject(coordinator)
            .environmentObject(sessionManager)
            .environmentObject(hostModel)
    }
}
