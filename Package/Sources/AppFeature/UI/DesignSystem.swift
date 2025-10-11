//
//  DesignSystem.swift
//  OnlyLonely
//
//  デザインシステム - カラー、タイポグラフィ、定数
//

import SwiftUI

// MARK: - Colors

extension Color {
    /// Hex文字列からColorを生成
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnlyLonelyColors {
    // MARK: - エフェクトカラー

    /// 雷
    static let lightningGold = Color(hex: "#FFD700")

    /// グロウ
    static let neonGlow = Color(hex: "#00FFFF").opacity(0.6)
}

// MARK: - Animation

struct OnlyLonelyAnimation {
    /// 超スロー - 背景のグラデーション変化
    static let ultraSlow = Animation.easeInOut(duration: 3.0)

    /// ファスト - インタラクティブなフィードバック
    static let fast = Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
}
