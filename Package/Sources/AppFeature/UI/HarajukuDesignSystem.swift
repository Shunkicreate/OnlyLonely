//
//  HarajukuDesignSystem.swift
//  OnlyLonely
//
//  原宿系ふわふわデザインシステム
//

import SwiftUI

// MARK: - Harajuku Colors

struct HarajukuColors {
    // MARK: - パステルカラーパレット

    /// パステルピンク（メイン）
    static let pastelPink = Color(hex: "#FFB3D9")
    static let pastelPinkLight = Color(hex: "#FFDDF4")
    static let pastelPinkDark = Color(hex: "#FF8CC6")

    /// パステルブルー
    static let pastelBlue = Color(hex: "#B3E5FF")
    static let pastelBlueLight = Color(hex: "#E0F7FF")
    static let pastelBlueDark = Color(hex: "#87CEEB")

    /// パステルパープル
    static let pastelPurple = Color(hex: "#D9B3FF")
    static let pastelPurpleLight = Color(hex: "#F0E0FF")
    static let pastelPurpleDark = Color(hex: "#C499FF")

    /// パステルイエロー
    static let pastelYellow = Color(hex: "#FFFACD")
    static let pastelYellowLight = Color(hex: "#FFFFE0")
    static let pastelYellowDark = Color(hex: "#FFE66D")

    /// パステルミント
    static let pastelMint = Color(hex: "#B3FFE8")
    static let pastelMintLight = Color(hex: "#D9FFF5")
    static let pastelMintDark = Color(hex: "#87EED1")

    /// パステルピーチ
    static let pastelPeach = Color(hex: "#FFD4B3")
    static let pastelPeachLight = Color(hex: "#FFE8D9")
    static let pastelPeachDark = Color(hex: "#FFBD87")

    /// パステルラベンダー
    static let pastelLavender = Color(hex: "#E0B3FF")
    static let pastelLavenderLight = Color(hex: "#F5E0FF")
    static let pastelLavenderDark = Color(hex: "#D087FF")

    // MARK: - プレイヤーカラー（原宿風）

    /// Player A - ピンク×パープル
    static let playerAPrimary = pastelPink
    static let playerASecondary = pastelPurple
    static let playerAAccent = Color(hex: "#FF99DD")

    /// Player B - ブルー×ミント
    static let playerBPrimary = pastelBlue
    static let playerBSecondary = pastelMint
    static let playerBAccent = Color(hex: "#99EEDD")

    // MARK: - 背景グラデーション

    /// 虹色グラデーション
    static let rainbowGradient = LinearGradient(
        colors: [
            pastelPink,
            pastelPurple,
            pastelBlue,
            pastelMint,
            pastelYellow,
            pastelPeach
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// ピンク×パープルグラデーション
    static let pinkPurpleGradient = LinearGradient(
        colors: [pastelPinkLight, pastelPink, pastelPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// ブルー×ミントグラデーション
    static let blueMintGradient = LinearGradient(
        colors: [pastelBlueLight, pastelBlue, pastelMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 空グラデーション
    static let skyGradient = LinearGradient(
        colors: [
            pastelBlueLight,
            pastelPinkLight,
            pastelPurpleLight,
            Color.white.opacity(0.9)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// キャンディグラデーション
    static let candyGradient = LinearGradient(
        colors: [
            pastelPink,
            pastelPeach,
            pastelYellowLight,
            pastelMintLight
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - UIエレメント

    /// テキスト
    static let textPrimary = Color(hex: "#FF69B4") // ホットピンク
    static let textSecondary = Color(hex: "#DDA0DD").opacity(0.8) // プラム
    static let textWhite = Color.white

    /// シャドウ・グロウ
    static let shadowColor = Color(hex: "#FFB3D9").opacity(0.5)
    static let glowColor = Color(hex: "#FF99DD").opacity(0.8)
}

// MARK: - Harajuku Typography

struct HarajukuTypography {
    /// 超デカタイトル - ふわふわで目立つ
    static func hugeTitle(size: CGFloat = 64) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    /// タイトル - 大きく可愛く
    static func title(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    /// サブタイトル - ポップに
    static func subtitle(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    /// ボディ - 読みやすく可愛く
    static func body(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    /// キャプション - 小さめ
    static func caption(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    /// ゲーム内数値 - ポップに
    static func gameValue(size: CGFloat = 36) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
}

// MARK: - Harajuku Animation

struct HarajukuAnimation {
    /// ふわふわ浮遊（速め）
    static func bounce(duration: Double = 1.5) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }

    /// ぴょんぴょんジャンプ
    static let jump = Animation.spring(response: 0.4, dampingFraction: 0.5)

    /// くるくる回転
    static func spin(duration: Double = 2.0) -> Animation {
        .linear(duration: duration).repeatForever(autoreverses: false)
    }

    /// きらきらパルス
    static func sparkle(duration: Double = 1.0) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }

    /// ぷるぷる震え
    static func wiggle(duration: Double = 0.15) -> Animation {
        .easeInOut(duration: duration).repeatForever(autoreverses: true)
    }
}

// MARK: - Harajuku Spacing

struct HarajukuSpacing {
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

// MARK: - Harajuku Effects

extension View {
    /// 原宿風カラフルシャドウ
    func harajukuShadow(color: Color = HarajukuColors.pastelPink) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 4)
            .shadow(color: color.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    /// きらきらグロウ
    func sparkleGlow(color: Color = HarajukuColors.pastelPink) -> some View {
        self
            .shadow(color: color.opacity(0.8), radius: 10, x: 0, y: 0)
            .shadow(color: color.opacity(0.5), radius: 20, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: 30, x: 0, y: 0)
    }

    /// ふわふわボーダー
    func fluffyBorder(color: Color = HarajukuColors.pastelPink, width: CGFloat = 3) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color,
                                color.opacity(0.5),
                                color
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: width
                    )
            )
    }
}
