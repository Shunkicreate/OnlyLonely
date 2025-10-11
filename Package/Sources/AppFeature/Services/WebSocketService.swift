//
//  WebSocketService.swift
//  OnlyLonely
//
//  WebSocket実装は後で追加予定
//

import Foundation
import Combine

@MainActor
class WebSocketService: ObservableObject {
    @Published var isConnected = false
    @Published var lastError: Error?

    // MARK: - Placeholder Methods (実装は後で追加)

    func connectToServer(host: String, port: Int) async throws {
        // TODO: WebSocket実装
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒待機（デモ用）
        isConnected = true
    }

    func startServer(port: Int = 8080) async throws {
        // TODO: WebSocket実装
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5秒待機（デモ用）
        isConnected = true
    }

    func stopServer() {
        // TODO: WebSocket実装
        isConnected = false
    }

    func disconnect() {
        // TODO: WebSocket実装
        isConnected = false
    }
}
