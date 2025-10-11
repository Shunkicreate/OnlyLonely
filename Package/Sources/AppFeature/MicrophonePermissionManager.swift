//
//  MicrophonePermissionManager.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import AVFoundation
import Foundation

enum MicrophonePermissionState: Equatable {
    case undetermined
    case granted
    case denied
}

@MainActor
final class MicrophonePermissionManager: ObservableObject {
    @Published private(set) var permission: MicrophonePermissionState

    init() {
        permission = Self.currentPermission()
    }

    func refreshPermissionStatus() {
        permission = Self.currentPermission()
    }

    func requestPermission() {
        guard permission == .undetermined else {
            refreshPermissionStatus()
            return
        }

        AVAudioApplication.requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                self?.permission = granted ? .granted : .denied
            }
        }
    }

    var permissionMessage: String {
        switch permission {
        case .undetermined:
            return "マイクの使用許可が必要です。"
        case .granted:
            return "マイクの使用が許可されています。"
        case .denied:
            return "マイクの使用が拒否されています。設定アプリから許可を付与してください。"
        }
    }

    static func isPermissionGranted() -> Bool {
        switch currentPermission() {
        case .granted:
            return true
        case .undetermined, .denied:
            return false
        }
    }

    private static func currentPermission() -> MicrophonePermissionState {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return .undetermined
        @unknown default:
            return .undetermined
        }
    }
}
