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
        List {
            Section("状態") {
                Text(hostModel.statusMessage)
                if let error = hostModel.lastErrorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section("接続可能なデバイス") {
                if hostModel.availableDevices.isEmpty {
                    Text("探索中...").foregroundStyle(.secondary)
                } else {
                    ForEach(hostModel.availableDevices) { device in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(device.name)
                                if hostModel.invitingPeerID == device.id {
                                    Text("招待中...")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button("招待") {
                                hostModel.invite(device)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(hostModel.invitingPeerID == device.id)
                        }
                    }
                }
            }

            Section("接続済みデバイス") {
                if hostModel.connectedDevices.isEmpty {
                    Text("まだ接続されていません").foregroundStyle(.secondary)
                } else {
                    ForEach(hostModel.connectedDevices) { peer in
                        Text(peer.name)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(hostModel.isHosting ? "停止" : "開始") {
                    hostModel.isHosting ? hostModel.stopHosting() : hostModel.startHosting()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("タイトルへ") {
                    hostModel.stopHosting()
                    coordinator.navigateToRoot()
                }
            }
        }
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
