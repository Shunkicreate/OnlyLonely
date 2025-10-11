//
//  ContentView.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import SwiftUI

public struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var micPermissionManager = MicrophonePermissionManager()
    @State private var showDebug = false

    public init() {}

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            TitleScreen()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(coordinator)
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
        .sheet(isPresented: $showDebug) {
            DebugScreen()
        }
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        // Common
        case .title:
            TitleScreen()

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
        case .playerNameInput:
            PlayerNameInputScreen()
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
