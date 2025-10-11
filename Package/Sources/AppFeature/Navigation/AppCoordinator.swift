//
//  AppCoordinator.swift
//  OnlyLonely
//

import SwiftUI

enum AppRoute: Hashable {
    // Common
    case title

    // iPad
    case connectionWaiting
    case iPadGameplay
    case iPadResult

    // iPhone
    case connection
    case playerNameInput
    case calibration
    case waiting
    case countdown
    case iPhoneGameplay
    case iPhoneResult
}

@MainActor
class AppCoordinator: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var currentRoute: AppRoute = .title

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
        path.removeAll()
        currentRoute = .title
    }

    func replace(with route: AppRoute) {
        path.removeAll()
        path.append(route)
        currentRoute = route
    }
}
