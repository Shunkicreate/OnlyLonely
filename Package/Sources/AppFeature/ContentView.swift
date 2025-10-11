//
//  ContentView.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import SwiftUI

public struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()

    public init() {}

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            TitleScreen()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
        .environmentObject(coordinator)
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
