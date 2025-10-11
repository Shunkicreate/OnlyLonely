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
    @StateObject private var characterManager: CharacterAssignmentManager

    public init() {
        let coordinator = AppCoordinator()
        let micPermissionManager = MicrophonePermissionManager()
        let sessionManager = P2PSessionManager()
        let bgmManager = BGMManager.shared
        let characterManager = CharacterAssignmentManager()
        _coordinator = StateObject(wrappedValue: coordinator)
        _micPermissionManager = StateObject(wrappedValue: micPermissionManager)
        _sessionManager = StateObject(wrappedValue: sessionManager)
        _hostConnectionModel = StateObject(wrappedValue: ConnectionWaitinScreenModel(sessionManager: sessionManager))
        _guestConnectionModel = StateObject(wrappedValue: ConnectionScreenModel(sessionManager: sessionManager))
        _bgmManager = StateObject(wrappedValue: bgmManager)
        _characterManager = StateObject(wrappedValue: characterManager)
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
        .environmentObject(characterManager)
        .onAppear {
            // アプリ起動時にマイク権限をリクエスト
            micPermissionManager.requestPermission()

            // Set up reset callback for when returning to title
            coordinator.onReturnToTitle = { [weak sessionManager, weak hostConnectionModel, weak guestConnectionModel] in
                print("🔄 [ContentView] Resetting app state...")

                // Reset P2P session manager
                sessionManager?.reset()

                // Reset iPad host model (stops hosting and clears devices)
                hostConnectionModel?.stopHosting()

                // Reset iPhone guest model (cancels connection and resets state)
                guestConnectionModel?.cancel()

                print("✅ [ContentView] App state reset complete")
            }
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
        case .iPadCountdown:
            CountdownScreen()
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
