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
    // MARK: - 空のグラデーション

    /// 低高度 - 夕暮れの空
    static let peach = Color(hex: "#FFE5B4")
    static let lightPink = Color(hex: "#FFB6C1")
    static let plum = Color(hex: "#DDA0DD")

    /// 中高度 - 透明感のある青空
    static let skyBlue = Color(hex: "#87CEEB")
    static let powderBlue = Color(hex: "#B0E0E6")
    static let iceBlue = Color(hex: "#E0F6FF")

    /// 高高度 - 宇宙の入り口
    static let darkBlue = Color(hex: "#4A5A8A")
    static let midnightBlue = Color(hex: "#2C3E7C")
    static let spaceBlack = Color(hex: "#1A1A2E")

    // MARK: - プレイヤーカラー

    /// Player A - 温かみのある色
    static let playerAPrimary = Color(hex: "#FF6B9D")
    static let playerASecondary = Color(hex: "#FFA07A")

    /// Player B - 冷たく透明感のある色
    static let playerBPrimary = Color(hex: "#88D4FF")
    static let playerBSecondary = Color(hex: "#A3D5FF")

    // MARK: - エフェクトカラー

    /// 雷
    static let lightningGold = Color(hex: "#FFD700")
    static let lightningKhaki = Color(hex: "#F0E68C")

    /// 雲
    static let cloudSilver = Color(hex: "#B0B0B0")
    static let cloudGray = Color(hex: "#808080")

    // MARK: - UIエレメント

    /// テキスト
    static let textPrimary = Color.white.opacity(0.9)
    static let textSecondary = Color.white.opacity(0.6)
    static let textInactive = Color.white.opacity(0.3)

    /// グロウ
    static let softGlow = Color.white.opacity(0.4)
    static let neonGlow = Color(hex: "#00FFFF").opacity(0.6)

    // MARK: - グラデーション

    /// 低高度グラデーション
    static let lowAltitudeGradient = LinearGradient(
        colors: [peach, lightPink, plum],
        startPoint: .bottom,
        endPoint: .top
    )

    /// 中高度グラデーション
    static let midAltitudeGradient = LinearGradient(
        colors: [skyBlue, powderBlue, iceBlue],
        startPoint: .bottom,
        endPoint: .top
    )

    /// 高高度グラデーション
    static let highAltitudeGradient = LinearGradient(
        colors: [darkBlue, midnightBlue, spaceBlack],
        startPoint: .bottom,
        endPoint: .top
    )

    /// タイトル画面用グラデーション
    static let titleGradient = LinearGradient(
        colors: [spaceBlack, midnightBlue, darkBlue, skyBlue],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Player A ボタングラデーション
    static let playerAButtonGradient = LinearGradient(
        colors: [playerAPrimary, playerASecondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Player B ボタングラデーション
    static let playerBButtonGradient = LinearGradient(
        colors: [playerBPrimary, playerBSecondary],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Typography

struct OnlyLonelyTypography {
    /// タイトル - 大きく詩的に
    static func title(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .ultraLight, design: .rounded)
    }

    /// サブタイトル - 繊細に
    static func subtitle(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .thin, design: .rounded)
    }

    /// ボディ - 読みやすく
    static func body(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }

    /// キャプション - 控えめに
    static func caption(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .ultraLight, design: .rounded)
    }

    /// ゲーム内数値 - ゲームライクに
    static func gameValue(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}

// MARK: - Spacing

struct OnlyLonelySpacing {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Animation

struct OnlyLonelyAnimation {
    /// 超スロー - 背景のグラデーション変化
    static let ultraSlow = Animation.easeInOut(duration: 3.0)

    /// スロー - 画面遷移、重要な演出
    static let slow = Animation.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.3)

    /// ミディアム - UI要素の表示/非表示
    static let medium = Animation.spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.2)

    /// ファスト - インタラクティブなフィードバック
    static let fast = Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)

    /// 浮遊アニメーション
    static func floating(duration: Double = 2.5) -> Animation {
        Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
    }

    /// パルスアニメーション
    static func pulse(duration: Double = 1.5) -> Animation {
        Animation.easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}
