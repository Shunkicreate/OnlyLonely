//
//  AppCoordinator.swift
//  OnlyLonely
//

import SwiftUI

enum AppRoute: Hashable {
    // Common
    case title
    case credits

    // iPad
    case connectionWaiting
    case iPadCountdown
    case iPadGameplay
    case iPadResult

    // iPhone
    case connection
    case waiting
    case countdown
    case iPhoneGameplay
    case iPhoneResult
}

@MainActor
class AppCoordinator: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var currentRoute: AppRoute = .title

    // Callback for resetting app state when returning to title
    var onReturnToTitle: (() -> Void)?

    func navigate(to route: AppRoute) {
        path.append(route)
        currentRoute = route
    }

    func navigateBack() {
        if !path.isEmpty {
            path.removeLast()
            currentRoute = path.last ?? .title
        }
    }

    func navigateToRoot() {
        print("🏠 [AppCoordinator] Navigating to root, resetting state...")

        // Reset navigation state
        path.removeAll()
        currentRoute = .title

        // Call reset callback to clean up app state
        onReturnToTitle?()

        print("✅ [AppCoordinator] Navigation to root complete")
    }

    func replace(with route: AppRoute) {
        path.removeAll()
        path.append(route)
        currentRoute = route
    }
}
