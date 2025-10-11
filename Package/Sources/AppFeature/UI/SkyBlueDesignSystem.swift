//
//  SkyBlueDesignSystem.swift
//  OnlyLonely
//
//  空と海をイメージした青系パステルデザインシステム
//  爽やかで優しい、水のような世界観
//

import SwiftUI

// MARK: - Sky Blue Colors

/// 空と海をイメージした青系パステルカラーパレット
struct SkyBlueColors {
    // MARK: Primary Colors (青系パステル)

    /// 空の青 - メインカラー
    static let skyBlue = Color(hex: "#B3D9FF")

    /// 水色 - サブカラー
    static let aqua = Color(hex: "#B3F5FF")

    /// ミントブルー - アクセント
    static let mintBlue = Color(hex: "#B3FFE5")

    /// ラベンダーブルー - 優しい紫がかった青
    static let lavenderBlue = Color(hex: "#C4B3FF")

    /// パウダーブルー - 淡い青
    static let powderBlue = Color(hex: "#D4E5FF")

    /// ターコイズ - 鮮やかな青緑
    static let turquoise = Color(hex: "#B3FFD4")

    /// ペールブルー - とても淡い青
    static let paleBlue = Color(hex: "#E5F2FF")

    // MARK: Accent Colors

    /// 白 - 雲や波の泡
    static let cloudWhite = Color(hex: "#FFFFFF")

    /// クリーム - 優しいアクセント
    static let cream = Color(hex: "#FFF9E5")

    /// ライトピーチ - 柔らかいコントラスト
    static let lightPeach = Color(hex: "#FFE5D9")

    // MARK: Text Colors

    /// プライマリテキスト - 読みやすい青灰色
    static let textPrimary = Color(hex: "#4A6B7C")

    /// セカンダリテキスト - 淡い青灰色
    static let textSecondary = Color(hex: "#7B9BAD")

    /// 非アクティブテキスト - とても淡いグレー
    static let textInactive = Color(hex: "#B8CDD9")

    // MARK: Player Colors

    /// プレイヤーA - 空色系
    static let playerAPrimary = skyBlue
    static let playerASecondary = aqua

    /// プレイヤーB - ミント系
    static let playerBPrimary = mintBlue
    static let playerBSecondary = turquoise

    // MARK: Gradients

    /// 空のグラデーション（メイン背景）
    static let skyGradient = LinearGradient(
        colors: [
            paleBlue,
            powderBlue,
            skyBlue,
            aqua
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 海のグラデーション
    static let oceanGradient = LinearGradient(
        colors: [
            aqua,
            skyBlue,
            turquoise,
            mintBlue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 爽やかグラデーション（ボタン用）
    static let freshGradient = LinearGradient(
        colors: [
            skyBlue,
            aqua,
            mintBlue
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// ラベンダースカイグラデーション
    static let lavenderSkyGradient = LinearGradient(
        colors: [
            lavenderBlue,
            skyBlue,
            aqua
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 水面グラデーション（キラキラ感）
    static let waterGradient = LinearGradient(
        colors: [
            paleBlue,
            aqua,
            turquoise,
            mintBlue,
            aqua,
            paleBlue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// ミストグラデーション（霧のような淡さ）
    static let mistGradient = LinearGradient(
        colors: [
            cloudWhite.opacity(0.8),
            paleBlue.opacity(0.6),
            powderBlue.opacity(0.4)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Sky Blue Typography

/// 空と海のテーマに合わせたタイポグラフィ
struct SkyBlueTypography {
    /// タイトル用フォント
    static func title(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// 本文用フォント
    static func body(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    /// キャプション用フォント
    static func caption(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    /// 数字用フォント（カウントダウンなど）
    static func number(size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}

// MARK: - Sky Blue Animations

/// 空と海をイメージした流れるようなアニメーション
struct SkyBlueAnimation {
    /// 波のように揺れる
    static func wave(duration: Double = 2.0) -> Animation {
        .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
    }

    /// 雲のようにふわふわ浮かぶ
    static func float(duration: Double = 3.0) -> Animation {
        .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
    }

    /// 水面のキラキラ
    static func shimmer(duration: Double = 2.0) -> Animation {
        .linear(duration: duration)
            .repeatForever(autoreverses: false)
    }

    /// 滑らかな流れ
    static func flow(duration: Double = 1.0) -> Animation {
        .spring(response: duration, dampingFraction: 0.7)
    }

    /// ふわっと現れる
    static func fadeIn(duration: Double = 0.8) -> Animation {
        .easeOut(duration: duration)
    }

    /// 水滴のように弾む
    static func droplet(duration: Double = 0.5) -> Animation {
        .spring(response: duration, dampingFraction: 0.6)
    }
}

// MARK: - Sky Blue Spacing

/// 余白の定義
struct SkyBlueSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// MARK: - View Modifiers

extension View {
    /// 空のような柔らかい影
    func skyShadow(color: Color = SkyBlueColors.skyBlue, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.3), radius: radius, x: 0, y: 4)
            .shadow(color: color.opacity(0.15), radius: radius * 2, x: 0, y: 8)
    }

    /// 水のような輝き
    func waterShine() -> some View {
        self
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.3),
                        Color.clear,
                        Color.white.opacity(0.2)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    /// 雲のような枠線
    func cloudBorder(color: Color = SkyBlueColors.skyBlue, width: CGFloat = 2) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.4),
                                color.opacity(0.2),
                                color.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: width
                    )
            )
    }
}
