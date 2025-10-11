//
//  ContentView.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var permissionManager = MicrophonePermissionManager()
    @StateObject private var levelManager = MicrophoneLevelManager()

    var body: some View {
        NavigationStack {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("マイクのアクセス状態")
                    .font(.headline)
                Text(permissionManager.permissionMessage)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }

            Button("マイクの権限をリクエスト") {
                permissionManager.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .disabled(permissionManager.permission != .undetermined)

            if permissionManager.permission == .granted {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ピークレベル")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formattedDecibels(for: levelManager.peakHoldLevel))
                            .font(.title2.monospacedDigit())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button(levelManager.isMonitoring ? "計測を停止" : "計測を開始") {
                        toggleMonitoring()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if permissionManager.permission == .denied {
                VStack(spacing: 8) {
                    Text("設定アプリから「プライバシー > マイク」で権限を付与してください。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("権限状態を再読み込み") {
                        permissionManager.refreshPermissionStatus()
                    }
                }
            }

            Spacer()

            // P2P navigation
            VStack(spacing: 12) {
                Text("P2P")
                    .font(.headline)
                HStack {
                    NavigationLink("Host へ", destination: { HostView() })
                        .buttonStyle(.borderedProminent)
                    NavigationLink("Guest へ", destination: { GuestView() })
                        .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .onAppear {
            permissionManager.refreshPermissionStatus()
        }
        .onChange(of: permissionManager.permission) { _, newValue in
            if newValue != .granted {
                levelManager.stopMonitoring()
            }
        }
        .onDisappear {
            levelManager.stopMonitoring()
        }
        }
    }

    private func toggleMonitoring() {
        if levelManager.isMonitoring {
            levelManager.stopMonitoring()
        } else {
            levelManager.startMonitoring()
        }
    }

    private func formattedDecibels(for value: Float?) -> String {
        guard let value else { return "-- dB" }
        return String(format: "%.1f dB", value)
    }
}

#Preview {
    ContentView()
}
