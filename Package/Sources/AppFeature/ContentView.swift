//
//  ContentView.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import SwiftUI

public struct ContentView: View {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var micPermissionManager: MicrophonePermissionManager
    @StateObject private var sessionManager: P2PSessionManager
    @StateObject private var hostConnectionModel: ConnectionWaitinScreenModel
    @StateObject private var guestConnectionModel: ConnectionScreenModel
    @StateObject private var bgmManager: BGMManager
    @State private var showDebug = false

    public init() {
        let coordinator = AppCoordinator()
        let micPermissionManager = MicrophonePermissionManager()
        let sessionManager = P2PSessionManager()
        let bgmManager = BGMManager.shared
        _coordinator = StateObject(wrappedValue: coordinator)
        _micPermissionManager = StateObject(wrappedValue: micPermissionManager)
        _sessionManager = StateObject(wrappedValue: sessionManager)
        _hostConnectionModel = StateObject(wrappedValue: ConnectionWaitinScreenModel(sessionManager: sessionManager))
        _guestConnectionModel = StateObject(wrappedValue: ConnectionScreenModel(sessionManager: sessionManager))
        _bgmManager = StateObject(wrappedValue: bgmManager)
    }

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            TitleScreen()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(sessionManager)
        .environmentObject(hostConnectionModel)
        .environmentObject(guestConnectionModel)
        .environmentObject(bgmManager)
        .onAppear {
            // アプリ起動時にマイク権限をリクエスト
            micPermissionManager.requestPermission()
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showDebug = true
            } label: {
                Image(systemName: "ladybug.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(Color.red.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(radius: 6)
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        // Common
        case .title:
            TitleScreen()
        case .credits:
            CreditsScreen()

        // iPad
        case .connectionWaiting:
            ConnectionWaitingScreen()
        case .iPadGameplay:
            iPadGameplayScreen()
        case .iPadResult:
            iPadResultScreen()

        // iPhone
        case .connection:
            ConnectionScreen()
        case .waiting:
            WaitingScreen()
        case .countdown:
            CountdownScreen()
        case .iPhoneGameplay:
            iPhoneGameplayScreen()
        case .iPhoneResult:
            iPhoneResultScreen()
        }
    }
}

#Preview {
    ContentView()
}
